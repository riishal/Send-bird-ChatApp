import 'package:flutter/material.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static String prefLoginUserId = 'loginUserId';

  static Future<bool> setLoginUserId() async {
    bool result = false;
    final sharedPreferences = await SharedPreferences.getInstance();
    final currentUser = SendbirdSdk().currentUser;
    if (currentUser != null) {
      debugPrint('//////////// ======>>>>>>>>> User Id: ${currentUser.userId}');
      result = await sharedPreferences.setString(
          prefLoginUserId, currentUser.userId);
    }
    return result;
  }

  static Future<String?> getLoginUserId() async {
    String? result;
    final sharedPreferences = await SharedPreferences.getInstance();
    result = sharedPreferences.getString(prefLoginUserId);
    debugPrint('//////////// ======>>>>>>>>> User Id: $result');

    return result;
  }

  static Future<bool> removeLoginUserId() async {
    bool result = false;
    final sharedPreferences = await SharedPreferences.getInstance();
    result = await sharedPreferences.remove(prefLoginUserId);
    return result;
  }
}
