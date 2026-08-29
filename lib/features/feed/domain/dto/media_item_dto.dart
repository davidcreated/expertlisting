import 'package:json_annotation/json_annotation.dart';

import '../media_item.dart';

part 'media_item_dto.g.dart';

@JsonSerializable(createToJson: false)
class MediaItemDto {
  const MediaItemDto({
    required this.id,
    required this.url,
    this.kind,
    this.aspectRatio,
  });

  factory MediaItemDto.fromJson(Map<String, dynamic> json) =>
      _$MediaItemDtoFromJson(json);

  final String id;
  final String url;
  final String? kind;
  final num? aspectRatio;

  MediaItem toEntity() => MediaItem(
    id: id,
    url: url,
    kind: MediaKind.fromWire(kind),
    aspectRatio: (aspectRatio ?? 1).toDouble(),
  );
}
