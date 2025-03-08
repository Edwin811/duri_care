import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

abstract class AppThemes {
  static ColorScheme appColorScheme(ColorScheme colorScheme) => colorScheme
      .copyWith(surface: AppColor.white, primary: AppColor.greenPrimary);

  static FilledButtonThemeData filledButtonThemeData(BuildContext context) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          fixedSize: const Size.fromHeight(48),
          textStyle: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  static OutlinedButtonThemeData outlinedButtonThemeData(
    BuildContext context,
  ) => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      fixedSize: const Size.fromHeight(48),
      textStyle: context.textTheme.bodyLarge!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(color: AppColor.greenPrimary),
    ),
  );

  static InputDecorationTheme inputDecorationTheme(
    BuildContext context,
    ColorScheme colorScheme,
  ) => InputDecorationTheme(
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    filled: true,
    fillColor: colorScheme.surface,
    hintStyle: context.textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.w400,
      color: Color(0xFF8897AD),
    ),
  );

  static TextTheme textTheme(BuildContext context, ColorScheme colorScheme) =>
      TextTheme(
        displayLarge: context.textTheme.displayLarge!.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: context.textTheme.displayMedium!.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: context.textTheme.displaySmall!.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: context.textTheme.titleLarge!.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: context.textTheme.titleMedium!.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: context.textTheme.titleSmall!.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: context.textTheme.bodyLarge!.copyWith(
          color: colorScheme.onSurface,
        ),
        bodyMedium: context.textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurface,
        ),
        bodySmall: context.textTheme.bodySmall!.copyWith(
          color: colorScheme.onSurface,
        ),
        labelLarge: context.textTheme.labelLarge!.copyWith(
          color: colorScheme.onSurface,
        ),
        labelMedium: context.textTheme.labelMedium!.copyWith(
          color: colorScheme.onSurface,
        ),
        labelSmall: context.textTheme.labelSmall!.copyWith(
          color: colorScheme.onSurface,
        ),
      );
}
