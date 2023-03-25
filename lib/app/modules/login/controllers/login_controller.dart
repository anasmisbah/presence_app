import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence_app/app/routes/app_pages.dart';

class LoginController extends GetxController {
  TextEditingController emailC = TextEditingController();
  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  RxBool isLoading = false.obs;

  Future login() async {
    if (emailC.text.isNotEmpty && passC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailC.text, password: passC.text);
        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified == true) {
            isLoading.value = false;
            if (passC.text == "qweasdzxc") {
              Get.offAllNamed(Routes.NEW_PASSWORD);
            } else {
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            isLoading.value = true;
            Get.defaultDialog(
                actions: [
                  OutlinedButton(
                    onPressed: () {
                      isLoading.value = false;
                      Get.back();
                    },
                    child: Text('cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        isLoading.value = false;
                        await userCredential.user!.sendEmailVerification();
                        Get.snackbar('Berhasil',
                            'Email verifikasi telah dikirim ulang, cek email kamu sekarang juga!');
                      } catch (e) {
                        isLoading.value = false;
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
        isLoading.value = false;
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
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
