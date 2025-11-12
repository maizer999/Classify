import 'dart:io';

import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/repositories/auth_repository.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// States for the login operation
abstract class LoginState {
  const LoginState();
}

/// Initial state when no login operation has been performed
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// State indicating that the login operation is in progress
class LoginInProgress extends LoginState {
  const LoginInProgress();
}

/// State indicating successful login
class LoginSuccess extends LoginState {
  final bool isProfileCompleted;
  final dynamic credential;
  final Map<String, dynamic> apiResponse;

  const LoginSuccess({
    required this.isProfileCompleted,
    required this.credential,
    required this.apiResponse,
  });
}

/// State indicating failure in login
class LoginFailure extends LoginState {
  final dynamic errorMessage;

  const LoginFailure(this.errorMessage);
}

/// Cubit responsible for handling login operations
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  /// Creates a new instance of [LoginCubit]
  LoginCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const LoginInitial());

  /// Gets the device token for push notifications
  Future<String?> getDeviceToken() async {
    try {
      // Replace this with your custom logic to handle FCM token retrieval
      print("Fetching FCM token...");
      return ''; // Custom implementation
    } catch (e) {
      print("Error fetching FCM token: $e");
      return null;
    }
  }

  /// Handles the login process
  Future<void> login({
    String? phoneNumber,
    required String password,
    required String firebaseUserId,
    required String type,
    required UserCredential credential, // Using Firebase UserCredential
    String? countryCode,
  }) async {
    try {
      emit(const LoginInProgress());

      print("Fetching FCM Token...");
      final token = await _getFCMToken();
      print("FCM Token: $token");

      // Handle user data with your custom logic
      final user = await _getUpdatedUser(type, credential);
      print("Updated User: $user");

      final name = _getUserName(type, user, credential);
      print("User Name: $name");

      print("Making API request with the following parameters:");
      final result = await _authRepository.numberLoginWithApi(
        phone: phoneNumber ?? credential.user?.phoneNumber, // Corrected access to phone
        type: type,
        password:password ,
        email: credential.user?.email, // Corrected access to email
        name: name,
        profile: credential.user?.photoURL, // Corrected access to photoURL
        countryCode: countryCode,
      );

      print("API Response: $result");
      await _handleLoginResponse(result, credential);
    } catch (e) {
      print("Login failed: $e");
      emit(LoginFailure(e));
    }
  }

  /// Handles login with Twilio
  Future<void> loginWithTwilio({
    required String phoneNumber,
    required String password,
    required String firebaseUserId,
    required String type,
    required Map<String, dynamic> credential,
    required String countryCode,
  }) async {
    try {
      emit(const LoginInProgress());
      print("Fetching FCM Token...");
      final token = await _getFCMToken();
      print("FCM Token: $token");

      if (_isValidTwilioCredential(credential)) {
        await _handleTwilioLoginResponse(credential);
        return;
      }

      print("Making API request with Twilio credentials:");
      final result = await _authRepository.numberLoginWithApi(
        phone: phoneNumber,
        type: type,
        email: null,
        name: null,
        profile: null,
        countryCode: countryCode, password: password,
      );

      print("API Response: $result");
      // await _handleLoginResponse(result, credential);
    } catch (e) {
      print("Login with Twilio failed: $e");
      emit(LoginFailure(e));
    }
  }

  /// Gets FCM token with error handling
  Future<String?> _getFCMToken() async {
    try {
      print("Fetching FCM token...");
      // Replace with your custom logic for getting the FCM token
      return ''; // Custom implementation
    } catch (_) {
      print("Error getting FCM token");
      return '';
    }
  }

  /// Gets updated user information (Custom logic)
  Future<dynamic> _getUpdatedUser(String type, UserCredential credential) async {
    if (type == AuthenticationType.apple.name) {
      print("Updating user data based on Apple authentication");
      return credential.user; // Returning the actual Firebase user object
    }
    return null;
  }

  /// Gets user name based on authentication type
  String? _getUserName(String type, dynamic updatedUser, UserCredential credential) {
    if (type == AuthenticationType.apple.name) {
      return updatedUser?.displayName ?? credential.user?.displayName;
    }
    return credential.user?.displayName;
  }

  /// Handles login response
  Future<void> _handleLoginResponse(
      Map<String, dynamic> result,
      UserCredential credential,
      ) async {
    print("Handling login response...");
    HiveUtils.setJWT(result['token']);
    final data = result['data'];
    print("API Data: $data");

    final isProfileCompleted = _isProfileCompleted(data);
    print("Is Profile Completed: $isProfileCompleted");

    if (!isProfileCompleted) {
      HiveUtils.setProfileNotCompleted();
    }

    HiveUtils.setUserData(data);
    emit(LoginSuccess(
      apiResponse: Map<String, dynamic>.from(data),
      isProfileCompleted: isProfileCompleted,
      credential: credential,
    ));
  }

  /// Handles Twilio login response
  Future<void> _handleTwilioLoginResponse(Map<String, dynamic> credential) async {
    print("Handling Twilio login response...");
    HiveUtils.setJWT(credential['token']);
    final data = credential['data'];
    print("Twilio Data: $data");

    final isProfileCompleted = _isProfileCompleted(data);
    print("Is Profile Completed: $isProfileCompleted");

    if (!isProfileCompleted) {
      HiveUtils.setProfileNotCompleted();
    }

    HiveUtils.setUserData(data);
    emit(LoginSuccess(
      apiResponse: Map<String, dynamic>.from(data),
      isProfileCompleted: isProfileCompleted,
      credential: credential,
    ));
  }

  /// Checks if the profile is completed
  bool _isProfileCompleted(Map<String, dynamic> data) {
    print("Checking if profile is completed...");
    return !(data['name'] == "" ||
        data['name'] == null ||
        data['email'] == "" ||
        data['email'] == null);
  }

  /// Validates Twilio credential format
  bool _isValidTwilioCredential(Map<String, dynamic> credential) {
    print("Validating Twilio credentials...");
    return credential.containsKey('token') && credential.containsKey('data');
  }
}
