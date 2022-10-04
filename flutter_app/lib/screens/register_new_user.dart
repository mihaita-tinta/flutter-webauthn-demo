import 'dart:developer';

import 'package:fido2_client/fido2_client.dart';
import 'package:fido2_client/registration_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/client/auth_api.dart';
import 'package:flutter_app/domain/user.dart';
import 'package:flutter_app/repository/key_repository.dart';
import 'package:flutter_app/repository/user_repository.dart';
import 'package:flutter_app/screens/login_account.dart';
import 'package:flutter_app/toast/toast.dart';

class RegisterNewUserScreen extends StatefulWidget {
  const RegisterNewUserScreen({Key? key}) : super(key: key);

  @override
  State<RegisterNewUserScreen> createState() => _RegisterNewUserScreenState();
}

class _RegisterNewUserScreenState extends State<RegisterNewUserScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool isLoading = false;
  final AuthApi _api = AuthApi();
  final Fido2Client fido = Fido2Client();

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
      body: SingleChildScrollView(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Please complete the fields below:',
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextField(
                    // style: MyTextStyle(
                    //   colorNew: appColors.lightColor,
                    //   fontWeightNew: FontWeight.w500,
                    //   size: ResponsiveFlutter.of(context).fontSize(1.9),
                    // ),
                    controller: firstNameController,
                    scrollPadding: EdgeInsets.zero,
                    expands: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'First Name',
                      isDense: true,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: TextField(
                    // style: MyTextStyle(
                    //   colorNew: appColors.lightColor,
                    //   fontWeightNew: FontWeight.w500,
                    //   size: ResponsiveFlutter.of(context).fontSize(1.9),
                    // ),
                    controller: lastNameController,
                    scrollPadding: EdgeInsets.zero,
                    expands: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.black)),
                      hintText: 'Last Name',
                      isDense: true,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                    onPressed: () async {
                      String firstName = firstNameController.value.text;
                      String lastName = lastNameController.value.text;
                      if (firstName.isEmpty) {
                        ToastUtil.showToast('First Name is required');
                      } else if (lastName.isEmpty) {
                        ToastUtil.showToast('Last Name is required');
                      } else {
                        try {
                          await registerNewUser(firstName, lastName);
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          }
                        } catch (e) {
                          ToastUtil.showError('Error registering user');
                        }
                      }
                    },
                  label: Text(isLoading ? 'Loading' : 'Create a new account'),
                  icon: const Icon(Icons.fingerprint,
                    color: Colors.white),
                ),
                const Text(
                  'or',
                ),
                ElevatedButton(
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                  },
                  child: const Text('Already have an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> registerNewUser(String firstName, String lastName) async {

    String displayName = '$firstName $lastName';
    await UserRepository.saveDisplayName(displayName);
    RegisterOptions _registerOptions = await _api.registerRequest(firstName, lastName);
    String userId = _registerOptions.userId;
    Future<RegistrationResult> res = fido.initiateRegistration(_registerOptions.challenge, userId, {
      'username': _registerOptions.username,
      'rpDomain': _registerOptions.rpId,
      'rpName': _registerOptions.rpName,
      'coseAlgoValue': '${_registerOptions.algoId}',
    });
    res.catchError((e) {
      ToastUtil.showError('registerNewUser - error $e');
      isLoading = false;
    });
    res.timeout(const Duration(seconds: 20));
    log('registerNewUser - waiting for result');

    RegistrationResult r = await res;
    await KeyRepository.storeKeyHandle(r.keyHandle);
    await KeyRepository.storeUserHandle(userId);
    await _api.registerResponse(_registerOptions.registrationId,
        _registerOptions.challenge, r.keyHandle, r.clientData, r.attestationObj);

    ToastUtil.showToast('Successfully created your account $displayName');
  }
}
