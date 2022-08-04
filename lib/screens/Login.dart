// ignore_for_file: prefer_const_constructors, file_names, use_build_context_synchronously

import 'package:chat_app/AuthenticationService.dart';
import 'package:chat_app/screens/ForgotPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'Signup.dart';
import 'People.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String _email = " ";
  String _password = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("asset/images/Chatbg.jpg"), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Login"),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Form(
              key: _formkey,
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        validator: (input) {
                          if (input!.isEmpty) {
                            return "Provide an Email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSaved: (input) => _email = input!,
                      ),
                    ),
                  ),
                  SizedBox(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      validator: (input) {
                        if (input!.isEmpty) {
                          return "Provide an Password";
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSaved: (input) => _password = input!,
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 100),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      onPressed: signIn,
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Sign In"),
                          SizedBox(child: Icon(Icons.lock_open_outlined))
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 100),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                      onPressed: navigateToSignUp,
                      clipBehavior: Clip.antiAlias,
                      child: Text("Sign Up"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 140.0, vertical: 8),
                    child: GestureDetector(
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPassword()));
                      },
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  dynamic user;
  dynamic title;
  Future<void> signIn() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      try {
        context
            .read<AuthenticationService>()
            .signIn(email: _email, password: _password);
        // user = await FirebaseAuth.instance
        //     .signInWithEmailAndPassword(email: _email, password: _password);
        users
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .limit(1)
            .get()
            .then((QuerySnapshot querysnapshot) {
          if (querysnapshot.docs.isEmpty) {
            users.doc(FirebaseAuth.instance.currentUser!.uid).set({
              'name': FirebaseAuth.instance.currentUser!.displayName,
              'email': FirebaseAuth.instance.currentUser!.email,
              'uid': FirebaseAuth.instance.currentUser!.uid,
              'Friends': [],
              'about': '',
              'profileId': ''
            });
          }
        }).catchError((onError) {
          var message = onError.message;
          final snackBar = SnackBar(
            content: message != null ? Text(message) : const Text("Error"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
        final snackBar = SnackBar(
          content: const Text('Logged In'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => People()));
      } on FirebaseAuthException catch (e) {
        var message = e.message;
        var snackBar = SnackBar(
          content: message != null ? Text(message) : const Text("Error"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  void navigateToSignUp() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Signup(),
        ));
  }
}
