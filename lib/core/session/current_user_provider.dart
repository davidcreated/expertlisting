import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/feed/domain/author.dart';

part 'current_user_provider.g.dart';

const Author kMockCurrentUser = Author(
  id: 'user-me',
  name: 'David Roberts',
  username: 'david.r',
  avatarUrl: 'https://i.pravatar.cc/200?img=13',
  role: AuthorRole.agent,
);

@Riverpod(keepAlive: true)
Author currentUser(Ref ref) => kMockCurrentUser;
