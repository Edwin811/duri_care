import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';
import 'package:duri_care/models/user/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final formKey = GlobalKey<FormState>();
  final isPasswordVisible = false.obs;
  var firebaseUser = Rxn<User>();
  var userModel = Rxn<UserModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupUserListener();
  }

  void _setupUserListener() {
    _auth.authStateChanges().listen((User? user) async {
      firebaseUser.value = user;
      if (user != null) {
        await _fetchUserData(user.uid);
      } else {
        userModel.value = null;
      }
    });
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        userModel.value = UserModel.fromFirestore(userDoc);
      } else {
        if (firebaseUser.value != null) {
          UserModel newUser = UserModel.fromFirebaseUser(firebaseUser.value!);
          await _firestore.collection('users').doc(userId).set({
            ...newUser.toMap(),
            'createdAt': FieldValue.serverTimestamp(),
          });
          await _fetchUserData(userId);
        }
      }
    } catch (e) {
      DialogHelper.showErrorDialog(
        'Error fetching user data: ${e.toString()}',
        title: 'txt_error'.tr,
      );
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> loginWithEmail(String email, String password) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastLogin': FieldValue.serverTimestamp()},
      );

      String displayName = userModel.value?.displayName ?? 'User';
      DialogHelper.showSuccessDialog(
        'Selamat Datang $displayName',
        title: 'txt_success_login'.tr,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      DialogHelper.showErrorDialog(e.toString(), title: 'txt_failed_login'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    DialogHelper.showConfirmationDialog(
      'Apakah Anda yakin ingin keluar?',
      'txt_warning'.tr,
      'txt_confirm'.tr,
      'txt_cancel'.tr,
      () async {
        try {
          await _auth.signOut();
          Get.offAllNamed('/login');
        } catch (e) {
          DialogHelper.showErrorDialog(
            'Error logging out: ${e.toString()}',
            title: 'txt_error'.tr,
          );
        }
      },
      () => Get.back(),
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      DialogHelper.showSuccessDialog(
        'Reset password link has been sent to your email',
        title: 'txt_reset_password'.tr,
      );
    } catch (e) {
      DialogHelper.showErrorDialog(
        e.toString(),
        title: 'txt_reset_password_failed'.tr,
      );
    }
  }
}
