// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:drive_ease_main/view/core/appcolors.dart';
import 'package:drive_ease_main/view/screens/register_screen.dart';
import 'package:drive_ease_main/viewModel/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/widgets.dart';

class ScreenOnBoarding extends StatelessWidget {
  const ScreenOnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent),
      child: Scaffold(
        body: Stack(
          children: [image(), onboardingText(), button(context)],
        ),
      ),
    );
  }

  Positioned button(BuildContext context) {
    return Positioned(
      left: Adaptive.w(25.5),
      bottom: Adaptive.h(7),
      child: InkWell(
        onTap: () async {
          ('onBoard button pressed');
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('onBoard', true);
          log('set onBoarding status completed');
          Navigator.pushReplacement(
              context, CustomPageTransition(page: const ScreenRegister()));
        },
        child: Container(
          width: 50.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: AppColors.buttonColor, // Greyish color
            borderRadius: BorderRadius.circular(12), // Rounded corners
            boxShadow: const [
              BoxShadow(
                color: AppColors.buttonSpreadColor, // Shadow color
                offset: Offset(0, 4), // Offset in X and Y direction
                blurRadius: 4, // Spread of the shadow
                spreadRadius: 0.5, // Size of the shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started',
                style: textStyle(
                    size: 25, color: Colors.white, thickness: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Positioned onboardingText() {
    return Positioned(
      top: Adaptive.h(7),
      left: Adaptive.w(6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
                text: "Find and \nRent a car in \nEasy Steps.",
                style: TextStyle(
                  foreground: Paint()..shader = AppColors.gradientShader,
                ))
          ],
        ),
      ),
    );
  }

  Container image() {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/onboarding.jpg'),
              fit: BoxFit.cover)),
    );
  }
}
