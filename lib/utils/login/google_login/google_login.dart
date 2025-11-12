import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:eClassify/utils/login/lib/login_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin extends LoginSystem {
  GoogleSignIn? _googleSignIn;

  @override
  void init() {
    _googleSignIn = GoogleSignIn(
      scopes: ["profile", "email"],
    );
  }

  @override
  Future<UserCredential?> login() async {
    print("==> GoogleLogin.login() START");
    try {
      emit(MProgress());
      print("==> Showing Google Sign-In prompt...");

      GoogleSignInAccount? googleSignIn = await _googleSignIn?.signIn();
      print("==> GoogleSignIn returned: $googleSignIn");

      if (googleSignIn == null) {
        print("==> User cancelled Google Sign-In");
        emit(MFail(
          "loginCancelledByUser".translate(Constant.navigatorKey.currentContext!),
        ));
        return null;
      }

      GoogleSignInAuthentication googleAuth = await googleSignIn.authentication;
      print("==> Google authentication details: $googleAuth");

      AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("==> Firebase AuthCredential created: $authCredential");

      UserCredential userCredential =
      await firebaseAuth.signInWithCredential(authCredential);
      print("==> Firebase UserCredential: $userCredential");

      emit(MSuccess());
      print("==> GoogleLogin.login() SUCCESS");

      return userCredential;
    } catch (e, stack) {
      print("==> GoogleLogin.login() ERROR: $e");
      print(stack);
      emit(MFail(e.toString()));
      return null; // login failed
    } finally {
      print("==> GoogleLogin.login() END");
    }
  }



  void signOut() async {
    if (await _googleSignIn?.isSignedIn() ?? false) {
      _googleSignIn?.signOut();
    }
  }

  @override
  void onEvent(MLoginState state) {}
}
