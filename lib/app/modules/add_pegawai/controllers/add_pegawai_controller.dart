import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addPegawai() async {
    print("add pegawai");
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      try {
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "qweasdzxc",
        );

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;

          await firestore.collection("pegawai").doc(uid).set({
            "nip": nipC.text,
            "name": nameC.text,
            "email": emailC.text,
            "uid": uid,
            "created_at": DateTime.now().toIso8601String(),
          });

          await userCredential.user!.sendEmailVerification();
        }

        print(userCredential);
      } on FirebaseAuthException catch (e) {
        print(e.code);
        if (e.code == 'weak-password') {
          Get.snackbar(
              'Terjadi Kesalahan', 'password yang digunakan terlalu singkat');
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar('Terjadi Kesalahan',
              'Pegawai telah terdaftar, tidak dapat menambahkan dengan email ini');
        }
      } catch (e) {
        Get.snackbar('Terjadi Kesalahan', 'Tidak dapat menambahkan pegawai');
      }
    } else {
      Get.snackbar('Terjadi Kesalahan', 'NIP, nama, dan email harus diisi');
    }
  }
}
