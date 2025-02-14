import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pakingapp/API/api.dart';

import '../homepage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  // Login##########################

  void _handleLogin() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final result = await _apiService.login(username, password);

    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed! Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login page")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  height: 400,
                  width: 300,
                  child: Card(
                    elevation: 10,
                    // color: Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "Parking Login",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),

                          // text fild ############
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: "username*",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),

                          // text filed ###########
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                labelText: "Password*",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 40),

                          // log in #############################
                          SizedBox(
                            height: 70,
                            width: 150,
                            child: InkWell(
                              onTap: () {
                                _handleLogin();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //       builder: (context) => Homepage()),
                                // );
                              },
                              child: Card(
                                color: Colors.blue,
                                child: Center(
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
