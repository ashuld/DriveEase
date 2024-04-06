import 'package:drive_ease_main/model/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void updateUserDetails({required UserModel userData}) {
    _user = UserModel(name: userData.name, phoneNumber: userData.phoneNumber);
    notifyListeners();
  }
}
