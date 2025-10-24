import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../models/reading_item.dart';
import '../utils/app_theme.dart';
import '../providers/theme_provider.dart';

class ReadingScreen extends StatefulWidget {
  final ReadingItem reading;

  const ReadingScreen({super.key, required this.reading});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with TickerProviderStateMixin {
  bool _isCompleted = false;
  double _fontSize = 16.0;
  bool _isDarkMode = false;
  double _progress = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.reading.isCompleted;
    _progress = widget.reading.progress;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
      _progress = _isCompleted ? 1.0 : 0.0;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isCompleted ? 'Đã hoàn thành!' : 'Đã hủy hoàn thành'),
        backgroundColor: AppTheme.primaryLight,
      ),
    );
  }

  void _showFontSizeDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cỡ chữ',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Text('Cỡ chữ: ${_fontSize.toInt()}'),
                    Slider(
                      value: _fontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      onChanged: (value) {
                        setState(() {
                          _fontSize = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _fontSize = 14.0;
                            });
                          },
                          child: const Text('Nhỏ'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _fontSize = 16.0;
                            });
                          },
                          child: const Text('Vừa'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _fontSize = 18.0;
                            });
                          },
                          child: const Text('Lớn'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDarkMode
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
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryLight.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  widget.reading.category,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _isCompleted ? AppTheme.primaryLight : Colors.grey,
                ),
                onPressed: _toggleCompletion,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.reading.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.reading.author,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.access_time_rounded,
                '${widget.reading.readingTime} phút',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.speed_rounded,
                widget.reading.difficulty,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.visibility_rounded,
                '${widget.reading.viewCount} lượt xem',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ đọc',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${(_progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryLight,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor:
                Theme.of(context).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildReadingContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.reading.description.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryLight.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    widget.reading.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                widget.reading.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: _fontSize,
                      height: 1.8,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            Icons.bookmark_border_rounded,
            'Lưu',
            () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã thêm vào bookmark')),
              );
            },
          ),
          _buildActionButton(
            Icons.note_add_rounded,
            'Ghi chú',
            () {
              _showNoteDialog();
            },
          ),
          _buildActionButton(
            Icons.highlight_rounded,
            'Highlight',
            () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Tính năng highlight đang phát triển')),
              );
            },
          ),
          _buildActionButton(
            Icons.volume_up_rounded,
            'Đọc to',
            () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Tính năng đọc to đang phát triển')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 20, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog() {
    final TextEditingController noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thêm ghi chú',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Nhập ghi chú của bạn...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu ghi chú')),
                        );
                      },
                      child: const Text('Lưu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.reading.title,
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              // Toggle theme globally
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
              HapticFeedback.lightImpact();
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            onPressed: _showFontSizeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã chia sẻ bài đọc')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildReadingHeader(),
          _buildProgressIndicator(),
          _buildReadingContent(),
          _buildBottomActions(),
        ],
      ),
    );
  }
}
