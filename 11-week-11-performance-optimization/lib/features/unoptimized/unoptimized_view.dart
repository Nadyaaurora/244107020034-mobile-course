import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/item_model.dart';

/// Halaman SEBELUM Optimasi:
/// 1. Menggunakan setState periodik pada root widget
/// 2. Tanpa const constructor
/// 3. Memuat 100 item sekaligus tanpa ListView.builder (SingleChildScrollView + Column)
/// 4. Anonymous closure function di dalam build method
/// 5. Tanpa RepaintBoundary
class UnoptimizedView extends StatefulWidget {
  const UnoptimizedView({super.key});

  @override
  State<UnoptimizedView> createState() => _UnoptimizedViewState();
}

class _UnoptimizedViewState extends State<UnoptimizedView> {
  int _rebuildCounter = 0;
  Timer? _ticker;
  late List<Item> _heavyItems;

  @override
  void initState() {
    super.initState();
    // Membangun 100 item secara eager di memori
    _heavyItems = List.generate(
      100,
      (i) => Item(
        id: i + 1,
        title: 'Pengumuman Kuliah Tanpa Optimasi #${i + 1}',
        description: 'Item ini di-render sekaligus dalam satu Column besar tanpa lazy loading viewport.',
        category: i % 2 == 0 ? 'Akademik' : 'Kemahasiswaan',
        imageUrl: '',
      ),
    );

    // Memicu rebuild konstan setiap detik di root untuk mendemonstrasikan jank
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _rebuildCounter++;
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Buruk: Membangun semua 100 item sekaligus ke pohon render
        child: Column(
          children: [
            // Banner Peringatan
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade100,
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode SEBELUM Optimasi (Rebuild Root: $_rebuildCounter kali)\n'
                      'Semua 100 item di-build sekaligus tanpa lazy loading.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 100 item non-const dibuat ulang setiap kali ticker berdetik
            ..._heavyItems.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.article_outlined,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Buruk: Anonymous closure dibuat ulang setiap frame
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Detail: ${item.title}'),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
