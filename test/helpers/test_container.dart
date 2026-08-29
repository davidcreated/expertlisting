import 'package:expertlisting/core/session/current_user_provider.dart';
import 'package:expertlisting/features/feed/domain/fake_post_repository.dart';
import 'package:expertlisting/features/feed/domain/post_repository.dart';
import 'package:expertlisting/features/feed/providers/post_repository_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

FakePostRepository buildFakeRepository({
  FakeFailureSwitches? failures,
  DateTime? now,
}) {
  return FakePostRepository(
    currentUser: kMockCurrentUser,
    failures: failures,
    latency: Duration.zero,
    now: now ?? DateTime(2026, 8, 28, 12),
  );
}

ProviderContainer createContainer({PostRepository? repository}) {
  final container = ProviderContainer(
    overrides: [
      postRepositoryProvider.overrideWithValue(
        repository ?? buildFakeRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}
