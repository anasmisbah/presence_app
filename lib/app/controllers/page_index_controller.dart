import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence_app/app/routes/app_pages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PageIndexController extends GetxController {
  RxInt pageIndex = 0.obs;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void changePage(int i) async {
    switch (i) {
      case 1:
        print("Absensi");
        Map<String, dynamic> res = await _determinePosition();

        if (res['error'] == false) {
          try {
            Position position = res['position'];
            List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude,
              position.longitude,
            );
            String address =
                "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}";
            await updatePosition(position, address);

            // Absen
            presensi(position, address);
          } catch (e) {
            Get.snackbar('Terjadi Kesalahan', "Gagal absen");
          }
        } else {
          Get.snackbar('Terjadi Kesalahan', res['message']);
        }

        print("Selesai");
        break;

      case 2:
        pageIndex.value = i;
        Get.offAllNamed(Routes.PROFILE);
        break;
      default:
        pageIndex.value = i;
        Get.offAllNamed(Routes.HOME);
    }
  }

  Future presensi(Position position, String address) async {
    String uid = auth.currentUser!.uid;
    CollectionReference<Map<String, dynamic>> colPresence =
        await firestore.collection("pegawai").doc(uid).collection('presence');
    QuerySnapshot<Map<String, dynamic>> snapPresence = await colPresence.get();
    DateTime now = DateTime.now();
    String todayDocId = DateFormat.yMd().format(now).replaceAll("/", "-");
    if (snapPresence.docs.length == 0) {
      // belum pernah absen & set absen masuk
      colPresence.doc(todayDocId).set({
        "date": now.toIso8601String(),
        "masuk": {
          "date": now.toIso8601String(),
          "lat": position.latitude,
          "long": position.longitude,
          "address": address,
          "status": "Di dalam area",
        }
      });
    } else {
      DocumentSnapshot<Map<String, dynamic>> todayDoc =
          await colPresence.doc(todayDocId).get();
      if (todayDoc.exists) {
        // absen keluar/sudah absen masuk dan keluar
        print("dijalankan todayDoc.exists");
        Map<String, dynamic>? dataPresenceToday = todayDoc.data();
        if (dataPresenceToday?["keluar"] != null) {
          // Sudah absen keluar
          Get.snackbar("Sukses", "Kamu telah absen masuk dan keluar.");
        } else {
          colPresence.doc(todayDocId).update({
            "keluar": {
              "date": now.toIso8601String(),
              "lat": position.latitude,
              "long": position.longitude,
              "address": address,
              "status": "Di dalam area",
            }
          });
        }
      } else {
        // absen masuk
        colPresence.doc(todayDocId).set({
          "date": now.toIso8601String(),
          "masuk": {
            "date": now.toIso8601String(),
            "lat": position.latitude,
            "long": position.longitude,
            "address": address,
            "status": "Di dalam area",
          }
        });
      }
    }
  }

  Future updatePosition(Position position, String address) async {
    String uid = auth.currentUser!.uid;
    await firestore.collection("pegawai").doc(uid).update({
      "position": {
        "lat": position.latitude,
        "long": position.longitude,
      },
      "address": address,
    });
    Get.snackbar('Berhasil absen', address);
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Map<String, dynamic>> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return {
        "message": "Location services are disabled.",
        "error": true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return {
          "message": "Location permissions are denied",
          "error": true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        "message":
            "Location permissions are permanently denied, we cannot request permissions.",
        "error": true,
      };
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();

    return {
      "position": position,
      "message": "Berhasil mendapatkan posisi device",
      "error": false,
    };
  }
}
