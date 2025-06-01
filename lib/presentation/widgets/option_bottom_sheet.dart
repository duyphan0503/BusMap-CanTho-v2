import 'package:flutter/material.dart';

class OptionBottomSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> optionLabels;
  final Color activeColor;
  final String confirmText;
  final String selectLabel;
  final void Function(int selectedIndex) onConfirm;

  const OptionBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.optionLabels,
    required this.activeColor,
    required this.confirmText,
    required this.onConfirm,
    required this.selectLabel,
  });

  @override
  State<OptionBottomSheet> createState() => _OptionBottomSheetState();
}

class _OptionBottomSheetState extends State<OptionBottomSheet> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, size: 16, color: Colors.yellow),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.subtitle,
                    textAlign: TextAlign.left,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.selectLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(context).dividerColor,
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.optionLabels.length,
              separatorBuilder:
                  (_, __) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Theme.of(context).dividerColor,
                  ),
              itemBuilder: (context, idx) {
                return RadioListTile<int>(
                  value: idx,
                  groupValue: _selectedIndex,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(widget.optionLabels[idx]),
                  activeColor: widget.activeColor,
                  selected: _selectedIndex == idx,
                  selectedTileColor: widget.activeColor.withAlpha(40),
                  tileColor: Theme.of(context).cardColor,
                  onChanged: (val) => setState(() => _selectedIndex = val!),
                );
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.activeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onConfirm(_selectedIndex);
                },
                child: Text(widget.confirmText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}