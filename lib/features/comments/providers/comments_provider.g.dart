// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Comments)
final commentsProvider = CommentsFamily._();

final class CommentsProvider
    extends $AsyncNotifierProvider<Comments, CommentListResult> {
  CommentsProvider._({
    required CommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentsHash();

  @override
  String toString() {
    return r'commentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Comments create() => Comments();

  @override
  bool operator ==(Object other) {
    return other is CommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsHash() => r'473d753230df90d31d96de8da8d6117b063f6a42';

final class CommentsFamily extends $Family
    with
        $ClassFamilyOverride<
          Comments,
          AsyncValue<CommentListResult>,
          CommentListResult,
          FutureOr<CommentListResult>,
          String
        > {
  CommentsFamily._()
    : super(
        retry: null,
        name: r'commentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CommentsProvider call(String postId) =>
      CommentsProvider._(argument: postId, from: this);

  @override
  String toString() => r'commentsProvider';
}

abstract class _$Comments extends $AsyncNotifier<CommentListResult> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  FutureOr<CommentListResult> build(String postId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CommentListResult>, CommentListResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CommentListResult>, CommentListResult>,
              AsyncValue<CommentListResult>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(AddCommentAction)
final addCommentActionProvider = AddCommentActionProvider._();

final class AddCommentActionProvider
    extends $AsyncNotifierProvider<AddCommentAction, void> {
  AddCommentActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addCommentActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addCommentActionHash();

  @$internal
  @override
  AddCommentAction create() => AddCommentAction();
}

String _$addCommentActionHash() => r'dd94d509f768d601ed3d027b3e9d6cfc01f5b3cb';

abstract class _$AddCommentAction extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
