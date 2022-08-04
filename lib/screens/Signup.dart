// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:chat_app/AuthenticationService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
// import 'package:test_flutter/screens/Login.dart';
import 'Login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SingupState();
}

class _SingupState extends State<Signup> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String _email = " ";
  String _password = "";
  String _name = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.blue,
      ),
      body: Form(
          key: _formkey,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                child: TextFormField(
                  validator: (input) {
                    if (input!.isEmpty) {
                      return "Provide an Name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (input) => _name = input!,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
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
              ),
              ElevatedButton(
                onPressed: signUp,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                child: const Text("Sign Up"),
              )
            ],
          )),
    );
  }

  // ignore: prefer_typing_uninitialized_variables
  var result;
  Future<void> signUp() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      try {
        context
            .read<AuthenticationService>()
            .signUp(email: _email, password: _password);
        FirebaseAuth.instance.currentUser!.updateDisplayName((_name));
        const snackBar = SnackBar(
          content: Text('Account Created'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } on FirebaseAuthException catch (e) {
        var message = e.message;
        var snackBar = SnackBar(
          content: message != null ? Text(message) : const Text("Error"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        print(e.toString());
      }
    }
  }
}
