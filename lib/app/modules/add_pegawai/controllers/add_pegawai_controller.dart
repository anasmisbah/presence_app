import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPegawaiController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddPegawai = false.obs;

  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  TextEditingController passC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future addPegawai() async {
    print("add pegawai");
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      isLoading.value = true;
      Get.defaultDialog(
          title: "Validasi Admin",
          content: Column(
            children: [
              Text("Masukkan password untuk validasi admin"),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: passC,
                autocorrect: false,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "password",
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                isLoading.value = false;
                Get.back();
              },
              child: Text("Cancel"),
            ),
            Obx(() => ElevatedButton(
                  onPressed: () async {
                    if (isLoadingAddPegawai.isFalse) {
                      await prosesAddPegawai();
                      isLoading.value = false;
                    }
                  },
                  child:isLoadingAddPegawai.isFalse? Text("Add Pegawai"):Text("lOADING.."),
                ))
          ]);
    } else {
      isLoading.value = false;
      Get.snackbar('Terjadi Kesalahan', 'NIP, nama, dan email harus diisi');
    }
  }

  Future prosesAddPegawai() async {
    if (passC.text.isNotEmpty) {
      isLoadingAddPegawai.value = true;
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
          isLoadingAddPegawai.value = false;
          print(pegawaiCredential);
          Get.back(); //tututp dialog
          Get.back(); //kembali ke home
          Get.snackbar('Berhasil', 'Berhasil menambahkan pegawai');
        }
      } on FirebaseAuthException catch (e) {
        isLoadingAddPegawai.value = false;
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
      isLoadingAddPegawai.value = false;
      isLoading.value = false;
      Get.snackbar('Terjadi Kesalahan', 'password harus diisi');
    }
  }
}
