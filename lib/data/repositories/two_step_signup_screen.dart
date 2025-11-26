import 'dart:convert';
import 'package:eClassify/data/repositories/auth_repository.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:http/http.dart' as http;

class TwoStepSignupScreen extends StatefulWidget {
  const TwoStepSignupScreen({Key? key}) : super(key: key);

  @override
  State<TwoStepSignupScreen> createState() => _TwoStepSignupScreenState();
}

class _TwoStepSignupScreenState extends State<TwoStepSignupScreen> {
  bool isLoading = false;
  bool isObscure = true;
  bool showExtraFields = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();

  // 💡 NEW: Separate GlobalKeys for each step
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  Future<void> completeSignup() async {
    setState(() => isLoading = true);

    try {
      final MultiAuthRepository _authRepo = MultiAuthRepository();
      final response = await _authRepo.twoStepSignupWithApi(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        mobile: mobileController.text,
      );

      setState(() => isLoading = false);

      HelperUtils.showSnackBarMessage(
        context,
        response["message"] ?? "Signup successful!",
      );
      Navigator.pushReplacementNamed(context, Routes.login);

    } catch (e) {
      setState(() => isLoading = false);

      String errorMessage = "Network error. Please try again.";

      HelperUtils.showSnackBarMessage(
        context,
        errorMessage,
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showExtraFields) {
          setState(() => showExtraFields = false);
          return false;
        }
        return true;
      },
      child: AnnotatedSafeArea(
        isAnnotated: true,
        navigationBarColor: context.color.backgroundColor,
        statusBarColor: context.color.backgroundColor,
        child: Scaffold(
          backgroundColor: context.color.backgroundColor,

          // ---------- Custom Header ----------
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              decoration: BoxDecoration(
                color: context.color.secondaryColor.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Center(
                child: CustomText(
                  "Sign Up".translate(context),
                  fontSize: context.font.extraLarge,
                  fontWeight: FontWeight.w600,
                  color: context.color.textDefaultColor,
                ),
              ),
            ),
          ),

          // ---------- BODY ----------
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1 Fields wrapped in its own Form
                  Form(
                    key: _formKeyStep1, // 🔑 Using Step 1 Key
                    child: Column(
                      children: [
                        CustomTextFormField(
                          controller: emailController,
                          hintText: "Email Address".translate(context),
                          keyboard: TextInputType.emailAddress,
                          validator: CustomTextFieldValidator.email,
                        ),
                        const SizedBox(height: 16),

                        CustomTextFormField(
                          controller: passwordController,
                          hintText: "Password".translate(context),
                          obscureText: isObscure,
                          validator: CustomTextFieldValidator.nullCheck,
                          suffix: IconButton(
                            icon: Icon(
                              isObscure ? Icons.visibility_off : Icons.visibility,
                              color: context.color.textLightColor.withValues(alpha: 0.4),
                            ),
                            onPressed: () => setState(() => isObscure = !isObscure),
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),

                  if (!showExtraFields)
                    UiUtils.buildButton(
                      context,
                      buttonTitle: "Continue".translate(context),
                      radius: 12,
                      onPressed: () {
                        // 🔑 Validates ONLY Step 1 fields
                        if (!_formKeyStep1.currentState!.validate()) return;
                        setState(() => showExtraFields = true);
                        HelperUtils.showSnackBarMessage(
                          context,
                          "Please complete your profile details.",
                        );
                      },
                    ),

                  // Step 2 Fields (with animated transition)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showExtraFields
                        ? Form( // 🔑 Form for Step 2
                      key: _formKeyStep2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          CustomTextFormField(
                            controller: nameController,
                            hintText: "Full Name".translate(context),
                            validator: CustomTextFieldValidator.nullCheck,
                          ),
                          const SizedBox(height: 16),

                          CustomTextFormField(
                            controller: mobileController,
                            hintText: "Mobile Number".translate(context),
                            keyboard: TextInputType.phone,
                            validator: CustomTextFieldValidator.phoneNumber,
                          ),
                          const SizedBox(height: 30),

                          UiUtils.buildButton(
                            context,
                            buttonTitle: "Submit".translate(context),
                            radius: 12,
                            onPressed: () {
                              if (!_formKeyStep2.currentState!.validate()) return;
                              completeSignup();
                            },
                          ),
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
