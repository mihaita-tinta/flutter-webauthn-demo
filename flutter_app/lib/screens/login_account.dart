import 'package:fido2_client/fido2_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/client/auth_api.dart';
import 'package:flutter_app/domain/user.dart';
import 'package:flutter_app/repository/user_repository.dart';
import 'package:flutter_app/screens/welcome.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String displayName = '';
  final AuthApi _api = AuthApi();
  final Fido2Client fido = Fido2Client();

  @override
  void initState() {
    super.initState();
  }

  void initName() async {
    displayName = await UserRepository.getDisplayName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Sign up'),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                    onPressed: () async {
                      User u = await login();
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomeScreen(user: u)),
                        );
                      }
                    },
                  label: Text(isLoading ? 'Loading' : 'Login as $displayName'),
                  icon: const Icon(Icons.fingerprint,
                    color: Colors.white),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Future<User> login() async {


    return _api.whoami('cookie');
  }
}
