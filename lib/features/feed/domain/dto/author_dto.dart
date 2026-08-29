import 'package:json_annotation/json_annotation.dart';

import '../author.dart';

part 'author_dto.g.dart';

@JsonSerializable(createToJson: false)
class AuthorDto {
  const AuthorDto({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.role,
  });

  factory AuthorDto.fromJson(Map<String, dynamic> json) =>
      _$AuthorDtoFromJson(json);

  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? role;

  Author toEntity() => Author(
    id: id,
    name: name,
    username: username,
    avatarUrl: avatarUrl,
    role: AuthorRole.fromWire(role),
  );
}
