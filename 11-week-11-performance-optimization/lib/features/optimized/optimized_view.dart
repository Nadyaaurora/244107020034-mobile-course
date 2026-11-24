import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/item_model.dart';
import '../../data/item_repository.dart';

class OptimizedView extends ConsumerStatefulWidget {
  const OptimizedView({super.key});

  @override
  ConsumerState<OptimizedView> createState() => _OptimizedViewState();
}

class _OptimizedViewState extends ConsumerState<OptimizedView> {
  final ScrollController _scrollController = ScrollController();
  final List<Item> _items = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPage();
    }
  }

  Future<void> _loadPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(itemRepositoryProvider);
      final newItems = await repository.fetchPage(_page);

      if (mounted) {
        setState(() {
          if (newItems.isEmpty) {
            _hasMore = false;
          } else {
            _items.addAll(newItems);
            _page++;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    ref.read(itemRepositoryProvider).clearCache();
    setState(() {
      _items.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadPage();
  }

  void _handleItemTap(Item item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Terpilih: ${item.title}'),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode SESUDAH Optimasi: ListView.builder + Lazy Loading + Caching\n'
                      'Item aktif di render tree: ${_items.length} item (Pagination hal. $_page)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _items.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final item = _items[index];
                  return RepaintBoundary(
                    child: OptimizedItemTile(item: item, onTap: _handleItemTap),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OptimizedItemTile extends StatelessWidget {
  final Item item;
  final ValueChanged<Item> onTap;

  const OptimizedItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_outlined, color: Colors.blue.shade700),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 14),
            onPressed: () => onTap(item),
          ),
        ],
      ),
    );
  }
}
