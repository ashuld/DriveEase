import 'package:drive_ease_main/view/core/app_router_const.dart';
import 'package:drive_ease_main/view/screens/onboarding.dart';
import 'package:drive_ease_main/view/screens/register_screen.dart';
import 'package:drive_ease_main/view/screens/screen_home.dart';
import 'package:drive_ease_main/view/screens/screen_otp_verifcation.dart';
import 'package:drive_ease_main/view/screens/screen_splash.dart';
import 'package:drive_ease_main/view/screens/screen_login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MyAppRouter {
  final GoRouter router = GoRouter(initialLocation: '/', routes: [
    GoRoute(
      name: MyAppRouterConstants.splashPage,
      path: '/',
      pageBuilder: (context, state) => MaterialPage(
          child: ResponsiveSizer(
        builder: (context, orientation, screenType) => const ScreenSplash(),
      )),
    ),
    GoRoute(
      name: MyAppRouterConstants.onBoardPage,
      path: '/onBoard',
      pageBuilder: (context, state) => MaterialPage(
          child: ResponsiveSizer(
        builder: (context, orientation, screenType) => const ScreenOnBoarding(),
      )),
    ),
    GoRoute(
      name: MyAppRouterConstants.loginPage,
      path: '/login',
      pageBuilder: (context, state) => MaterialPage(
          child: ResponsiveSizer(
        builder: (context, orientation, screenType) => const ScreenLogin(),
      )),
    ),
    GoRoute(
        name: MyAppRouterConstants.otpPage,
        path: '/otpPage/:phoneNo/:isFromRegistration/:name',
        pageBuilder: (context, state) {
          final String? phoneNo = state.pathParameters['phoneNo'];
          final String? isRegistration =
              state.pathParameters['isFromRegistration'];
          final String? name = state.pathParameters['name'];
          final bool isFromRegistration = isRegistration == 'true';
          return MaterialPage(
              child: ResponsiveSizer(
            builder: (context, orientation, screenType) =>
                ScreenOtpVerification(
              phoneNo: phoneNo!,
              isFromRegistration: isFromRegistration,
              name: name,
            ),
          ));
        }),
    GoRoute(
      name: MyAppRouterConstants.registerPage,
      path: '/register',
      pageBuilder: (context, state) => MaterialPage(
          child: ResponsiveSizer(
        builder: (context, orientation, screenType) => const ScreenRegister(),
      )),
    ),
    GoRoute(
      name: MyAppRouterConstants.homePage,
      path: '/home',
      pageBuilder: (context, state) => MaterialPage(
          child: ResponsiveSizer(
        builder: (context, orientation, screenType) => const ScreenHome(),
      )),
    )
  ]);
}
