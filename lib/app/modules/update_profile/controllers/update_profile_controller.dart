import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_core;

class UpdateProfileController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  TextEditingController passC = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final ImagePicker picker = ImagePicker();
  XFile? image;

  final storage = firebase_core.FirebaseStorage.instance;

  void pickImage() async {
    image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print(image!.name);
      print(image!.name.split(".").last);
    } else {
      print(image);
    }
    update();
  }

  Future updateProfile(String uid) async {
    if (nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty &&
        nameC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        Map<String, dynamic> data = {
          "name": nameC.text,
        };
        if (image != null) {
          File file = File(image!.path);
          String ext = image!.name.split(".").last;
          await storage.ref("$uid/profile.$ext").putFile(file);
          String profileUrl =
              await storage.ref("$uid/profile.$ext").getDownloadURL();
          data.addAll({'profile': profileUrl});
        }
        firestore.collection("pegawai").doc(uid).update(data);
        image = null;
        update();
        Get.snackbar('Berhasil', 'Berhasil update profile');
      } on firebase_core.FirebaseException catch (e) {
        // ...
      } catch (e) {
        Get.snackbar('Terjadi kesalahan', 'Tidak dapat update profile');
      } finally {
        isLoading.value = false;
      }
    }
  }

  void deleteProfile(String uid) async {
    try {
      firestore
          .collection("pegawai")
          .doc(uid)
          .update({'profile': FieldValue.delete()});
      Get.back();
      Get.snackbar('berhasil', 'berhasil delete profile picture');
    } catch (e) {
      Get.snackbar('Terjadi kesalahan', 'Tidak dapat delete profile');
    }
  }
}
