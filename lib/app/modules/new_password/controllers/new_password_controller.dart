import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence_app/app/routes/app_pages.dart';

class NewPasswordController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController newPassC = TextEditingController();
  void newPassword() async {
    if (newPassC.text.isNotEmpty) {
      if (newPassC.text != "qweasdzxc") {
        try {
          await auth.currentUser!.updatePassword(newPassC.text);
          String email = auth.currentUser!.email!;
          await auth.signOut();
          await auth.signInWithEmailAndPassword(
              email: email, password: newPassC.text);
          Get.offAllNamed(Routes.HOME);
        } on FirebaseAuthException catch (e) {
          print(e.code);
          if (e.code == 'weak-password') {
            Get.snackbar(
                'Terjadi Kesalahan', 'password yang digunakan terlalu singkat');
          }
        } catch (e) {
          Get.snackbar(
              'Terjadi Kesalahan', 'Tidak dapat membuat password baru');
        }
      } else {
        Get.snackbar('Terjadi Kesalahan',
            'Password baru wajib berbeda dengan password default');
      }
    } else {
      Get.snackbar('Terjadi Kesalahan', 'Password baru wajib di isi');
    }
  }
}
