import 'package:flutter/widgets.dart';

import '../../features/feed/domain/author.dart';
import '../theme/theme_extensions.dart';
import 'app_avatar.dart';

class AppAvatarStack extends StatelessWidget {
  const AppAvatarStack({
    required this.authors,
    this.size = 20,
    this.maxVisible = 3,
    this.overlap = 6,
    super.key,
  });

  final List<Author> authors;
  final double size;
  final int maxVisible;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    if (authors.isEmpty) return const SizedBox.shrink();

    final visible = authors.take(maxVisible).toList();
    final step = size - overlap;
    final width = size + step * (visible.length - 1);

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: [
          for (var index = visible.length - 1; index >= 0; index--)
            Positioned(
              left: index * step,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.color.surface, width: 1.5),
                ),
                child: AppAvatar(
                  size: size,
                  imageUrl: visible[index].avatarUrl,
                  initials: visible[index].initials,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
