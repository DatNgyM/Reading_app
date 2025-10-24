import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/reading_card.dart';
import '../widgets/animated_widgets.dart';
import '../data/sample_data.dart';
import '../models/reading_item.dart';
import '../utils/app_theme.dart';
import 'reading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<ReadingItem> _allReadings = [];
  List<ReadingItem> _filteredReadings = [];
  String _selectedCategory = 'Tất cả';
  String _selectedDifficulty = 'Tất cả';
  bool _isLoading = true;
  late AnimationController _animationController;

  final List<String> _categories = SampleData.getCategories();
  final List<String> _difficulties = SampleData.getDifficulties();
  final List<String> _suggestions = SampleData.getSearchSuggestions();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _allReadings = SampleData.getAllReadings();
      _filteredReadings = _allReadings;
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _filterReadings() {
    setState(() {
      _filteredReadings = _allReadings.where((reading) {
        final matchesSearch = _searchController.text.isEmpty ||
            reading.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            reading.content
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            reading.author
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            reading.tags.any((tag) => tag
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()));

        final matchesCategory = _selectedCategory == 'Tất cả' ||
            reading.category == _selectedCategory;

        final matchesDifficulty = _selectedDifficulty == 'Tất cả' ||
            reading.difficulty == _selectedDifficulty;

        return matchesSearch && matchesCategory && matchesDifficulty;
      }).toList();
    });
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            onChanged: (value) => _filterReadings(),
            onSubmitted: (value) => _filterReadings(),
            hintText: 'Tìm kiếm bài đọc, tác giả...',
            onFilterPressed: _showFilterDialog,
            suggestions: _suggestions,
            onSuggestionSelected: (suggestion) {
              _searchController.text = suggestion;
              _filterReadings();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'Danh mục',
                  _selectedCategory,
                  Icons.category_rounded,
                  () => _showCategoryDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  'Độ khó',
                  _selectedDifficulty,
                  Icons.speed_rounded,
                  () => _showDifficultyDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryLight),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Kết quả tìm kiếm',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '${_filteredReadings.length} bài đọc',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Không tìm thấy bài đọc nào',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thử tìm kiếm với từ khóa khác hoặc điều chỉnh bộ lọc',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _selectedCategory = 'Tất cả';
                _selectedDifficulty = 'Tất cả';
                _filterReadings();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Làm mới'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: CustomShimmer(
              width: double.infinity,
              height: 100,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      );
    }

    if (_filteredReadings.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedListView(
      children: _filteredReadings.map((reading) {
        return ReadingCard(
          reading: reading,
          isCompact: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadingScreen(reading: reading),
              ),
            );
          },
          onBookmark: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(reading.isBookmarked ? 'Đã bỏ lưu' : 'Đã lưu bài đọc'),
                backgroundColor: AppTheme.primaryLight,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  void _showCategoryDialog() {
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
              'Chọn danh mục',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ..._categories.map((category) {
              return ListTile(
                title: Text(category),
                leading: Radio<String>(
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    Navigator.pop(context);
                    _filterReadings();
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                  Navigator.pop(context);
                  _filterReadings();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showDifficultyDialog() {
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
              'Chọn độ khó',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ..._difficulties.map((difficulty) {
              return ListTile(
                title: Text(difficulty),
                leading: Radio<String>(
                  value: difficulty,
                  groupValue: _selectedDifficulty,
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value!;
                    });
                    Navigator.pop(context);
                    _filterReadings();
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedDifficulty = difficulty;
                  });
                  Navigator.pop(context);
                  _filterReadings();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
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
              'Bộ lọc',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Danh mục'),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(labelText: 'Độ khó'),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            const SizedBox(height: 24),
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
                      _filterReadings();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tìm kiếm',
        showBackButton: false,
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildResultsHeader(),
          const SizedBox(height: 16),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }
}
