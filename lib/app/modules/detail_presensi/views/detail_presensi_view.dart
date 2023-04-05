import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/detail_presensi_controller.dart';

class DetailPresensiView extends GetView<DetailPresensiController> {
  DetailPresensiView({Key? key}) : super(key: key);
  Map<String, dynamic> data = Get.arguments;
  @override
  Widget build(BuildContext context) {
    print(data);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Presensi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade200,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "${DateFormat.yMMMMEEEEd().format(DateTime.parse(data['date']))}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Masuk",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                    "Jam : ${DateFormat.jms().format(DateTime.parse(data['masuk']['date']))}"),
                Text(
                    "Posisi : ${data['masuk']['lat']}, ${data['masuk']['long']}"),
                Text("Status : ${data['masuk']['status']}"),
                Text(
                    "Distance : ${data['masuk']['distance'].toString().split(".").first} Meter"),
                Text("address : ${data['masuk']['address']}"),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Keluar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                    "Jam : ${data['keluar'] != null ? DateFormat.jms().format(DateTime.parse(data['keluar']['date'])) : "-"}"),
                Text(data['keluar'] != null
                    ? "Posisi : ${data['keluar']['lat']}, ${data['keluar']['long']}"
                    : "Posisi : -"),
                Text(data['keluar'] != null
                    ? "Status : ${data['keluar']['status']}"
                    : "Status : keluar -"),
                Text(data['keluar'] != null
                    ? "Distance : ${data['keluar']['distance'].toString().split(".").first} Meter"
                    : "Distance : -"),
                Text(data['keluar'] != null
                    ? "address : ${data['keluar']['address']}"
                    : "address : -"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
