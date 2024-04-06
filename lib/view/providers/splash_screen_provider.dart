// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:drive_ease_main/view/core/appcolors.dart';
import 'package:drive_ease_main/view/providers/firebase_auth_provider.dart';
import 'package:drive_ease_main/viewModel/utils_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SplashScreenProvider extends ChangeNotifier {
  //handling the navigations for the splash screen
  Future<String> navigationHandler(BuildContext context) async {
    final util = Provider.of<UtilsProvider>(context, listen: false);
    final onBoard = await util.checkOnBoardingStatus();
    if (!onBoard) {
      return 'notOnBoarded';
    } else {
      final isSigned = await util.checkSignInStatus();
      if (!isSigned) {
        return 'notSigned';
      } else {
        final loggedIn = await util.checkLoginStatus(context);
        log(loggedIn.toString());
        if (!loggedIn) {
          return 'notloggedIn';
        } else {
          final auth =
              Provider.of<FirebaseAuthProvider>(context, listen: false);
          auth.fetchDataFromFireStore(context);
          return 'home';
        }
      }
    }
  }

  //error screen
  Widget buildErrorScreen() {
    return Container();
  }

  //splashScreen
  Widget buildSplashScreen() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50.h,
                width: 100.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(
                          'assets/images/new_splash-removebg-preview.png')),
                ),
              ),
              DefaultTextStyle(
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade200),
                  child: AnimatedTextKit(animatedTexts: [
                    WavyAnimatedText('Welcome to Drive Ease'),
                  ]))
            ],
          ),
        ),
      ),
    );
  }
}
