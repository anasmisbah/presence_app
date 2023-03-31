import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:presence_app/app/controllers/page_index_controller.dart';
import 'package:presence_app/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final pageC = Get.find<PageIndexController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: controller.streamUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              Map<String, dynamic> user = snapshot.data!.data()!;
              String defaultImage =
                  "https://ui-avatars.com/api/?name=${user['name']}";
              return ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 75,
                          height: 75,
                          color: Colors.grey.shade200,
                          child: Image.network(
                            user['profile'] != null
                                ? user['profile']
                                : defaultImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome,",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Jalan raya gandul"),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${user['job']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "${user['nip']}",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${user['name']}",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text("Masuk"),
                            Text("-"),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 2,
                          color: Colors.grey,
                        ),
                        Column(
                          children: [
                            Text("Keluar"),
                            Text("-"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Last 5 days ago",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(onPressed: () {}, child: Text("See more")),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                    "${DateFormat.yMMMEd().format(DateTime.now())}"),
                              ],
                            ),
                            Text("${DateFormat.jms().format(DateTime.now())}"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Keluar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("${DateFormat.jms().format(DateTime.now())}"),
                          ],
                        ),
                      );
                    },
                  )
                ],
              );
            } else {
              return Center(
                child: Text("Tidak dapat memuat database user"),
              );
            }
          }),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.fingerprint, title: 'Add'),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        initialActiveIndex: pageC.pageIndex.value,
        onTap: (int i) => pageC.changePage(i),
      ),
    );
  }
}
