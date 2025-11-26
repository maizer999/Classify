import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class CategoryHomeCard extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onTap;
  const CategoryHomeCard({
    super.key,
    required this.title,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🚨 FIX 1: Removed the conflicting SizedBox(width: 70).
    // The GridView now correctly determines the card's size.
    return GestureDetector(
      onTap: onTap,
      child: Column(
        // Note: 'spacing' is not a standard Column property.
        // We structure the children to manage space explicitly.
        // The children list handles the vertical sizing.
        children: [
          // 🚨 FIX 2: Wrapped the main visual element in Expanded.
          // This ensures the image container takes all available height,
          // *after* the text box has been sized to its content,
          // which is the key to preventing overflow in a Column inside a constrained grid cell.
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColoredBox(
                color: context.color.secondaryColor,
                // AspectRatio 1 ensures the image itself is square within its space.
                child: AspectRatio(
                  aspectRatio: 1,
                  child: UiUtils.imageType(url, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          // Added a small, explicit vertical spacer between the image and the text.
          const SizedBox(height: 4),



          // 🚨 FIX 3: Removed the Expanded around CustomText.
          // Text should take only the height it needs. The image container (Expanded above)
          // will take the rest, guaranteeing no overflow.
          CustomText(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            fontSize: context.font.smaller,
            color: context.color.textDefaultColor.withValues(alpha: .7),
          ),
        ],
      ),
    );
  }
}