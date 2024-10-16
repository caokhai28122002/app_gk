// ignore_for_file: prefer_const_constructors, avoid_print, unused_local_variable, no_leading_underscores_for_local_identifiers, unnecessary_brace_in_string_interps, curly_braces_in_flow_control_structures, prefer_final_fields, unused_import

import 'dart:io';
import 'dart:typed_data'; // Thêm cho Uint8List
import 'package:app_gk/Login%20SignUp/Services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Nếu bạn muốn sử dụng cho di động
import 'Login SignUp/Screen/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _loaiController = TextEditingController();
  final TextEditingController _giaController = TextEditingController();

  CollectionReference _users = FirebaseFirestore.instance.collection("users");
  String imageUrl = '';
  Uint8List? _selectedImage; // Thay đổi từ XFile sang Uint8List

  /// Thêm sản phẩm vào Firestore
  _addUser() async {
    try {
      if (_selectedImage != null) {
        await uploadFileToStorage();
      }
      await _users.add({
        'name': _nameController.text,
        'loai': _loaiController.text,
        'gia': _giaController.text,
        'imageUrl': imageUrl, // Lưu URL hình ảnh
      });
      _clearForm();
    } catch (e) {
      print('Lỗi khi thêm sản phẩm: $e');
    }
  }

  /// Xóa sản phẩm
  void _deleteUser(String userId) {
    _users.doc(userId).delete();
  }

  /// Cập nhật sản phẩm
  Future<void> _updateUser(String userId) async {
    try {
      if (_selectedImage != null) {
        await uploadFileToStorage();
      }
      await _users.doc(userId).update({
        'name': _nameController.text,
        'loai': _loaiController.text,
        'gia': _giaController.text,
        if (imageUrl.isNotEmpty) 'imageUrl': imageUrl, // Cập nhật URL ảnh nếu có
      });
      _clearForm();
    } catch (e) {
      print('Lỗi khi cập nhật sản phẩm: $e');
    }
  }

  /// Chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    // Sử dụng file_picker cho web
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedImage = result.files.single.bytes; // Lưu trữ dữ liệu ảnh vào Uint8List
      });
    }
  }

  /// Tải ảnh lên Firebase Storage
  Future<void> uploadFileToStorage() async {
    if (_selectedImage == null) {
      print('Chưa có ảnh nào được chọn để tải lên');
      return;
    }

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceDirImages = FirebaseStorage.instance.ref().child('images').child(uniqueFileName);

    try {
      // Tải lên ảnh dưới dạng Uint8List
      await referenceDirImages.putData(_selectedImage!);
      imageUrl = await referenceDirImages.getDownloadURL();
      print('Tải ảnh lên thành công, URL: $imageUrl');
    } catch (e) {
      print('Lỗi khi tải ảnh lên: $e');
    }
  }

  /// Xóa dữ liệu form
  void _clearForm() {
    _nameController.clear();
    _loaiController.clear();
    _giaController.clear();
    _selectedImage = null;
    imageUrl = '';
  }

  /// Mở dialog để chỉnh sửa sản phẩm
  void _editUser(DocumentSnapshot user) {
    _nameController.text = user['name'];
    _loaiController.text = user['loai'];
    _giaController.text = user['gia'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Sửa sản phẩm"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Tên sản phẩm"),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Chọn ảnh mới"),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _loaiController,
                decoration: InputDecoration(labelText: "Loại sản phẩm"),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _giaController,
                decoration: InputDecoration(labelText: "Giá sản phẩm"),
              ),
              SizedBox(height: 8),
              if (_selectedImage != null)
                Image.memory(
                  _selectedImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUser(user.id);
                Navigator.pop(context);
              },
              child: Text("Cập nhật"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dữ liệu sản phẩm", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthMethod().googleSignOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nhập tên sản phẩm"),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _loaiController,
              decoration: InputDecoration(labelText: "Nhập loại sản phẩm"),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _giaController,
              decoration: InputDecoration(labelText: "Nhập giá sản phẩm"),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Icon(Icons.camera_alt),
            ),
            if (_selectedImage != null) ...[
              SizedBox(height: 20),
              Image.memory(
                _selectedImage!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _addUser();
              },
              child: Text("Thêm sản phẩm"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: _users.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var user = snapshot.data!.docs[index];

                      return Dismissible(
                        key: Key(user.id),
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteUser(user.id);
                        },
                        direction: DismissDirection.endToStart,
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(8.0),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (user['imageUrl'] != null && user['imageUrl'].isNotEmpty)
                                  Image.network(
                                    user['imageUrl'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text(user['loai']),
                                      Text(user['gia']),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editUser(user);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
