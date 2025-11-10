import 'dart:math';
import 'package:eClassify/app/app_theme.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/ui/screens/home/widgets/category_home_card.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryWidgetHome extends StatelessWidget {
  const CategoryWidgetHome({super.key});

  final int maxLimit = 10;

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
      builder: (context, state) {
        if (state is FetchCategorySuccess && state.categories.isNotEmpty) {
          final length = min(state.categories.length, maxLimit);
          final showMoreCategory = length >= maxLimit;

          final displayCategories = List.from(state.categories.take(length));
          if (showMoreCategory) displayCategories.add(null);

          return Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(

              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemCount: displayCategories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1, // square-ish cards
              ),
              itemBuilder: (context, index) {
                final category = displayCategories[index];
                if (category == null) {
                  return moreCategory(context);
                }
                return CategoryHomeCard(
                  title: category.name!,
                  url: category.url!,
                  onTap: () {
                    if (category.children!.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        Routes.subCategoryScreen,
                        arguments: {
                          "categoryList": category.children,
                          "catName": category.name,
                          "catId": category.id,
                          "categoryIds": [category.id.toString()],
                        },
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        Routes.itemsList,
                        arguments: {
                          'catID': category.id.toString(),
                          'catName': category.name,
                          "categoryIds": [category.id.toString()],
                        },
                      );
                    }
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget moreCategory(BuildContext context) {
    // LayoutBuilder is no longer necessary here. The GridView is the constraint.
    // The previous 'cardWidth' variable is also unused.

    return BlocBuilder<AppThemeCubit, AppTheme>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.categories,
              arguments: {"from": Routes.home},
            ).then((dynamic value) {
              if (value != null) selectedCategory = value;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                // *** FIX APPLIED HERE: Wrapped container in Expanded ***
                Expanded(
                  child: Container(
                    // Removed fixed height! It now expands to fill remaining space.
                    width: double.infinity, // Use all available width
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: context.color.textLightColor.withValues(alpha: 0.33),
                        width: 1,
                      ),
                      color: context.color.secondaryColor,
                    ),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: UiUtils.getSvg(
                        AppIcons.more,
                        color: context.color.territoryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Text remains sized to its content, and the Container takes the rest.
                CustomText(
                  "more".translate(context),
                  textAlign: TextAlign.center,
                  fontSize: context.font.smaller,
                  color: context.color.textDefaultColor.withValues(alpha: .7),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}