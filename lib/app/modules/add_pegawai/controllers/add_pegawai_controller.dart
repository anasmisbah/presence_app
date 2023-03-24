import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addPegawai() async {
    print("add pegawai");
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      Get.defaultDialog(
          title: "Validasi Admin",
          content: Column(
            children: [
              Text("Masukkan password untuk validasi admin"),
              TextField(
                controller: passC,
                autocorrect: false,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Get.back();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await prosesAddPegawai();
              },
              child: Text("Add Pegawai"),
            )
          ]);
    } else {
      Get.snackbar('Terjadi Kesalahan', 'NIP, nama, dan email harus diisi');
    }
  }

  Future prosesAddPegawai() async {
    if (passC.text.isNotEmpty) {
      try {
        String emailAdmin = auth.currentUser!.email!;

        UserCredential userCredentialAdmin =
            await auth.signInWithEmailAndPassword(
                email: emailAdmin, password: passC.text);

        if (userCredentialAdmin != null) {
          final pegawaiCredential = await auth.createUserWithEmailAndPassword(
            email: emailC.text,
            password: "qweasdzxc",
          );

          if (pegawaiCredential.user != null) {
            String uid = pegawaiCredential.user!.uid;

            await firestore.collection("pegawai").doc(uid).set({
              "nip": nipC.text,
              "name": nameC.text,
              "email": emailC.text,
              "uid": uid,
              "created_at": DateTime.now().toIso8601String(),
            });

            await pegawaiCredential.user!.sendEmailVerification();

            await auth.signOut();

            await auth.signInWithEmailAndPassword(
                email: emailAdmin, password: passC.text);
          }

          print(pegawaiCredential);
          Get.back(); //tututp dialog 
          Get.back(); //kembali ke home
          Get.snackbar('Berhasil', 'Berhasil menambahkan pegawai');
        }
      } on FirebaseAuthException catch (e) {
        print(e.code);
        if (e.code == 'weak-password') {
          Get.snackbar(
              'Terjadi Kesalahan', 'password yang digunakan terlalu singkat');
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar('Terjadi Kesalahan',
              'Pegawai telah terdaftar, tidak dapat menambahkan dengan email ini');
        } else if (e.code == 'wrong-password') {
          Get.snackbar('Terjadi Kesalahan', 'password salah');
        } else {
          Get.snackbar('Terjadi Kesalahan', e.code);
        }
      } catch (e) {
        Get.snackbar('Terjadi Kesalahan', 'Tidak dapat menambahkan pegawai');
      }
    } else {
      Get.snackbar('Terjadi Kesalahan', 'password harus diisi');
    }
  }
}
