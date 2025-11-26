import 'dart:io';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // Required for the new signup method
import 'dart:convert'; // Required for jsonEncode/jsonDecode

// NOTE: You must define ApiException and DataOutput in your project.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static int? forceResendingToken;

  Future<Map<String, dynamic>> numberLoginWithApi(
      {String? phone,
        required String uid,
        required String type,
        String? fcmId,
        String? email,
        String? name,
        String? profile,
        String? countryCode}) async {
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

    return {"token": response['token'], "data": response['data']};
  }

  Future<dynamic> deleteUser() async {
    Map<String, dynamic> response = await Api.delete(
      url: Api.deleteUserApi,
    );

    return response;
  }

  void loginEmailUser() async {}

  Future<void> sendOTP(
      {required String phoneNumber,
        required Function(String verificationId) onCodeSent,
        Function(dynamic e)? onError}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(
        seconds: Constant.otpTimeOutSecond,
      ),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        // Assuming ApiException can handle a string code
        onError?.call(ApiException(e.code));
      },
      codeSent: (String verificationId, int? resendToken) {
        forceResendingToken = resendToken;
        onCodeSent.call(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: forceResendingToken,
    );
  }

  Future<UserCredential> verifyOTP({
    required String otpVerificationId,
    required String otp,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: otpVerificationId, smsCode: otp);
    UserCredential userCredential =
    await _auth.signInWithCredential(credential);
    return userCredential;
  }
}

class MultiAuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> createUserWithEmail(
      {required String email, required String password}) async {
    try {
      UserCredential credentials =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credentials;
    } catch (e) {
      rethrow;
    }
  }

  /// Handles the two-step signup process by posting data to the API endpoint.
  Future<Map<String, dynamic>> twoStepSignupWithApi({
    required String email,
    required String password,
    required String name,
    required String mobile,
  }) async {
    // 1. Prepare the parameters map in the required format (Map<String, String> for Api.post)
    Map<String, String> parameters = {
      Api.email: email.trim(),
      Api.password: password.trim(),
      Api.name: name.trim(),
      Api.mobile: mobile.trim(),
    };

    // Debugging prints requested by the user
    print('DEBUG REPO: Attempting to POST to URL: ${Api.userSignupApi}');
    print('DEBUG REPO: Request Body: ${jsonEncode(parameters)}');

    try {
      // 2. Use the consistent Api.post utility for the request
      // Note: We no longer need the manual http.post logic here.
      Map<String, dynamic> response = await Api.post(
        url: Api.userSignupApi,
        parameter: parameters,
      );

      // Since Api.post likely handles error checking and decoding,
      // we only need to return the data structure expected by the UI.
      // Assuming a success means the response is valid.
      return response;

    } catch (e) {
      // Re-throw the error (SocketException, FormatException, ApiException, etc.)
      // for the UI to handle, maintaining the debugging print for visibility.
      print('*** CRITICAL ERROR IN REPO DURING SIGNUP ***');
      print('Exception Type: ${e.runtimeType}');
      print('Exception Details: $e');
      print('*******************************************');
      rethrow;
    }
  }
}