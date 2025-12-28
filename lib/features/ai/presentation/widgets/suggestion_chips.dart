import 'package:flutter/material.dart';
import 'package:darna/core/theme/app_theme.dart';

class SuggestionChips extends StatelessWidget {
  final Function(String) onSuggestionSelected;

  const SuggestionChips({
    super.key,
    required this.onSuggestionSelected,
  });

  final List<String> _suggestions = const [
    "What's popular today?",
    "Vegetarian options?",
    "Spicy dishes?",
    "Tell me about Tagines",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(_suggestions[index]),
              onPressed: () => onSuggestionSelected(_suggestions[index]),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelStyle: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}
