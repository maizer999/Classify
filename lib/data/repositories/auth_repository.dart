import 'dart:io';
// Removed: import 'package:firebase_auth/firebase_auth.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';

// --- Custom/Placeholder Types for Firebase types ---
// These are defined in Api.dart now for simplicity
class CustomAuthResult {
  final String token;
  final Map<String, dynamic> userData;
  CustomAuthResult({required this.token, required this.userData});
}

class CustomVerificationId {
  final String id;
  CustomVerificationId(this.id);
}
// --------------------------------------------------

class AuthRepository {
  // Removed: final FirebaseAuth _auth = FirebaseAuth.instance;
  // Removed: static int? forceResendingToken;

  Future<Map<String, dynamic>> numberLoginWithApi({
    String? phone,
    required String uid,
    required String type,
    String? fcmId,
    String? email,
    String? name,
    String? profile,
    String? countryCode,
  }) async {
    Map<String, String> parameters = {
      if (phone != null) Api.mobile: phone,
      Api.firebaseId: uid,
      Api.type: type,
      Api.platformType: Platform.isAndroid ? "android" : "ios",
      if (fcmId != null) Api.fcmId: fcmId,
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

  void loginEmailUser() async {}

  /// Sends an OTP via a custom backend/SMS gateway (Uses placeholder API).
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

  /// Verifies the OTP using a custom backend/SMS gateway (Uses placeholder API).
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
  // The curl command matches a sign-up/registration flow,
  // which replaces the Firebase email creation method.
  Future<CustomAuthResult> createUserWithEmail({
    required String firebaseId, // Renamed from uid to match parameter key
    required String email,
    // Password is not in your curl, but might be needed for your API later
    String? password,
    String? fcmId,
  }) async {
    try {
      // --- Custom Sign-up Logic using your CURL data ---
      Map<String, String> parameters = {
        Api.firebaseId: firebaseId,
        Api.type: "email", // From curl: 'type=email'
        Api.platformType: Platform.isAndroid ? "android" : "ios", // From curl
        if (fcmId != null) Api.fcmId: fcmId,
        Api.email: email,
        // if (password != null) "password": password, // Add if needed
      };

      Map<String, dynamic> response = await Api.post(
        url: Api.signUpApi, // Your new API endpoint
        parameter: parameters,
      );

      // Return a custom auth result object.
      String token = response['token'] ?? '';
      Map<String, dynamic> userData = response['data'] ?? {};
      return CustomAuthResult(token: token, userData: userData);
      // --- End Custom Sign-up Logic ---
    } catch (e) {
      rethrow;
    }
  }
}