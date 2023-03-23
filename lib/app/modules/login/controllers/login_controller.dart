import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence_app/app/routes/app_pages.dart';

class LoginController extends GetxController {
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  void login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailC.text, password: passC.text);

        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified == true) {
            Get.offNamed(Routes.HOME);
          } else {
            Get.defaultDialog(
                onConfirm: () => print("Ok"),
                title: "Belum verifikasi",
                middleText:
                    "Kamu belum verifikasi email, lakukan verifikasi melalui email anda");
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Get.snackbar(
              'Terjadi Kesalahan', 'Pegawai dengan email ini tidak ditemukan');
        } else if (e.code == 'wrong-password') {
          Get.snackbar('Terjadi Kesalahan', 'password salah');
        }
        Get.snackbar('Terjadi Kesalahan', 'Gagal login');
      }
    } else {
      Get.snackbar('Terjadi Kesalahan', 'email dan password harus diisi');
    }
  }
}
