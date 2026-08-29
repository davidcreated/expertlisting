import 'package:equatable/equatable.dart';

enum MediaKind {
  image('IMAGE'),
  video('VIDEO');

  const MediaKind(this.wire);

  final String wire;

  static MediaKind fromWire(String? value) {
    if (value == null) return MediaKind.image;
    final normalized = value.trim().toUpperCase();
    for (final kind in values) {
      if (kind.wire == normalized) return kind;
    }
    return MediaKind.image;
  }
}

class MediaItem extends Equatable {
  const MediaItem({
    required this.id,
    required this.url,
    this.kind = MediaKind.image,
    this.aspectRatio = 1,
    this.localPath,
  });

  final String id;
  final String url;
  final MediaKind kind;
  final double aspectRatio;
  final String? localPath;

  bool get isVideo => kind == MediaKind.video;

  bool get isLocal => localPath != null;

  @override
  List<Object?> get props => [id, url, kind, aspectRatio, localPath];
}
