import 'package:equatable/equatable.dart';

enum AuthorRole {
  developer('DEVELOPER'),
  broker('BROKER'),
  agent('AGENT');

  const AuthorRole(this.wire);

  final String wire;

  static AuthorRole? fromWire(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    for (final role in values) {
      if (role.wire == normalized) return role;
    }
    return null;
  }

  String get label => switch (this) {
    AuthorRole.developer => 'Developer',
    AuthorRole.broker => 'Broker',
    AuthorRole.agent => 'Agent',
  };
}

class Author extends Equatable {
  const Author({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.role,
  });

  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final AuthorRole? role;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = _firstLetter(parts.first);
    if (parts.length == 1) return first;
    return '$first${_firstLetter(parts.last)}';
  }

  static String _firstLetter(String value) =>
      String.fromCharCode(value.runes.first).toUpperCase();

  Author copyWith({
    String? id,
    String? name,
    String? username,
    String? Function()? avatarUrl,
    AuthorRole? Function()? role,
  }) {
    return Author(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
      role: role != null ? role() : this.role,
    );
  }

  @override
  List<Object?> get props => [id, name, username, avatarUrl, role];
}
