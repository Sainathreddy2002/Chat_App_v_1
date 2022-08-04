import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/ChatPage.dart';

class UpdateProfile extends StatefulWidget {
  UpdateProfile({Key? key}) : super(key: key);

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController updatedName = TextEditingController();
  TextEditingController updatedAbout = TextEditingController();
  var userdata;
  var uid = FirebaseAuth.instance.currentUser!.uid;
  File? file;
  UploadTask? task;
  FirebaseStorage storage = FirebaseStorage.instance;
  // ignore: prefer_typing_uninitialized_variables
  var urlDownload;

  void imageUrl() async {
    urlDownload = await FirebaseStorage.instance
        .ref()
        .child("profile/$uid")
        .getDownloadURL();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'profileId': urlDownload});
    setState(() {});
  }

  void getDetails() async {
    FirebaseFirestore.instance
        .collection('profileId')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot doc) {
      userdata = doc.data();
    });
  }

  void updateProfile() async {
    if (updatedAbout.text != '' && updatedName.text != '') {
      FirebaseAuth.instance.currentUser!.updateDisplayName(updatedName.text);
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'name': updatedName.text, "about": updatedAbout.text}).then(
              (value) {
        const snackBar = SnackBar(
          content: Text('Updated Profile Successfully'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          updatedAbout.text = "";
          updatedName.text = "";
        });
      }).onError((error, stackTrace) {
        print(error);
        const snackBar = SnackBar(
          content: Text('Error'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else if (updatedAbout.text != '' && updatedName.text == '') {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"about": updatedAbout.text}).then((value) {
        const snackBar = SnackBar(
          content: Text('Updated Profile Successfully'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          updatedAbout.text = "";
          updatedName.text = "";
        });
      }).onError((error, stackTrace) {
        const snackBar = SnackBar(
          content: Text('Error'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else if (updatedAbout.text == '' && updatedName.text != '') {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"name": updatedName.text}).then((value) {
        const snackBar = SnackBar(
          content: Text('Updated Profile Successfully'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          updatedAbout.text = "";
          updatedName.text = "";
        });
      }).onError((error, stackTrace) {
        const snackBar = SnackBar(
          content: Text('Error'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    }
  }

  Future getImage() async {
    final result =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (result == null) return;
    final path = result.path;
    uploadImage();
    setState(() {
      file = File(path);
    });
  }

  Future uploadImage() async {
    if (file == null) return;
    final filename = FirebaseAuth.instance.currentUser!.uid;
    final destination = 'profile/$filename';

    task = FirebaseApi.uploadFile(destination, file!);
    if (task == null) return;
    final snapshot = await task!.whenComplete(() {
      print('Success');
    });
    //  imageUrl = await snapshot.ref.getDownloadURL();
    if (task != null) {
      print("going on");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    getDetails();
    imageUrl();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update Your Profile"),
          backgroundColor: Colors.blue,
        ),
        body: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
              child: urlDownload != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(urlDownload),
                      radius: 60,
                      child: GestureDetector(
                        onTap: getImage,
                        child: const Icon(Icons.add_a_photo_outlined),
                      ),
                    )
                  : CircleAvatar(
                      radius: 60,
                      child: GestureDetector(
                          child: const Icon(Icons.add_a_photo_outlined),
                          onTap: getImage),
                    ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Update Name",
                style: TextStyle(fontFamily: 'Raleway'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextFormField(
                controller: updatedName,
                validator: (input) {
                  if (input!.isEmpty) {
                    return "Please Enter Something ";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: userdata == null ? "Update Name" : userdata['name'],
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(20)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Update About",
                style: TextStyle(fontFamily: 'Raleway'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextFormField(
                controller: updatedAbout,
                decoration: InputDecoration(
                  hintText:
                      userdata == null ? "Update About" : userdata['about'],
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 130.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                onPressed: updateProfile,
                clipBehavior: Clip.antiAlias,
                child: const Text("Update Profile"),
              ),
            ),
          ],
        ));
  }
}
