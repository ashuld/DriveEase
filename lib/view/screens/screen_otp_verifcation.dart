import 'package:drive_ease_main/model/user_model.dart';
import 'package:drive_ease_main/view/core/app_router_const.dart';
import 'package:drive_ease_main/view/providers/connectivity_provider.dart';
import 'package:drive_ease_main/view/providers/firebase_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../core/appcolors.dart';
import '../widgets/network_error.dart';
import '../widgets/widgets.dart';

class ScreenOtpVerification extends StatefulWidget {
  final String phoneNo;
  final bool isFromRegistration;
  final String? name;
  const ScreenOtpVerification(
      {super.key,
      required this.phoneNo,
      this.name,
      required this.isFromRegistration});

  @override
  State<ScreenOtpVerification> createState() => _ScreenOtpVerificationState();
}

class _ScreenOtpVerificationState extends State<ScreenOtpVerification> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 52,
      textStyle: const TextStyle(
          fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: AppColors.formFieldFilled.withOpacity(0.3),
        border: Border.all(
            color: AppColors.formFieldEnabledBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(9),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.buttonSpreadColor.withOpacity(0.5)),
      borderRadius: BorderRadius.circular(10),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromARGB(179, 226, 224, 224),
      ),
    );
    return Scaffold(
      body: Container(
        height: 100.h,
        width: 100.w,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                backButton(context),
                const SizedBox(height: 30),
                otpHead(),
                displayMsg(),
                SizedBox(height: 6.5.h),
                otpField(otpController, defaultPinTheme, focusedPinTheme,
                    submittedPinTheme),
                SizedBox(height: 10.h),
                Consumer<ConnectivityProvider>(
                    builder: (context, connectivity, child) {
                  return InkWell(
                    onTap: () {
                      final otp = otpController.text;
                      if (otp.length != 6) {
                        showSnackBar(
                            context: context,
                            message: 'Please enter a valid OTP');
                      } else {
                        if (!connectivity.isDeviceConnected) {
                          networkDialog(context);
                        } else {
                          final auth = Provider.of<FirebaseAuthProvider>(
                              context,
                              listen: false);
                          if (widget.isFromRegistration) {
                            final userData = UserModel(
                                name: widget.name!,
                                phoneNumber: widget.phoneNo);
                            auth.verifyOTPSignIn(
                                context: context, otp: otp, userData: userData);
                          } else {
                            auth.verifyOTPLogIn(context: context, otp: otp);
                          }
                        }
                      }
                    },
                    child: Container(
                      width: 40.w,
                      height: 6.2.h,
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor, // Greyish color
                        borderRadius:
                            BorderRadius.circular(8), // Rounded corners
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
                            'Verify',
                            style: textStyle(
                                size: 25,
                                color: Colors.white,
                                thickness: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 18),
                resendOtp(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding resendOtp(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: Adaptive.w(18.8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Didn’t received code? ',
              style: textStyle(
                size: 17,
                color: AppColors.textColor,
              )),
          InkWell(
            onTap: () {
              final auth =
                  Provider.of<FirebaseAuthProvider>(context, listen: false);
              auth.resendOtp(context, widget.phoneNo);
            },
            child: Text('Resend ',
                style: textStyle(
                  size: 17,
                  color: AppColors.linkColor,
                )),
          )
        ],
      ),
    );
  }

  Padding otpField(
      TextEditingController otpController,
      PinTheme defaultPinTheme,
      PinTheme focusedPinTheme,
      PinTheme submittedPinTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Adaptive.w(5)),
      child: Center(
        child: Pinput(
          obscureText: true,
          obscuringCharacter: '℗',
          controller: otpController,
          length: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          keyboardType: TextInputType.number,
          separatorBuilder: (index) => const SizedBox(width: 5),
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          showCursor: true,
        ),
      ),
    );
  }

  Padding displayMsg() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Adaptive.w(5), 5, Adaptive.w(5), 0),
      child: SizedBox(
          width: Adaptive.w(100),
          child: Text(
            textAlign: TextAlign.center,
            'Enter the verification code we just sent on your Number ${widget.phoneNo}',
            style: textStyle(size: 15, thickness: FontWeight.w600),
          )),
    );
  }

  Padding otpHead() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Adaptive.w(5), 0, 0, 0),
      child: Text('OTP Verification',
          style: textStyle(
              color: AppColors.textColor,
              size: 30,
              thickness: FontWeight.bold)),
    );
  }

  InkWell backButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.isFromRegistration) {
          GoRouter.of(context)
              .pushReplacementNamed(MyAppRouterConstants.registerPage);
        } else {
          GoRouter.of(context)
              .pushReplacementNamed(MyAppRouterConstants.loginPage);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(Adaptive.w(5), Adaptive.h(5), 0, 0),
            child: Container(
                height: Adaptive.h(6.25),
                width: Adaptive.w(13.88),
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.buttonSpreadColor, // Shadow color
                        offset: Offset(0, 4), // Offset in X and Y direction
                        blurRadius: 4, // Spread of the shadow
                        spreadRadius: 0.5, // Size of the shadow
                      ),
                    ],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.buttonColor),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 24,
                    color: AppColors.textColor,
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
