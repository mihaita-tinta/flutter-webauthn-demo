import 'package:flutter/material.dart';
import 'package:flutter_app/screens/register_new_user.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebAuthn Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RegisterNewUserScreen(),
    );
  }
}