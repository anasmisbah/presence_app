import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UpdateProfileController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  TextEditingController passC = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future updateProfile(String uid) async {
    if (nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        nameC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        firestore.collection("pegawai").doc(uid).update({"name": nameC.text});
        Get.snackbar('Berhasil', 'Berhasil update profile');
      } catch (e) {
        Get.snackbar('Terjadi kesalahan', 'Tidak dapat update profile');
      } finally {
        isLoading.value = false;
      }
    }
  }
}
