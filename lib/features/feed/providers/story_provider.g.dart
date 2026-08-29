// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storyAuthors)
final storyAuthorsProvider = StoryAuthorsProvider._();

final class StoryAuthorsProvider
    extends $FunctionalProvider<List<Author>, List<Author>, List<Author>>
    with $Provider<List<Author>> {
  StoryAuthorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storyAuthorsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storyAuthorsHash();

  @$internal
  @override
  $ProviderElement<List<Author>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Author> create(Ref ref) {
    return storyAuthors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Author> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Author>>(value),
    );
  }
}

String _$storyAuthorsHash() => r'3277b9bd9d9a55b9e1e25a9e16e037754adc1d1b';
