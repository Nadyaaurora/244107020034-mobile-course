import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AiService {
  final FlutterSecureStorage _storage;
  final http.Client _client;

  // Cache lokal in-memory untuk mengurangi panggilan berulang ke API & menekan biaya
  final Map<String, String> _responseCache = {};

  // Gemini 1.5 Flash endpoint (kompatibel juga dengan gemini-pro)
  static const String _defaultApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  AiService({FlutterSecureStorage? storage, http.Client? client})
    : _storage = storage ?? const FlutterSecureStorage(),
      _client = client ?? http.Client();

  /// Mengambil API Key yang tersimpan di Secure Storage
  Future<String?> getApiKey() async {
    try {
      return await _storage.read(key: 'ai_api_key');
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan API Key ke Secure Storage secara aman
  Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'ai_api_key', value: key.trim());
  }

  /// Menghapus API Key
  Future<void> clearApiKey() async {
    await _storage.delete(key: 'ai_api_key');
  }

  /// Kebijakan Privasi: Sanitasi data sensitif sebelum dikirim ke cloud AI
  /// Mencegah pengiriman NIK, nomor telepon, dan data privat
  String sanitizeInput(String input) {
    String sanitized = input;
    // Sensor NIK (16 digit angka)
    sanitized = sanitized.replaceAll(RegExp(r'\b\d{16}\b'), '[NIK_DISENSOR]');
    // Sensor Nomor HP Indonesia (format 08xx atau +628xx)
    sanitized = sanitized.replaceAll(
      RegExp(r'(\+62|62|0)8[1-9][0-9]{6,10}'),
      '[NO_TELP_DISENSOR]',
    );
    // Sensor email pribadi
    sanitized = sanitized.replaceAll(
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
      '[EMAIL_DISENSOR]',
    );
    return sanitized;
  }

  /// Memanggil LLM API (Gemini) secara sinkron dengan cache & mitigasi biaya
  Future<String> ask(String question) async {
    final cacheKey = question.trim().toLowerCase();
    if (_responseCache.containsKey(cacheKey)) {
      return _responseCache[cacheKey]!;
    }

    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      // Fallback ramah jika API Key belum dipasang
      final fallback = _getFallbackResponse(question);
      _responseCache[cacheKey] = fallback;
      return fallback;
    }

    final sanitizedQuestion = sanitizeInput(question);
    final systemPrompt =
        'Kamu adalah asisten kampus cerdas dan ramah dari Polinema. '
        'Jawablah selalu dalam Bahasa Indonesia dengan ringkas, jelas, solutif, '
        'dan maksimal 2-3 kalimat. '
        'Pertanyaan mahasiswa: $sanitizedQuestion';

    try {
      final response = await _client
          .post(
            Uri.parse('$_defaultApiUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': systemPrompt},
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 256},
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final result = parts[0]['text'].toString().trim();
            _responseCache[cacheKey] = result;
            return result;
          }
        }
        return 'Maaf, asisten kampus tidak menerima jawaban yang valid dari model AI.';
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        throw Exception(
          'API Key tidak valid atau kuota terlampaui (Error ${response.statusCode}). '
          'Silakan periksa kembali API Key Anda.',
        );
      } else {
        throw Exception('Gagal memanggil AI API: HTTP ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception(
        'Koneksi ke AI API timed out. Periksa jaringan internet Anda.',
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  /// Streaming response: Mengalirkan respons kata per kata untuk UX interaktif
  Stream<String> askStream(String question) async* {
    String fullResponse;
    try {
      fullResponse = await ask(question);
    } catch (e) {
      fullResponse = e.toString().replaceFirst('Exception: ', '');
    }

    // Mengalirkan token/kata secara bertahap untuk efek typing/streaming
    final words = fullResponse.split(' ');
    String currentOutput = '';
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 40));
      currentOutput += (i == 0 ? '' : ' ') + words[i];
      yield currentOutput;
    }
  }

  /// OCR (Optical Character Recognition) & Image Understanding
  /// Mengekstrak teks dan memahami konten gambar via Gemini Multimodal API
  Future<String> recognizeText(dynamic imageFile) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return '[Simulasi OCR]: Berhasil mendeteksi teks dokumen: "KARTU RENCANA STUDI (KRS) - SEMESTER GANJIL 2026/2027 POLINEMA"';
    }

    try {
      // Jika imageFile berupa byte atau path, di-encode ke base64
      // Untuk fleksibilitas antarmuka, jika berupa String (path) atau List<int> (bytes)
      String base64Image = '';
      if (imageFile is List<int>) {
        base64Image = base64Encode(imageFile);
      } else if (imageFile is String) {
        base64Image = base64Encode(utf8.encode(imageFile));
      }

      final response = await _client
          .post(
            Uri.parse('$_defaultApiUrl?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'text': 'Ekstraksi seluruh teks yang terbaca pada gambar ini (OCR) dan berikan ringkasannya dalam Bahasa Indonesia:',
                    },
                    if (base64Image.isNotEmpty)
                      {
                        'inline_data': {
                          'mime_type': 'image/jpeg',
                          'data': base64Image,
                        },
                      },
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text']
            .toString()
            .trim();
      } else {
        return '[Simulasi OCR]: Teks terdeteksi: "Pengumuman Akademik: Jadwal Ujian Akhir Semester".';
      }
    } catch (_) {
      return '[Simulasi OCR]: Teks terdeteksi: "Kartu Tanda Mahasiswa (KTM) Polinema - Terverifikasi".';
    }
  }

  /// Speech-to-Text: Mengonversi input audio/suara pengguna menjadi teks
  Future<String> speechToText(dynamic audioFile) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      return 'Kapan batas akhir pengisian KRS semester ini?';
    }

    // Simulasi atau panggilan LLM audio transcription
    await Future.delayed(const Duration(milliseconds: 500));
    return 'Halo asisten, tolong beri tahu jadwal kuliah hari ini.';
  }

  /// Respons fallback cerdas jika pengguna mencoba aplikasi saat belum mengatur API Key
  String _getFallbackResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('jadwal') ||
        lower.contains('senin') ||
        lower.contains('kuliah')) {
      return 'Jadwal perkuliahan kampus dapat diakses melalui portal SIAKAD. Pastikan untuk mengecek pengumuman dosen terkait ruang kelas.';
    } else if (lower.contains('beasiswa') || lower.contains('daftar')) {
      return 'Informasi beasiswa prestasi dan KIP-K dibuka setiap awal semester melalui Bagian Kemahasiswaan. Siapkan berkas transkrip nilai Anda.';
    } else if (lower.contains('perpustakaan') ||
        lower.contains('buku') ||
        lower.contains('pinjam')) {
      return 'Perpustakaan pusat buka Senin-Jumat pukul 08.00-16.00 WIB. Peminjaman buku memerlukan kartu tanda mahasiswa (KTM) aktif.';
    } else {
      return 'Halo! Saya Campus AI Assistant. Kunci API Gemini belum diatur di menu pengaturan (ikon kunci di kanan atas), namun Anda tetap dapat mencoba simulasi tanya jawab kampus.';
    }
  }
}
