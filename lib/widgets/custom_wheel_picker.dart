import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomWheelPicker extends StatelessWidget {
  final String label;
  final List<int> values;
  final int initialIndex;
  final Function(int) onSelectedItemChanged;
  final String? prefix;
  final String? suffix;

  const CustomWheelPicker({
    super.key,
    required this.label,
    required this.values,
    required this.initialIndex,
    required this.onSelectedItemChanged,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: initialIndex,
              ),
              itemExtent: 50,
              looping: false,
              selectionOverlay: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 50,
                child: DecoratedBox(
                  // decoration: BoxDecoration(
                  //   color: Colors.white.withValues(alpha: 0.12),
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                  decoration: ShapeDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              onSelectedItemChanged: (index) {
                HapticFeedback.vibrate();
                onSelectedItemChanged(index);
              },
              children: [
                for (int value in values)
                  Center(
                    child: Text(
                      '${prefix ?? ''}$value${suffix ?? ''}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
