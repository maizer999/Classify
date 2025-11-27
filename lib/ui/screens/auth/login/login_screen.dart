import 'dart:async';
import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/screens/widgets/skip_button_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Removed: country_picker, sms_autofill

class LoginScreen extends StatefulWidget {
  final bool? isDeleteAccount;
  final bool? popToCurrent;
  final String? email;

  const LoginScreen({
    super.key,
    this.isDeleteAccount,
    this.popToCurrent,
    this.email,
  });

  @override
  State<LoginScreen> createState() => LoginScreenState();

  static MaterialPageRoute route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      builder: (_) => LoginScreen(
        isDeleteAccount: args?['isDeleteAccount'],
        popToCurrent: args?['popToCurrent'],
        email: args?['email'] as String?,
      ),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {

  late final TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool sendMailClicked = false;
  final _formKey = GlobalKey<FormState>();

  bool isObscure = true;
  bool isBack = false;
  late Size size;


  @override
  void initState() {
    super.initState();
    initCallFun();
  }

  void initCallFun() {
    // 🗑️ Removed mobile login setup
    context.read<AuthenticationCubit>().init();
    context.read<AuthenticationCubit>().listen((MLoginState state) {
      if (state is MOtpSendInProgress) {
        if (mounted) LoadingWidgets.showLoader(context);
      }

      if (state is MVerificationPending) {
        if (mounted) {
          LoadingWidgets.hideLoader(context);
          // Only email login logic remains
        }
      }

      if (state is MFail) {
        if (mounted) LoadingWidgets.hideLoader(context);

        if (mounted) {
          // Check for generic error
          final errorMessage = state.error.toString();  // Handle error generically

          // You can check if the error message contains certain keywords or do other custom error checks:
          if (errorMessage.contains('invalid-credentials')) {
            // If specific error is detected (e.g., invalid credentials), handle accordingly
            HelperUtils.showSnackBarMessage(
              context,
              'You have entered an invalid username or password.',
            );
          } else {
            // Handle all other errors generically
            HelperUtils.showSnackBarMessage(context, errorMessage);
          }
        }
      }

      if (state is MSuccess) {
        // Handle success logic here
        // Widgets.hideLoader(context);
      }
    });
  }




  @override
  void dispose() {
    _passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onTapContinue() {
    sendMailClicked = true;
    setState(() {});
  }

  Future<void> sendVerificationCode() async {
    final form = _formKey.currentState;

    if (form == null) return;
    form.save();
    if (form.validate()) {
      _onTapContinue();
    }
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return AnnotatedSafeArea(
      isAnnotated: true,
      navigationBarColor: context.color.backgroundColor,
      statusBarColor: context.color.backgroundColor,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: PopScope(
          canPop: isBack,
          onPopInvokedWithResult: (didPop, result) {
            if (widget.isDeleteAccount ?? false) {
              Navigator.pop(context);
            } else {
              if (sendMailClicked) {
                setState(() {
                  sendMailClicked = false;
                });
              } else {
                setState(() {
                  isBack = true;
                });
                return;
              }
            }
            setState(() {
              isBack = false;
            });
            return;
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: context.color.backgroundColor,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SkipButtonWidget(
                    onTap: () {
                      HelperUtils.killPreviousPages(context, Routes.main, {
                        "from": "login",
                        "isSkipped": true,
                      });
                    },
                  ),
                ),
              ],
            ),
            backgroundColor: context.color.backgroundColor,
            body: BlocListener<LoginCubit, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  context.read<UserDetailsCubit>().fill(
                    HiveUtils.getUserDetails(),
                  );
                  if (state.isProfileCompleted) {
                    HiveUtils.setUserIsAuthenticated(true);
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.locationPermissionScreen,
                          (route) => false,
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      Routes.completeProfile,
                      arguments: {"from": "login", "popToCurrent": false},
                    );
                  }
                }

                if (state is LoginFailure) {
                  HelperUtils.showSnackBarMessage(
                    context,
                    state.errorMessage.toString(),
                  );
                }
              },
              child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
                listener: (context, state) {
                  if (state is AuthenticationSuccess) {
                    LoadingWidgets.hideLoader(context);

                    if (state.type == AuthenticationType.email) {
                      if (state.credential.user!.emailVerified) {
                        context.read<LoginCubit>().login(
                          phoneNumber: state.credential.user!.phoneNumber,
                          firebaseUserId: state.credential.user!.uid,
                          type: state.type.name,
                          credential: state.credential,
                          countryCode: null,
                        );
                      }
                    }
                  }

                  if (state is AuthenticationFail) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      state.errorKey.translate(context),
                    );
                    LoadingWidgets.hideLoader(context);
                  }

                  if (state is AuthenticationInProcess) {
                    LoadingWidgets.showLoader(context);
                  }
                },
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    child: Form(
                      key: _formKey,
                      child: buildLoginWidget(), // Simplified
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget emailLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'loginWithEmail'.translate(context),
          fontSize: context.font.large,
          color: context.color.textColorDark,
        ),
        const SizedBox(height: 24),
        CustomTextFormField(
          controller: emailController,
          fillColor: context.color.secondaryColor,
          borderColor: context.color.textLightColor.withValues(alpha: 0.2),
          keyboard: TextInputType.emailAddress,
          validator: CustomTextFieldValidator.email,
          hintText: "emailAddress".translate(context),
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          hintText: "${"password".translate(context)}",
          controller: _passwordController,
          validator: CustomTextFieldValidator.nullCheck,
          obscureText: isObscure,
          suffix: IconButton(
            onPressed: () {
              isObscure = !isObscure;
              setState(() {});
            },
            icon: Icon(
              !isObscure ? Icons.visibility : Icons.visibility_off,
              color: context.color.textColorDark.withValues(alpha: 0.3),
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: MaterialButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.forgotPassword);
            },
            child: CustomText(
              "${"forgotPassword".translate(context)}?",
              color: context.color.textLightColor,
              fontSize: context.font.normal,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: Listenable.merge([emailController, _passwordController]),
          builder: (context, child) {
            return UiUtils.buildButton(
              context,
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                print("Email: ${emailController.text}");
                print("Password: ${_passwordController.text}");

                context.read<AuthenticationCubit>().setData(
                  payload: EmailLoginPayload(
                    email: emailController.text,
                    password: _passwordController.text,
                    type: EmailLoginType.login,
                  ),
                  type: AuthenticationType.email,
                );
                context.read<AuthenticationCubit>().authenticate();
              },
              buttonTitle: 'signIn'.translate(context),
              radius: 10,
              disabled:
              emailController.text.isEmpty ||
                  _passwordController.text.isEmpty,
              disabledColor: const Color.fromARGB(255, 104, 102, 106),
            );
          },
        ),
      ],
    );
  }

  Widget buildLoginWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            "welcomeback".translate(context),
            fontSize: context.font.extraLarge,
            color: context.color.textDefaultColor,
          ),
          const SizedBox(height: 8),
          emailLogin(),

          const SizedBox(height: 20),
          if (Constant.mobileAuthentication == "1" ||
              Constant.emailAuthentication == "1")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  "dontHaveAcc".translate(context),
                  color: context.color.textColorDark.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.twoStepSignupScreen,
                    );
                  },
                  child: CustomText(
                    "signUp".translate(context),
                    color: context.color.territoryColor,
                    showUnderline: true,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          ...googleAndAppleLogin(),
        ],
      ),
    );
  }

  List<Widget> googleAndAppleLogin() {
    return [
      if (Constant.googleAuthentication == "1" ||
          (Constant.appleAuthentication == "1" && Platform.isIOS))
        Align(
          alignment: Alignment.center,
          child: CustomText(
            "orSignInWith".translate(context),
            color: context.color.textDefaultColor,
          ),
        ),
      const SizedBox(height: 20),
      if (Constant.googleAuthentication == "1") ...[
        UiUtils.buildButton(
          context,
          prefixWidget: Padding(
            padding: EdgeInsetsDirectional.only(end: 10.0),
            child: UiUtils.getSvg(AppIcons.googleIcon, width: 22, height: 22),
          ),
          showElevation: false,
          buttonColor: secondaryColor_,
          border: !context.read<AppThemeCubit>().isDarkMode()
              ? BorderSide(
            color: context.color.textDefaultColor.withValues(alpha: 0.5),
          )
              : null,
          textColor: textDarkColor,
          onPressed: () async {
            try {
              context.read<AuthenticationCubit>().setData(
                payload: GoogleLoginPayload(),
                type: AuthenticationType.google,
              );
              context.read<AuthenticationCubit>().authenticate();
            } catch (e) {
              // Handle all errors generically
              HelperUtils.showSnackBarMessage(
                context,
                "Google login failed. Please try again. Error: ${e.toString()}",
              );
            }
          },
          radius: 8,
          height: 46,
          buttonTitle: "continueWithGoogle".translate(context),
        ),
        const SizedBox(height: 12),
      ],
      if (Constant.appleAuthentication == "1" && Platform.isIOS) ...[
        UiUtils.buildButton(
          context,
          prefixWidget: Padding(
            padding: EdgeInsetsDirectional.only(end: 10.0),
            child: UiUtils.getSvg(AppIcons.appleIcon, width: 22, height: 22),
          ),
          showElevation: false,
          buttonColor: secondaryColor_,
          border: !context.read<AppThemeCubit>().isDarkMode()
              ? BorderSide(
            color: context.color.textDefaultColor.withValues(alpha: 0.5),
          )
              : null,
          textColor: textDarkColor,
          onPressed: () {
            try {
              context.read<AuthenticationCubit>().setData(
                payload: AppleLoginPayload(),
                type: AuthenticationType.apple,
              );
              context.read<AuthenticationCubit>().authenticate();
            } catch (e) {
              // Handle all errors generically
              HelperUtils.showSnackBarMessage(
                context,
                "Apple login failed. Please try again. Error: ${e.toString()}",
              );
            }
          },
          height: 46,
          radius: 8,
          buttonTitle: "continueWithApple".translate(context),
        ),
        const SizedBox(height: 12),
      ],
    ];
  }


  Widget termAndPolicyTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 25.0, end: 25.0, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            "bySigningUpLoggingIn".translate(context),
            color: context.color.textLightColor.withValues(alpha: 0.8),
            fontSize: context.font.small,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: CustomText(
                  "termsOfService".translate(context),
                  color: context.color.territoryColor,
                  fontSize: context.font.small,
                  showUnderline: true,
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.profileSettings,
                  arguments: {
                    'title': "termsConditions".translate(context),
                    'param': Api.termsAndConditions,
                  },
                ),
              ),
              const SizedBox(width: 5.0),
              CustomText(
                "andTxt".translate(context),
                color: context.color.textLightColor.withValues(alpha: 0.8),
                fontSize: context.font.small,
              ),
              const SizedBox(width: 5.0),
              InkWell(
                child: CustomText(
                  "privacyPolicy".translate(context),
                  color: context.color.territoryColor,
                  fontSize: context.font.small,
                  showUnderline: true,
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.profileSettings,
                  arguments: {
                    'title': "privacyPolicy".translate(context),
                    'param': Api.privacyPolicy,
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> onBackPress() {
    if (widget.isDeleteAccount ?? false) {
      Navigator.pop(context);
    } else {
      if (sendMailClicked == true) {
        setState(() {
          sendMailClicked = false;
        });
      } else {
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

}