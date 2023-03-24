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
            if (passC.text == "qweasdzxc") {
              Get.offAllNamed(Routes.NEW_PASSWORD);
            } else {
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            Get.defaultDialog(
                actions: [
                  OutlinedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await userCredential.user!.sendEmailVerification();
                        Get.snackbar('Berhasil',
                            'Email verifikasi telah dikirim ulang, cek email kamu sekarang juga!');
                      } catch (e) {
                        Get.snackbar('Terjadi Kesalahan',
                            'Tidak dapat mengirim ulang email verifikasi,hubungi admin atau CS');
                      }
                    },
                    child: Text('Kirim ulang'),
                  ),
                ],
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
