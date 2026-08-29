import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_env.dart';
import '../../../core/network/api_client.dart';
import '../../../core/session/current_user_provider.dart';
import '../domain/api_post_repository.dart';
import '../domain/fake_post_repository.dart';
import '../domain/post_repository.dart';

part 'post_repository_provider.g.dart';

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient();

@Riverpod(keepAlive: true)
PostRepository postRepository(Ref ref) {
  if (AppEnv.useFakeData) {
    return FakePostRepository(currentUser: ref.watch(currentUserProvider));
  }
  return ApiPostRepository(ref.watch(apiClientProvider).dio);
}
