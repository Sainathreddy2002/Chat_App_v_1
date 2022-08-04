// ignore: file_names
// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_6.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final friendUid;
  final friendName;

  const ChatPage({Key? key, this.friendUid, this.friendName}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _ChatPage createState() => _ChatPage(friendUid, friendName);
}

class _ChatPage extends State<ChatPage> {
  _ChatPage(this.friendUid, this.friendName);

  //variables declaration
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final friendUid;
  final friendName;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  var chatDocId;
  final _textController = TextEditingController();
  File? file;
  UploadTask? task;
  var stream;
  @override
  void initState() {
    super.initState();
    checkUser();
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
    await chats.doc(chatDocId).collection('messages').doc(filename).set({
      'createdOn': FieldValue.serverTimestamp(),
      'uid': currentUserId,
      'friendName': friendName,
      'type': "img",
      'msg': ""
    });
    final destination = 'files/$filename';

    task = FirebaseApi.uploadFile(destination, file!);
    if (task == null) return;
    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    if (task != null) {
      await chats
          .doc(chatDocId)
          .collection('messages')
          .doc(filename)
          .update({'msg': urlDownload});
    }
  }

  void checkUser() async {
    await chats
        .where('users', isEqualTo: {friendUid: null, currentUserId: null})
        .limit(1)
        .get()
        .then(
          (QuerySnapshot querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              setState(() {
                chatDocId = querySnapshot.docs.single.id;
              });
            } else {
              await chats.add({
                'users': {currentUserId: null, friendUid: null},
                'names': {
                  currentUserId: FirebaseAuth.instance.currentUser?.displayName,
                  friendUid: friendName
                }
              }).then((value) => {chatDocId = value});
            }
          },
        )
        .catchError((error) {});
  }

  void sendMessage(String msg) {
    if (msg == '') return;
    Map<String, dynamic> messages = {
      'createdOn': FieldValue.serverTimestamp(),
      'uid': currentUserId,
      'friendName': friendName,
      'type': "text",
      'msg': msg
    };
    chats.doc(chatDocId).collection('messages').add(messages).then((value) {
      _textController.text = '';
    });
    print(messages['type']);
  }

  bool isSender(String friend) {
    return friend == currentUserId;
  }

  Alignment getAlignment(friend) {
    if (friend == currentUserId) {
      return Alignment.topRight;
    }
    return Alignment.topLeft;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
      stream: chats
          .doc(chatDocId)
          .collection('messages')
          .orderBy('createdOn', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong"),
          );
        }

        if (snapshot.hasData) {
          var data;
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.blue,
              middle: Text(friendName),
              previousPageTitle: "Back",
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      reverse: true,
                      children: snapshot.data!.docs.map(
                        (DocumentSnapshot document) {
                          data = document.data()!;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ChatBubble(
                              clipper: ChatBubbleClipper6(
                                nipSize: 0,
                                radius: 10,
                                type: isSender(data['uid'].toString())
                                    ? BubbleType.sendBubble
                                    : BubbleType.receiverBubble,
                              ),
                              alignment: getAlignment(data['uid'].toString()),
                              margin: const EdgeInsets.only(top: 20),
                              backGroundColor: isSender(data['uid'].toString())
                                  ? Colors.blue
                                  : const Color(0xffE7E7ED),
                              child: data['type'] == 'text'
                                  ? Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  data['msg'],
                                                  style: TextStyle(
                                                      fontFamily: 'Raleway',
                                                      fontSize: 16,
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: isSender(
                                                              data['uid']
                                                                  .toString())
                                                          ? Colors.white
                                                          : Colors.black),
                                                  // overflow:
                                                  //     TextOverflow.ellipsis),
                                                ),
                                              )
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  data['createdOn'] == null
                                                      ? DateTime.now()
                                                          .toString()
                                                      : data['createdOn']
                                                          .toDate()
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: isSender(
                                                              data['uid']
                                                                  .toString())
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: size.height / 2.5,
                                      width: size.width / 2,
                                      alignment:
                                          getAlignment(data['uid'].toString()),
                                      child: Container(
                                        height: size.height / 2.5,
                                        width: size.width / 2,
                                        alignment: Alignment.center,
                                        child: data['msg'] != ""
                                            ? Image.network(data['msg'])
                                            : const CircularProgressIndicator(),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0),
                          child: CupertinoTextField(
                            // suffix:
                            maxLines: 1,
                            controller: _textController,
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: getImage, child: const Icon(Icons.image)),
                      CupertinoButton(
                          child: const Icon(Icons.send_sharp),
                          onPressed: () => sendMessage(_textController.text))
                    ],
                  )
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
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
