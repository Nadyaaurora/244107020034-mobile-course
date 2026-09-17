import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/post.dart';
import '../data/network_errors.dart';
import '../data/paged_posts.dart';
import '../data/providers.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({super.key, required this.postId, this.initialPost});

  final int postId;
  final Post? initialPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromPostList = ref
        .read(postListProvider)
        .when(
          data: (posts) => posts.cast<Post?>().firstWhere(
            (post) => post?.id == postId,
            orElse: () => null,
          ),
          loading: () => null,
          error: (_, _) => null,
        );
    final cached =
        initialPost ??
        fromPostList ??
        ref
            .read(pagedPostsProvider)
            .items
            .cast<Post?>()
            .firstWhere((post) => post?.id == postId, orElse: () => null);

    if (cached != null) {
      return _PostDetailBody(post: cached);
    }

    return _PostDetailFromRepository(postId: postId);
  }
}

class _PostDetailFromRepository extends ConsumerWidget {
  const _PostDetailFromRepository({required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.watch(postRepositoryProvider).fetchPost(postId);

    return FutureBuilder<Post>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Post $postId')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Post $postId')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  friendlyErrorMessage(snapshot.error!),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return _PostDetailBody(post: snapshot.data!);
      },
    );
  }
}

class _PostDetailBody extends StatelessWidget {
  const _PostDetailBody({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post ${post.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
