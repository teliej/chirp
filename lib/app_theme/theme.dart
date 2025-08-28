import 'package:flutter/material.dart';
import 'custom_colors.dart';
import 'app_color.dart';


class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      // background: AppColors.darkAccent,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      ),

      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      ),

      bodySmall: TextStyle(
        color: AppColors.textSecondary,
        overflow: TextOverflow.ellipsis,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.searchBackground,
    ),
    hintColor: AppColors.textSecondary,
    extensions: const [
      CustomColors(
        chatBackground: AppColors.chatBackground,
        bubbleIncoming: AppColors.bubbleIncoming,
        bubbleOutgoing: AppColors.bubbleOutgoing,
        incomingTimeStamp: AppColors.incomingtimeStamp,
        outgoingTimeStamp: AppColors.outgoingtimeStamp,
        header: AppColors.header,
      ),
    ],
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppDarkColors.background,
    primaryColor: AppDarkColors.primary,
    colorScheme: ColorScheme.dark(
      primary: AppDarkColors.primary,
      secondary: AppDarkColors.accent,
      // background: AppDarkColors.background,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppDarkColors.textPrimary, 
        fontSize: 16,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,),

      bodyMedium: TextStyle(
        color: AppDarkColors.textSecondary, 
        fontSize: 14,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,),

      bodySmall: TextStyle(
        color: AppDarkColors.textSecondary,
        overflow: TextOverflow.ellipsis,),

    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppDarkColors.searchBackground,

    ),
    hintColor: AppDarkColors.textSecondary,
    extensions: const [
      CustomColors(
        chatBackground: AppDarkColors.chatBackground,
        bubbleIncoming: AppDarkColors.bubbleIncoming,
        bubbleOutgoing: AppDarkColors.bubbleOutgoing,
        incomingTimeStamp: AppDarkColors.incomingtimeStamp,
        outgoingTimeStamp: AppDarkColors.outgoingtimeStamp,
        header: AppDarkColors.header,
      ),
    ],
  );
}
