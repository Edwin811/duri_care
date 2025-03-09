import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/app_label.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/core/utils/widgets/cta_link.dart';
import 'package:duri_care/core/utils/widgets/google_button.dart';
import 'package:duri_care/core/utils/widgets/line_divider.dart';
import 'package:duri_care/core/utils/widgets/textform.dart';
import 'package:duri_care/features/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.xl,
                    Image.asset(
                      'assets/images/logo/LOGO-AGRITECH.png',
                      width: 64,
                    ),
                    AppSpacing.md,
                    Text(
                      'Welcome Back! ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sign In to your Account',
                      style: TextStyle(fontSize: 16),
                    ),
                    AppSpacing.xl,
                    Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          AppLabelText(text: 'Email'),
                          AppSpacing.sm,
                          AppTextFormField(
                            controller: controller.emailController,
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (value) =>
                                    controller.validateEmail(value ?? ''),
                          ),
                          AppSpacing.md,
                          AppLabelText(text: 'Password'),
                          AppSpacing.sm,
                          Obx(
                            () => AppTextFormField(
                              controller: controller.passwordController,
                              obscureText: controller.isPasswordVisible.value,
                              hintText: 'Enter your password',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon:
                                    controller.isPasswordVisible.value
                                        ? Icon(Icons.visibility)
                                        : Icon(Icons.visibility_off),
                                onPressed:
                                    () => controller.togglePasswordVisibility(),
                              ),
                              validator:
                                  (value) =>
                                      controller.validatePassword(value ?? ''),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.greenSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppFilledButton(
                            onPressed: () {
                              if (controller.formKey.currentState!.validate()) {
                                controller.loginWithEmail;
                              }
                            },
                            text: 'Login',
                          ),
                          AppSpacing.md,
                          LineDivider(),
                          AppSpacing.md,
                          GoogleButton(
                            onPressed: () {
                              controller.signInWithGoogle();
                            },
                            text: 'Sign In with Google',
                          ),
                          AppSpacing.md,
                          CtaLink(
                            text: 'Don\'t have an account? ',
                            onPressed: () {
                              Get.toNamed('/register');
                              controller.clearForm();
                            },
                            linkText: 'Register',
                          ),
                        ],
                      ),
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
