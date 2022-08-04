// ignore: file_names
// ignore_for_file: prefer_typing_uninitialized_variables, no_leading_underscores_for_local_identifiers

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Addfriends extends StatefulWidget {
  const Addfriends({Key? key}) : super(key: key);

  @override
  State<Addfriends> createState() => _AddfriendsState();
}

class _AddfriendsState extends State<Addfriends> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _search = TextEditingController();
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  bool isTapped = false;
  bool isFriend = false;
  bool isSameUser = false;
  var userdata;
  var frienddata;
  var currentUser = FirebaseAuth.instance.currentUser!.uid;

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      setState(() {
        isLoading = true;
      });

      await _firestore
          .collection('users')
          .where(
            "email",
            isNotEqualTo: _auth.currentUser!.uid,
            isEqualTo: _search.text,
          )
          .limit(1)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          setState(() {
            userMap = value.docs[0].data();
            int length = userMap!['Friends'].length;
            if (userMap!['uid'] == FirebaseAuth.instance.currentUser!.uid) {
              setState(() {
                isSameUser = true;
              });
            }
            for (var i = 0; i < length; i++) {
              if (userMap!['Friends'][i]['Frienduid'] ==
                  FirebaseAuth.instance.currentUser!.uid) {
                setState(() {
                  isFriend = true;
                  isSameUser = false;
                });
              }
            }
            isLoading = false;
            isTapped = false;
          });
          _firestore.collection('users').doc(currentUser).get().then((value) {
            userdata = value.data();
          });

          const snackBar = SnackBar(
            content: Text('User Fetched Successfully'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          const snackBar = SnackBar(
            content: Text('No User Exists '),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      });
    } on FirebaseException catch (e) {
      var message = e.message;
      final snackBar = SnackBar(
        content: message == null ? Text(message!) : const Text("Error"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void addFriends() async {
    // FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(FirebaseAuth.instance.currentUser!.uid)
    //     .get()
    //     .then((DocumentSnapshot doc) {
    //   userdata = doc.data();
    // });
    FirebaseFirestore.instance
        .collection('users')
        .doc(userMap!['uid'])
        .get()
        .then((DocumentSnapshot doc) {
      frienddata = doc.data();
    });
    try {
      _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'Friends': FieldValue.arrayUnion([
          {
            'Friendname': userMap!['name'],
            'Frienduid': userMap!['uid'],
            'FriendAbout': userMap!['about'],
            'FriendProfileId': userMap!['profileId'],
          }
        ])
      });
      _firestore.collection('users').doc(userMap!['uid']).update({
        'Friends': FieldValue.arrayUnion([
          {
            'Friendname': userdata!['name'],
            'Frienduid': userdata!['uid'],
            'FriendAbout': userdata!['about'],
            'FriendProfileId': userdata!['profileId'],
          }
        ])
      });
      const snackBar = SnackBar(
        content: Text('Friend Added Successfully'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on FirebaseException catch (e) {
      var message = e.message;
      final snackBar = SnackBar(
        content:
            message == null ? const Text('Logged In') : const Text("Error"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      isTapped = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Friends"),
        backgroundColor: Colors.blue,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () {})],
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : Column(
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
                      child: TextFormField(
                        controller: _search,
                        validator: (input) {
                          if (input!.isEmpty) {
                            return "Please Enter Gmail to Search ";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
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
                ElevatedButton(
                  onPressed: onSearch,
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue)),
                  child: const Text("Search"),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                isSameUser == false
                    ? (isFriend == false
                        ? (userMap != null
                            ? ListTile(
                                leading: const Icon(Icons.account_box,
                                    color: Colors.black),
                                title: Text(
                                  userMap!['name'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(userMap!['email']),
                                trailing: GestureDetector(
                                  onTap: addFriends,
                                  child: isTapped == false
                                      ? const Icon(Icons.add,
                                          color: Colors.black)
                                      : const Icon(
                                          Icons.check,
                                          color: Colors.black,
                                        ),
                                ),
                              )
                            : Container())
                        : const Center(child: Text("Already a Friend")))
                    : const Center(
                        child: Text("You can't add yourself as friend "),
                      )
              ],
            ),
    );
  }
}
