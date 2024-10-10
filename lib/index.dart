// ignore_for_file: prefer_const_constructors

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RealTimeCRUDEdatabase extends StatefulWidget {
  const RealTimeCRUDEdatabase({super.key});

  @override
  State<RealTimeCRUDEdatabase> createState() => _RealTimeCRUDEdatabaseState();
}

final DatabaseReference dbRef = FirebaseDatabase.instance.ref("sanpham");

class _RealTimeCRUDEdatabaseState extends State<RealTimeCRUDEdatabase> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "Quản lý sản phẩm",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FirebaseAnimatedList(
              query: dbRef,
              itemBuilder: (context, snapshot, animation, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(10),
                  //
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    leading: CircleAvatar(
                      child: Text(
                        (index + 1).toString(),
                      ),
                    ),
                    title: Text(
                      snapshot.child("tensanpham").value.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.child("loaisanpham").value.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Giá: ${snapshot.child("giasanpham").value.toString()}",
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              nameController.text =
                                  snapshot.child("tensanpham").value.toString();
                              addressController.text = snapshot
                                  .child("loaisanpham")
                                  .value
                                  .toString();
                              priceController.text =
                                  snapshot.child('giasanpham').value.toString();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return myDialogBox(
                                    context: context,
                                    name: "Cập nhật sản phẩm",
                                    address: "Cập nhật",
                                    onPressed: () {
                                      dbRef
                                          .child(snapshot
                                              .child("idsp")
                                              .value
                                              .toString())
                                          .update({
                                        'tensanpham':
                                            nameController.text.toString(),
                                        "loaisanpham":
                                            addressController.text.toString(),
                                        'giasanpham':
                                            priceController.text.toString(),
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              );
                            },
                            leading: const Icon(Icons.edit),
                            title: const Text("Sửa"),
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              dbRef
                                  .child(
                                      snapshot.child("idsp").value.toString())
                                  .remove();
                            },
                            leading: const Icon(Icons.delete),
                            title: const Text("Xóa"),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          nameController.clear();
          addressController.clear();
          priceController.clear();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return myDialogBox(
                context: context,
                name: "Thêm sản phẩm",
                address: "Thêm",
                onPressed: () {
                  final id = DateTime.now().millisecondsSinceEpoch.toString();
                  dbRef.child(id).set({
                    'tensanpham': nameController.text.toString(),
                    "loaisanpham": addressController.text.toString(),
                    'giasanpham': priceController.text.toString(),
                    'idsp': id
                    //
                  });
                  Navigator.pop(context);
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Dialog myDialogBox({
    required BuildContext context,
    required String name,
    required String address,
    required VoidCallback onPressed,
  }) {
    return Dialog(
      backgroundColor: Colors.blue[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                CircleAvatar(
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nhập tên sản phẩm",
                hintText: "vd: Iphone 11",
              ),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Nhập loại sản phẩm",
                hintText: "vd: Điện thoại",
              ),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: "Nhập giá sản phẩm",
                hintText: "vd: 999000",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(address),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
