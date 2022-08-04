// ignore_for_file: prefer_typing_uninitialized_variables, no_logic_in_create_state

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupChatPage extends StatefulWidget {
  final groupchatid;
  final groupname;
  const GroupChatPage(
      {required this.groupchatid, required this.groupname, Key? key})
      : super(key: key);

  @override
  State<GroupChatPage> createState() =>
      _GroupChatPageState(groupchatid, groupname);
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _message = TextEditingController();
  final groupchatid;
  final groupname;
  _GroupChatPageState(this.groupchatid, this.groupname);

  File? file;
  UploadTask? task;
  Alignment getAlignment(friend) {
    if (friend == FirebaseAuth.instance.currentUser!.uid) {
      return Alignment.topRight;
    }
    return Alignment.topLeft;
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": FirebaseAuth.instance.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await FirebaseFirestore.instance
          .collection('Groupchat')
          .doc(groupchatid)
          .collection('chats')
          .add(chatData);
    }
  }

  Future getImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final path = result.files.single.path;
    uploadImage();
    setState(() {
      file = File(path!);
    });
  }

  Future uploadImage() async {
    if (file == null) return;
    final filename = const Uuid().v1();
    final destination = 'files/$filename';

    task = FirebaseApi.uploadFile(destination, file!);
    if (task == null) return;
    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    if (task != null) {
      await FirebaseFirestore.instance
          .collection('Groupchat')
          .doc(groupchatid)
          .collection('chats')
          .add({
        'time': FieldValue.serverTimestamp(),
        'sendBy': FirebaseAuth.instance.currentUser!.displayName,
        'type': "img",
        'message': urlDownload
      });
      // .update({'message': urlDownload});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(groupname),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(
            height: size.height / 1.27,
            width: size.width,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Groupchat')
                    .doc(groupchatid)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none) {
                    return const Scaffold(
                      body: Center(
                        child: Text("Check your internet connection"),
                      ),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.active) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> chatMap =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return messageTile(size, chatMap);
                          });
                    }
                  }
                  return const Text("ooo");
                }),
          ),
          Container(
            height: size.height / 10,
            width: size.width,
            alignment: Alignment.center,
            child: SizedBox(
              height: size.height / 12,
              width: size.width / 1.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height / 17,
                    width: size.width / 1.3,
                    child: TextField(
                      controller: _message,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: getImage,
                            icon: const Icon(Icons.image),
                          ),
                          hintText: "Send Message",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.send), onPressed: onSendMessage),
                ],
              ),
            ),
          )
        ])));
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap) {
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        return Container(
          width: size.width,
          alignment: chatMap['sendBy'] ==
                  FirebaseAuth.instance.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Text(
                    chatMap['sendBy'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: size.height / 200,
                  ),
                  Text(
                    chatMap['message'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          height: size.height / 2.5,
          width: size.width / 2,
          alignment: chatMap['sendBy'] ==
                  FirebaseAuth.instance.currentUser!.displayName
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            height: size.height / 2.5,
            width: size.width / 2,
            alignment: Alignment.center,
            child: chatMap['message'] != ""
                ? Image.network(chatMap['message'])
                : const CircularProgressIndicator(),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Text(
              chatMap['message'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e.message);
      return null;
    }
  }
}
