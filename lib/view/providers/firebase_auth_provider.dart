// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:drive_ease_main/model/user_model.dart';
import 'package:drive_ease_main/view/core/app_router_const.dart';
import 'package:drive_ease_main/view/widgets/widgets.dart';
import 'package:drive_ease_main/viewModel/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthProvider extends ChangeNotifier {
  String? _uid;
  String? _verificationId;

  String? get uid => _uid;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  // final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //------------------SignUP Procedure---------------------//
  Future<void> verifyPhoneNumberSignIn(
      {required BuildContext context,
      required String phoneNumber,
      required String name}) async {
    try {
      loadingDialog(context);
      final userSnapShot = await _fireStore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .get();
      if (userSnapShot.docs.isNotEmpty) {
        context.pop();
        showSnackBar(
            context: context,
            message:
                'Phone Number Already Registered! Please go to Login Page');
      } else {
        await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (phoneAuthCredential) async {
            await _auth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            context.pop();
            log('Verification Error:${error.toString()}');
            showSnackBar(
                context: context,
                message:
                    'Something Happened! Please Try Again After few Minutes');
          },
          codeSent: (verificationId, forceResendingToken) {
            _verificationId = verificationId;
            log('.....code sent successfully');
            context.pop();
            GoRouter.of(context).pushReplacementNamed(
                MyAppRouterConstants.otpPage,
                pathParameters: {
                  'phoneNo': phoneNumber,
                  'isFromRegistration': true.toString(),
                  'name': name
                });
          },
          codeAutoRetrievalTimeout: (verificationId) =>
              log('code REtrieval TimedOUt'),
        );
      }
    } catch (e) {
      context.pop();
      log(e.toString());
      showSnackBar(
          context: context,
          message: "Something Happened! Please Try Again After few Minutes");
    }
  }

  Future<void> verifyOTPSignIn(
      {required BuildContext context,
      required String otp,
      required UserModel userData}) async {
    try {
      loadingDialog(context);
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: otp);
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        log('verification succcesful');
        _verificationId = null;
        log('....saving to firestore');
        _uploadToFireStore(context: context, userData: userData);
      }
    } catch (e) {
      context.pop();
      log(e.toString());
      showSnackBar(
          context: context,
          message: "Something Happened! Please Try Again After few Minutes");
    }
  }

  Future<void> _uploadToFireStore(
      {required BuildContext context, required UserModel userData}) async {
    try {
      await _fireStore.collection('users').doc(_uid).set({
        'userName': userData.name,
        'phoneNumber': userData.phoneNumber,
        'userId': _uid
      });
      log('successfully added userdata to firstore');
      Provider.of<UserProvider>(context, listen: false)
          .updateUserDetails(userData: userData);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isSigned', true);
      context.pop();
      GoRouter.of(context).pushReplacementNamed(MyAppRouterConstants.homePage);
    } catch (e) {
      context.pop();
      log(e.toString());
      showSnackBar(
          context: context,
          message: "Something Happened! Please Try Again After few Minutes");
    }
  }

  //------------------SignUP Procedure---------------------//

  //------------------Login Procedure---------------------//
  Future<void> verifyPhoneNumberLogIn(
      {required BuildContext context, required String phoneNumber}) async {
    try {
      loadingDialog(context);
      final userSnapshot = await _fireStore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();
      if (userSnapshot.docs.isEmpty) {
        log('user does not exist ');
        context.pop();
        showSnackBar(
            context: context,
            message: 'User does not Exist. Please go to Register Page');
      } else {
        log('user exist lets send otp');
        await _auth.verifyPhoneNumber(
            phoneNumber: phoneNumber,
            verificationCompleted:
                (PhoneAuthCredential phoneAuthCredential) async {
              await _auth.signInWithCredential(phoneAuthCredential);
            },
            verificationFailed: (error) {
              context.pop();
              log(error.toString());
              showSnackBar(
                  context: context,
                  message:
                      "Something Happened! Please Try Again After few Minutes");
            },
            codeSent: (verificationId, forceResendingToken) {
              _verificationId = verificationId;
              log('...code sent successfully');
              context.pop();
              GoRouter.of(context).pushReplacementNamed(
                  MyAppRouterConstants.otpPage,
                  pathParameters: {
                    'phoneNo': phoneNumber,
                    'isFromRegistration': false.toString(),
                    'name': ''
                  });
            },
            codeAutoRetrievalTimeout: (verificationId) =>
                log('code auto retrival time out'));
      }
    } catch (e) {
      context.pop();
      log(e.toString());
      showSnackBar(
          context: context,
          message: "Something Happened! Please Try Again After few Minutes");
    }
  }

  Future<void> verifyOTPLogIn(
      {required BuildContext context, required String otp}) async {
    try {
      loadingDialog(context);
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: otp);
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        log('otp verification sucessfull');
        _uid = user.uid;
        //get user details from firestore
        DocumentSnapshot documentSnapshot =
            await _fireStore.collection('users').doc(_uid).get();
        if (documentSnapshot.exists) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          UserModel userData = await _extractUserDetails(documentSnapshot);
          userProvider.updateUserDetails(userData: userData);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isSigned', true);
          context.pop();
          GoRouter.of(context)
              .pushReplacementNamed(MyAppRouterConstants.homePage);
        }
      } else {
        context.pop();
        log('OTP Verification failed.');
        showSnackBar(context: context, message: 'OTP Verfication Failed');
      }
    } catch (e) {
      context.pop();
      log(e.toString());
      showSnackBar(
          context: context,
          message: "Something Happened! Please Try Again After few Minutes");
    }
  }

  Future<UserModel> _extractUserDetails(DocumentSnapshot snapshot) async {
    var name = (snapshot.data() as Map<String, dynamic>)['userName'] ?? '';
    var phoneNumber =
        (snapshot.data() as Map<String, dynamic>)['phoneNumber'] ?? '';
    var userId = (snapshot.data() as Map<String, dynamic>)['userId'] ?? '';
    return UserModel(name: name, phoneNumber: phoneNumber, uid: userId);
  }
  //------------------Login Procedure---------------------//

  //get current userid
  Future<void> getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _fireStore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _uid = user.uid;
        notifyListeners();
      }
    } else {
      log('no uid');
    }
  }

  //user signOut
  Future<void> signOut(BuildContext context) async {
    try {
      loadingDialog(context);
      await _auth.signOut();
      context.pop();
      log('user signed out successfully');
      GoRouter.of(context).pushReplacementNamed(MyAppRouterConstants.loginPage);
    } catch (e) {
      context.pop();
      log(e.toString());
      showSnackBar(
          context: context,
          message: "Something Happened! Please Try Again After few Minutes");
    }
  }

  //resend otp
  Future<void> resendOtp(BuildContext context, String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (phoneAuthCredential) async {
            await _auth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            showSnackBar(
                context: context,
                message:
                    'Something Happened! Please Try Again After few Minutes');
            // Handle verification failure
            log("Verification Failed-resend otp: ${error.message}");
          },
          codeSent: (verificationId, forceResendingToken) {
            _verificationId = verificationId;
            notifyListeners();
            // Code Successfully sent
            log('resend otp sent');
            showSnackBar(context: context, message: "Code Sent Successfully");
          },
          codeAutoRetrievalTimeout: (verificationId) =>
              log('auto retrieval timed out'));
    } catch (e) {
      log(e.toString());
      showSnackBar(
          context: context,
          message: "Something Happened! Please Try Again After few Minutes");
    }
  }

  //fetch data
  fetchDataFromFireStore(BuildContext context) async {
    try {
      await getCurrentUserId();
      final snapshot = await _fireStore.collection('users').doc(_uid).get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final userDetails = UserModel(
              name: data['userName'] ?? '',
              phoneNumber: data['phoneNumber'] ?? '',
              uid: data['userId'] ?? '');
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.updateUserDetails(userData: userDetails);
          notifyListeners();
        }
      }
    } catch (e) {
      log('Error fetching and storing driver data: $e');
    }
  }
}
