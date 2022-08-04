import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/settings/Addfriends.dart';
import 'package:chat_app/screens/ChatPage.dart';
import 'package:chat_app/screens/Login.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  var friends = ['friend1', 'friend2'];
  final TextEditingController _groupName = TextEditingController();
  var chatdocid;
  var friendUid;
  List<Map<String, dynamic>> memlist = [];
  var data;
  var isTapped = [];
  var currentuser = FirebaseAuth.instance.currentUser!.displayName;
  List<Map<String, dynamic>> pointList = [];

  @override
  void initState() {
    super.initState();
    getFriends();
    getCurrentUserdetails();
  }

  void getFriends() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      data = value.data();

      for (int index = 0; index < data['Friends'].length; index++) {
        pointList.add(data['Friends'][index]);
        isTapped.add(false);
      }
    });
  }

  void getCurrentUserdetails() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        memlist.add({
          'name': FirebaseAuth.instance.currentUser!.displayName,
          'uid': FirebaseAuth.instance.currentUser!.uid,
          'isAdmin': 'true'
        });
      });
    });
  }

  void createGroup() async {
    if (memlist.length <= 2) {
      const snackBar = SnackBar(
          content:
              Text("You have to add more than two members to create a group"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      String GroupId = Uuid().v1();
      await FirebaseFirestore.instance
          .collection('Groupchat')
          .doc(GroupId)
          .set({'members': memlist, 'id': GroupId});
      for (var i = 0; i < memlist.length; i++) {
        String uid = memlist[i]['uid'];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('groups')
            .doc(GroupId)
            .set({'name': _groupName.text, 'id': GroupId});
      }
      await FirebaseFirestore.instance
          .collection('Groupchat')
          .doc(GroupId)
          .collection('chats')
          .add(
              {'message': '$currentuser Created this Group', 'type': 'notify'});
      const snackBar = SnackBar(content: Text("Group created successfully"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Create Group"),
        ),
        body: friends.isNotEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: size.height / 20,
                  ),
                  Container(
                    height: size.height / 14,
                    width: size.width,
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: size.height / 14,
                      width: size.width / 1.15,
                      child: Form(
                        child: TextField(
                          controller: _groupName,
                          decoration: InputDecoration(
                            hintText: "Group Name",
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 130.0),
                    child: ElevatedButton(
                      onPressed: () {
                        createGroup();
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      child: const Text("Create Group"),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 30,
                  ),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      clipBehavior: Clip.antiAlias,
                      itemCount: pointList.length,
                      itemBuilder: (BuildContext context, int index) {
                        //  print(pointList.length);
                        return ListTile(
                          leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  pointList[index]['FriendProfileId']),
                              backgroundColor:
                                  const Color.fromARGB(255, 116, 109, 109)),
                          title: Text(pointList[index]['Friendname']),
                          trailing: GestureDetector(
                            child: isTapped[index] == false
                                ? const Icon(Icons.add)
                                : const Icon(Icons.check),
                            onTap: () {
                              setState(() {
                                isTapped[index] = true;
                              });
                              memlist.add({
                                'name': pointList[index]['Friendname'],
                                'uid': pointList[index]['Frienduid']
                              });
                              print(memlist);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Container());
  }
}
