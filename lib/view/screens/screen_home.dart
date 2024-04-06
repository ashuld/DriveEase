import 'package:drive_ease_main/view/core/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ScreenHome extends StatelessWidget {
  const ScreenHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: 100.h,
      width: 100.w,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: const Center(
        child: Text(
          'HomePage',
          style: TextStyle(color: Colors.amber),
        ),
      ),
    ));
  }
}
