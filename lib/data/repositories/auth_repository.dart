import 'dart:io';
import 'package:eClassify/utils/api.dart';

class CustomAuthResult {
  final String token;
  final Map<String, dynamic> userData;
  CustomAuthResult({required this.token, required this.userData});
}

class CustomVerificationId {
  final String id;
  CustomVerificationId(this.id);
}

class AuthRepository {
  Future<Map<String, dynamic>> numberLoginWithApi({
    String? phone,
    required String type,
    required String password,
    String? email,
    String? name,
    String? profile,
    String? countryCode,
  }) async {
    Map<String, String> parameters = {
      if (phone != null) Api.mobile: phone,
      Api.password : password ,
      Api.type: type,
      Api.platformType: Platform.isAndroid ? "android" : "ios",
      if (email != null) Api.email: email,
      if (name != null) Api.name: name,
      if (countryCode != null) Api.countryCode: countryCode,
    };
    Map<String, dynamic> response = await Api.post(
      url: Api.loginApi,
      parameter: parameters,
    );
    print("loginApi ${Api.loginApi}");
    print("parameters ${parameters}");
    print("response $response");
    return {"token": response['token'], "data": response['data']};
  }

  Future<dynamic> deleteUser() async {
    Map<String, dynamic> response = await Api.delete(url: Api.deleteUserApi);
    return response;
  }

  Future<CustomVerificationId> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    Function(dynamic e)? onError,
  }) async {
    try {
      Map<String, dynamic> response = await Api.post(
        url: Api.sendOTPApi,
        parameter: {
          Api.mobile: phoneNumber,
        },
      );

      String customVerificationId = response['verification_id'] ?? '';
      if (customVerificationId.isEmpty) {
        throw Exception("Failed to get verification ID from API.");
      }

      onCodeSent.call(customVerificationId);

      return CustomVerificationId(customVerificationId);
    } catch (e) {
      onError?.call(e);
      rethrow;
    }
  }

  Future<CustomAuthResult> verifyOTP({
    required String otpVerificationId,
    required String otp,
  }) async {
    try {
      Map<String, dynamic> response = await Api.post(
        url: Api.verifyOTPApi,
        parameter: {
          "verification_id": otpVerificationId,
          "otp_code": otp,
        },
      );

      String token = response['token'] ?? '';
      Map<String, dynamic> userData = response['data'] ?? {};

      return CustomAuthResult(token: token, userData: userData);
    } catch (e) {
      rethrow;
    }
  }
}

class MultiAuthRepository {
  Future<CustomAuthResult> createUserWithEmail({
    required String email,
    String? password,
    String? fcmId,
  }) async {
    try {
      Map<String, String> parameters = {
        Api.password : password ?? "" ,
        Api.type: "email",
        Api.platformType: Platform.isAndroid ? "android" : "ios",
        if (fcmId != null) Api.fcmId: fcmId,
        Api.email: email,
      };

      Map<String, dynamic> response = await Api.post(
        url: Api.signUpApi,
        parameter: parameters,
      );

      if (response['error'] != null && response['error'] == true) {
        throw Exception("API Error: ${response['message']}");
      }

      String token = response['token'] ?? '';
      Map<String, dynamic> userData = response['data'] ?? {};

      return CustomAuthResult(token: token, userData: userData);
    } catch (e) {
      rethrow;
    }
  }
}
