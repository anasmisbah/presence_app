import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  Future sendEmail() async {
    if (emailC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        auth.sendPasswordResetEmail(email: emailC.text);
        Get.snackbar('Berhasil', 'Berhasil mengirim email reset password');
      } catch (e) {
        Get.snackbar(
            'Terjadi Kesalahan', 'Tidak dapat mengirim email reset password');
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar('Terjadi Kesalahan', 'Email wajib diisi');
    }
  }
}
