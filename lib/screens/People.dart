// ignore: file_names
// ignore_for_file: prefer_const_constructors

import 'package:chat_app/AuthenticationService.dart';
import 'package:chat_app/screens/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings/Addfriends.dart';
import '../settings/CreateGroup.dart';
import '../settings/UpdateProfile.dart';
import 'ChatPage.dart';
import 'GroupChatPage.dart';

class People extends StatefulWidget {
  const People({Key? key}) : super(key: key);
  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  // var cu=FirebaseAuth.instance.currentUser!.uid;
  // final ref = FirebaseDatabase.instance.ref('users/$cu/Friends[0]');
  DocumentReference documentReference = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  var friends;
  var friendUid;
  var data;
  var urlDownload;
  int _selectedIndex = 0;

  List grouplist = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('groups')
        .get()
        .then((value) {
      grouplist = value.docs;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void imageUrl() async {
    // var uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      urlDownload = await FirebaseStorage.instance
          .ref()
          .child("profile/$friendUid")
          .getDownloadURL();
    } on Exception catch (e) {
      print(e);
      urlDownload = null;
    }
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: documentReference.snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasData) {
            getAvailableGroups();
            friends = snapshot.data!.get('Friends');
            // int index = friends.length;
            if (snapshot.connectionState == ConnectionState.active) {
              return _selectedIndex == 0
                  ? Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.blue,
                        leading: PopupMenuButton(
                            elevation: 20,
                            enabled: true,
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 1,
                                    child: GestureDetector(
                                      child: const Text("Add friends"),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Addfriends()));
                                      },
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: GestureDetector(
                                      child: const Text("Create a Group"),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateGroup()));
                                      },
                                    ),
                                  ),
                                ],
                            child: const Icon(Icons.menu)),
                        title: const Text("Your Friends 😁😎 "),
                        actions: [
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue)),
                            child: const Text(
                              "Log Out",
                            ),
                            onPressed: () {
                              context.read<AuthenticationService>().signOut();
                            },
                          ),
                        ],
                      ),
                      body: friends != null
                          ? friends.length != 0
                              ? ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  clipBehavior: Clip.antiAlias,
                                  itemCount: friends.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    friendUid = friends[index]['Frienduid'];
                                    imageUrl();
                                    return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                      friendUid: friends[index]
                                                          ['Frienduid'],
                                                      friendName: friends[index]
                                                          ['Friendname'],
                                                    )),
                                          );
                                        },
                                        child: ListTile(
                                          leading: urlDownload != null
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      friends[index]
                                                          ['FriendProfileId']),
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 116, 109, 109))
                                              : CircleAvatar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 116, 109, 109)),
                                          title: Text(
                                              friends[index]['Friendname']),
                                          subtitle: Text(
                                              friends[index]['FriendAbout']),
                                        ));
                                  },
                                )
                              : Container()
                          : Container(),
                      bottomNavigationBar: BottomNavigationBar(
                        items: const <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                            icon: Icon(Icons.chat),
                            label: 'Chats',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.group),
                            label: 'Group Chats',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.settings),
                            label: 'Settings',
                          )
                        ],
                        currentIndex: _selectedIndex,
                        selectedItemColor: Colors.blue,
                        onTap: _onItemTapped,
                      ),
                    )
                  : _selectedIndex == 1
                      ? Scaffold(
                          appBar: AppBar(
                            title: Text('Group Chat'),
                            automaticallyImplyLeading: false,
                            backgroundColor: Colors.blue,
                          ),
                          body: ListView.builder(
                            itemCount: grouplist.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GroupChatPage(
                                              groupname: grouplist[index]
                                                  ['name'],
                                              groupchatid: grouplist[index]
                                                  ['id'],
                                            )),
                                  );
                                },
                                leading: Icon(Icons.group),
                                title: Text(grouplist[index]['name']),
                              );
                            },
                          ),
                          bottomNavigationBar: BottomNavigationBar(
                            items: const <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                icon: Icon(Icons.chat),
                                label: 'Chats',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.group),
                                label: 'Group Chats',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.settings),
                                label: 'Settings',
                              ),
                            ],
                            currentIndex: _selectedIndex,
                            selectedItemColor: Colors.blue,
                            onTap: _onItemTapped,
                          ),
                        )
                      : Scaffold(
                          appBar: AppBar(
                            title: Text('Settings'),
                            automaticallyImplyLeading: false,
                            backgroundColor: Colors.blue,
                          ),
                          body: Column(
                            children: [
                              GestureDetector(
                                child: ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: const Text(
                                      "Delete your account",
                                      style: TextStyle(fontSize: 20),
                                    )),
                                onTap: () {
                                  AlertDialog alert = AlertDialog(
                                    title: const Text("Account Deletion"),
                                    content: const Text(
                                        "Your'e about to delete your account, do you want to continue?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Yes"),
                                        onPressed: () {
                                          FirebaseAuth.instance.currentUser!
                                              .delete();
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .delete();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen()));
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("No"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      )
                                    ],
                                  );
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    },
                                  );
                                },
                              ),
                              GestureDetector(
                                child: ListTile(
                                  leading: Icon(Icons.update_outlined),
                                  title: Text(
                                    'Update Your Profile',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateProfile()));
                                },
                              )
                            ],
                          ),
                          bottomNavigationBar: BottomNavigationBar(
                            items: const <BottomNavigationBarItem>[
                              BottomNavigationBarItem(
                                icon: Icon(Icons.chat),
                                label: 'Chats',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.group),
                                label: 'Group Chats',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.settings),
                                label: 'Settings',
                              ),
                            ],
                            currentIndex: _selectedIndex,
                            selectedItemColor: Colors.blue,
                            onTap: _onItemTapped,
                          ),
                        );
            }
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.none) {
            return Scaffold(body: Center(child: const Text("No connection")));
          }
          return Container();
        });
  }
}
