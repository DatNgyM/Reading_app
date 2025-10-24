import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/reading_item.dart';
import '../utils/app_theme.dart';

class ReadingCard extends StatelessWidget {
  final ReadingItem reading;
  final VoidCallback? onTap;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;
  final bool showProgress;
  final bool isCompact;

  const ReadingCard({
    super.key,
    required this.reading,
    this.onTap,
    this.onBookmark,
    this.onShare,
    this.showProgress = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isCompact) {
      return _buildCompactCard(context, theme, isDark);
    }

    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppTheme.shadowDark.withOpacity(0.1)
                        : AppTheme.shadowLight.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, isDark),
                  _buildContent(context, theme),
                  if (showProgress) _buildProgress(context, theme),
                  _buildFooter(context, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildCompactThumbnail(context, theme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reading.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reading.author,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.access_time_rounded,
                        '${reading.readingTime} phút',
                        theme,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        Icons.category_rounded,
                        reading.category,
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (reading.isBookmarked)
              Icon(
                Icons.bookmark_rounded,
                color: AppTheme.primaryLight,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.primaryDark.withOpacity(0.1),
                  AppTheme.secondaryDark.withOpacity(0.1)
                ]
              : [
                  AppTheme.primaryLight.withOpacity(0.1),
                  AppTheme.secondaryLight.withOpacity(0.1)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryLight.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    reading.category,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  reading.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  reading.author,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              if (reading.isBookmarked)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bookmark_rounded,
                    color: AppTheme.primaryLight,
                    size: 20,
                  ),
                ),
              const SizedBox(height: 8),
              _buildDifficultyBadge(context, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reading.description.isNotEmpty) ...[
            Text(
              reading.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              _buildInfoChip(
                context,
                Icons.access_time_rounded,
                '${reading.readingTime} phút',
                theme,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                context,
                Icons.visibility_rounded,
                '${reading.viewCount} lượt xem',
                theme,
              ),
              if (reading.rating > 0) ...[
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  Icons.star_rounded,
                  reading.rating.toStringAsFixed(1),
                  theme,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ đọc',
                style: theme.textTheme.labelMedium,
              ),
              Text(
                '${(reading.progress * 100).toInt()}%',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: reading.progress,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onBookmark,
              icon: Icon(
                reading.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                size: 18,
              ),
              label: Text(reading.isBookmarked ? 'Đã lưu' : 'Lưu'),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    reading.isBookmarked ? AppTheme.primaryLight : null,
                side: BorderSide(
                  color: reading.isBookmarked
                      ? AppTheme.primaryLight
                      : theme.colorScheme.outline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('Đọc ngay'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactThumbnail(BuildContext context, ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.book_rounded,
        color: AppTheme.primaryLight,
        size: 24,
      ),
    );
  }

  Widget _buildDifficultyBadge(BuildContext context, ThemeData theme) {
    Color color;
    switch (reading.difficulty) {
      case 'Easy':
        color = Colors.green;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Hard':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        reading.difficulty,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context, IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
