import 'package:chat_app/screens/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:provider/provider.dart';

import '../AuthenticationService.dart';
import 'Signup.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOME"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(
            width: 100,
            height: 100,
            child: Center(
                child: Text(
              "Chat App",
              style: TextStyle(fontSize: 20),
            )),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            width: w / 2,
            height: h / 4,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("asset/images/bg.png"), fit: BoxFit.fill),
            ),
          ),
          SizedBox(
            width: w / 6,
            height: h / 6,
          ),
          Center(
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Log in",
                    style: TextStyle(fontSize: 17),
                  ),
                )),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Don't have an account yet? ",
                style: TextStyle(fontSize: 17),
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Signup(),
                      ));
                },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 17),
                )),
          )
        ],
      ),
    );
  }
}
