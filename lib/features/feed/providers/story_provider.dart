import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/author.dart';
import '../domain/fake_feed_seed.dart';

part 'story_provider.g.dart';

@Riverpod(keepAlive: true)
List<Author> storyAuthors(Ref ref) => FakeFeedSeed.storyAuthors;
