import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final VoidCallback? onFilterPressed;
  final bool showFilterButton;
  final List<String>? suggestions;
  final ValueChanged<String>? onSuggestionSelected;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Tìm kiếm...',
    this.onFilterPressed,
    this.showFilterButton = true,
    this.suggestions,
    this.onSuggestionSelected,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? AppTheme.primaryLight
                  : (isDark ? AppTheme.dividerDark : AppTheme.dividerLight),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryLight.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: _isFocused
                    ? AppTheme.primaryLight
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.controller.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged?.call('');
                        HapticFeedback.lightImpact();
                      },
                    ),
                  if (widget.showFilterButton)
                    IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      onPressed: () {
                        widget.onFilterPressed?.call();
                        HapticFeedback.lightImpact();
                      },
                    ),
                ],
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: theme.textTheme.bodyLarge,
          ),
        ),
        if (widget.suggestions != null &&
            widget.suggestions!.isNotEmpty &&
            _isFocused)
          _buildSuggestions(context, theme),
      ],
    );
  }

  Widget _buildSuggestions(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: widget.suggestions!.map((suggestion) {
          return ListTile(
            leading: Icon(
              Icons.history_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            title: Text(
              suggestion,
              style: theme.textTheme.bodyMedium,
            ),
            onTap: () {
              widget.controller.text = suggestion;
              widget.onSuggestionSelected?.call(suggestion);
              _focusNode.unfocus();
            },
          );
        }).toList(),
      ),
    );
  }
}
