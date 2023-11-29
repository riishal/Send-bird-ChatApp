import 'package:chat_app/service/user_service.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';

class AuthService {
  static Future<void> loginUser(String userId) async {
    final sendbird = SendbirdSdk(appId: '4DF99F17-28BF-4741-90AB-99DAAA707E58');
    await sendbird.connect(userId);
    // await SendbirdChat.connect(userId);
    await UserService.setLoginUserId();
  }
}
