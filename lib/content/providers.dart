import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'content_repository.dart';
import 'models.dart';

final Provider<ContentRepository> contentRepositoryProvider =
    Provider<ContentRepository>((ref) => AssetContentRepository());

final FutureProvider<ContentBundle> contentBundleProvider =
    FutureProvider<ContentBundle>(
      (ref) => ref.watch(contentRepositoryProvider).load(),
    );
