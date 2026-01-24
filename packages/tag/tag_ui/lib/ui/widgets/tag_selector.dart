import 'package:flutter/material.dart';
import 'package:tag_shared/tag_shared.dart';

/// A multi-select tag selector widget.
///
/// Displays available tags as chips and allows users to select/deselect them.
class TagSelector extends StatefulWidget {
  final List<TagDetails> availableTags;
  final List<TagDetails> selectedTags;
  final ValueChanged<List<TagDetails>> onChanged;

  const TagSelector({
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
    super.key,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  late List<TagDetails> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedTags);
  }

  @override
  void didUpdateWidget(TagSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTags != oldWidget.selectedTags) {
      _selected = List.from(widget.selectedTags);
    }
  }

  void _toggleTag(TagDetails tag) {
    setState(() {
      if (_selected.any((t) => t.id == tag.id)) {
        _selected.removeWhere((t) => t.id == tag.id);
      } else {
        _selected.add(tag);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.availableTags.map((tag) {
        final isSelected = _selected.any((t) => t.id == tag.id);

        return FilterChip(
          label: Text(tag.name),
          selected: isSelected,
          onSelected: (_) => _toggleTag(tag),
          avatar: isSelected ? const Icon(Icons.check, size: 18) : null,
        );
      }).toList(),
    );
  }
}
