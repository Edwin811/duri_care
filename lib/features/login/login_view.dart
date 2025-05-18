import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/core/utils/widgets/app_label.dart';
import 'package:duri_care/core/utils/widgets/button.dart';
import 'package:duri_care/core/utils/widgets/textform.dart';
import 'package:duri_care/features/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});
  static const String route = '/login';

  @override
  Widget build(BuildContext context) {
    final loginKey = controller.loginKey;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  reverse: true,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.15),
                        Image.asset(
                          'assets/images/DURICARE-LOGO.png',
                          width: 120,
                        ),
                        AppSpacing.md,
                        Text(
                          'Selamat Datang di DuriCare',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Silahkan masuk untuk melanjutkan',
                          style: TextStyle(fontSize: 16),
                        ),
                        AppSpacing.xl,
                        Form(
                          key: loginKey,
                          child: Column(
                            children: [
                              AppLabelText(text: 'Email'),
                              AppSpacing.sm,
                              AppTextFormField(
                                controller: controller.emailController,
                                hintText: 'Masukkan email',
                                obscureText: false,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator:
                                    (value) => controller.validateEmail(value),
                              ),

                              AppSpacing.md,
                              AppLabelText(text: 'Password'),
                              AppSpacing.sm,
                              Obx(
                                () => AppTextFormField(
                                  controller: controller.passwordController,
                                  obscureText:
                                      controller.isPasswordVisible.value,
                                  hintText: 'Masukkan password',
                                  prefixIcon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon:
                                        controller.isPasswordVisible.value
                                            ? Icon(Icons.visibility)
                                            : Icon(Icons.visibility_off),
                                    onPressed:
                                        () =>
                                            controller
                                                .togglePasswordVisibility(),
                                  ),
                                  validator: controller.validatePassword,
                                  keyboardType: TextInputType.visiblePassword,
                                ),
                              ),
                              AppSpacing.xl,
                              AppFilledButton(
                                onPressed: () {
                                  controller.loginWithEmail();
                                },
                                text: 'Masuk',
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom >
                                              0
                                          ? 20
                                          : 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
