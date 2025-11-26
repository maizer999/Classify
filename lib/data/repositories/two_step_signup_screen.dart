import 'dart:convert';
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
  final _formKey = GlobalKey<FormState>();

  Future<void> completeSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${Api}/signup-two-step"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "name": nameController.text.trim(),
          "mobile": mobileController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200 && data["status"] == 200) {
        HelperUtils.showSnackBarMessage(
          context,
          data["message"] ?? "Signup successful!",
        );
        Navigator.pushReplacementNamed(context, Routes.login);
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          data["message"] ?? "Something went wrong",
          type: MessageType.error,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      HelperUtils.showSnackBarMessage(
        context,
        "Network error. Please try again.",
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showExtraFields) {
          // Go back to step 1 instead of exiting
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
          appBar: AppBar(
            backgroundColor: context.color.backgroundColor,
            title: CustomText(
              "signUp".translate(context),
              fontSize: context.font.large,
              color: context.color.textDefaultColor,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "x".translate(context),
                      fontSize: context.font.extraLarge,
                      color: context.color.textDefaultColor,
                    ),
                    const SizedBox(height: 24),

                    /// Step 1 Fields
                    CustomTextFormField(
                      controller: emailController,
                      hintText: "emailAddress".translate(context),
                      keyboard: TextInputType.emailAddress,
                      validator: CustomTextFieldValidator.email,
                    ),
                    const SizedBox(height: 16),

                    CustomTextFormField(
                      controller: passwordController,
                      hintText: "password".translate(context),
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
                    const SizedBox(height: 20),

                    if (!showExtraFields)
                      UiUtils.buildButton(
                        context,
                        buttonTitle: "continue".translate(context),
                        radius: 10,
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          setState(() => showExtraFields = true);
                          HelperUtils.showSnackBarMessage(
                            context,
                            "Please complete your profile details.",
                          );
                        },
                      ),

                    /// Step 2 Fields
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: showExtraFields
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextFormField(
                            controller: nameController,
                            hintText: "fullName".translate(context),
                            validator: CustomTextFieldValidator.nullCheck,
                          ),
                          const SizedBox(height: 16),

                          CustomTextFormField(
                            controller: mobileController,
                            hintText: "mobileNumberLbl".translate(context),
                            keyboard: TextInputType.phone,
                            validator: CustomTextFieldValidator.phoneNumber,
                          ),
                          const SizedBox(height: 30),

                          /// Finish Signup (Apple-style button)
                          UiUtils.buildButton(
                            context,
                            buttonTitle: "submit".translate(context),
                            radius: 10,
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              setState(() => showExtraFields = true);
                              HelperUtils.showSnackBarMessage(
                                context,
                                "Please complete your profile details.",
                              );
                            },
                          ),
                        ],
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
