import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_app/domain/user.dart';
import 'package:flutter_app/repository/token_repository.dart';
import 'package:flutter_app/repository/token_repository.dart';
import 'package:http/http.dart' as http;


class AuthApi {
  static const String BASE_URL = 'https://chatty-toys-march-86-126-30-191.loca.lt/api';
  // TODO add your own domain here

  final _client = http.Client();

  Future<String> registerResponse(
      String registrationId,
      String challenge,
      String keyHandle,
      String clientDataJSON,
      String attestationObj) async {
    log('registerResponse - registrationId: $registrationId');

    var response = await _client.post(
        Uri.parse('$BASE_URL/registration/finish'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: jsonEncode(
          {
            'registrationId': registrationId,
            'credential': {
              'type': 'public-key',
              'id': keyHandle,
              'rawId': keyHandle,
              'response': {
                'clientDataJSON': clientDataJSON,
                'attestationObject': attestationObj,
              },
              'clientExtensionResults': {},
            }
          },
        ));
    log('registerRequest - status: ${response.statusCode}, body: ${response.body}');
    return jsonDecode(response.body)['recoveryToken'];
  }

  Future<RegisterOptions> registerRequest(String firstName, String lastName) async {
    log('registerRequest - firstName: $firstName');
    var response = await _client.post(Uri.parse('$BASE_URL/registration/start'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: jsonEncode({
            'firstName' : firstName,
            'lastName' : lastName,
            // 'username' : username,
          },
        ));
    var body = response.body;
    var status = response.statusCode;
    log('registerRequest - status: $status, body: $body');
    if (status != 200) {
      return Future.error('Server error: $status');
    }
    return _parseRegisterReq(body);
  }

  Future<SigningOptions> assertionStart(
      String userHandle, String keyHandle) async {
    log('assertionStart - userHandle: $userHandle, keyHandle: $keyHandle');
    String url = '$BASE_URL/assertion/start';
    var response = await _client.post(Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: jsonEncode({
          'userId': userHandle,
          // 'username': username,
        }));
    var body = response.body;

    var statusCode = response.statusCode;
    log('assertionStart - statusCode: $statusCode');
    var body2 = response.body;
    log('status: $statusCode, body: $body2');
    if (statusCode == 401) {
      return Future.error('Unauthorized');
    }
    if (statusCode != 200) {
      return Future.error('Server error: $statusCode');
    }
    return _parseSigningReq(body);
  }

  Future<User> assertionFinish(
      String assertionId,
      String keyHandle,
      String challenge,
      String clientData,
      String authData,
      String signature,
      String userHandle) async {
    log('assertionFinish - keyHandle: $keyHandle');
    String url = '$BASE_URL/assertion/finish';
    var response = await _client.post(Uri.parse(url),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: jsonEncode({
          'assertionId': assertionId,
          'credential': {
            'type': 'public-key',
            'id': keyHandle,
            'rawId': keyHandle,
            'response': {
              'clientDataJSON': clientData,
              'authenticatorData': authData,
              'signature': signature,
              'userHandle': userHandle
            },
            'clientExtensionResults': {},
          },
        }));
    log('assertionFinish - statusCode: ${response.statusCode}');
    if (response.statusCode == 401) {
      return Future.error('Access denied');
    }
    var cookie = response.headers['set-cookie'];
    return whoami(cookie!);
  }

  Future<User> whoami(String cookie) async {
    await TokenRepository.save(cookie);

    var response = await _client.get(
      Uri.parse('$BASE_URL/whoami'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.cookieHeader: cookie,
      },
    );
    log('whoami - status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Server error');
    }
    var json = jsonDecode(response.body);
    return User.fromJson(json);
  }

  RegisterOptions _parseRegisterReq(String responseBody) {
    var json = jsonDecode(responseBody);
    String registrationId = json['registrationId'];
    String rpId = json['publicKeyCredentialCreationOptions']['rp']['id'];
    String rpName = json['publicKeyCredentialCreationOptions']['rp']['name'];
    String username =
        json['publicKeyCredentialCreationOptions']['user']['name'];
    String userId = json['publicKeyCredentialCreationOptions']['user']['id'];
    int algoId = json['publicKeyCredentialCreationOptions']['pubKeyCredParams']
        [0]['alg'];
    String challenge = json['publicKeyCredentialCreationOptions']['challenge'];
    return RegisterOptions(
        registrationId: registrationId,
        rpId: rpId,
        rpName: rpName,
        userId: userId,
        username: username,
        algoId: algoId,
        challenge: challenge);
  }

  SigningOptions _parseSigningReq(String responseBody) {
    var json = jsonDecode(responseBody);
    String assertionId = json['assertionId'];
    String rpId = json['publicKeyCredentialRequestOptions']['rpId'];
    // TODO pass fields below
    // String allowCredentials = json['publicKeyCredentialRequestOptions']['allowCredentials'];
    // String userVerification = json['publicKeyCredentialRequestOptions']['userVerification'];
    String challenge = json['publicKeyCredentialRequestOptions']['challenge'];
    return SigningOptions(
        assertionId: assertionId, rpId: rpId, challenge: challenge);
  }
}

class SigningOptions {
  SigningOptions(
      {required this.assertionId, required this.rpId, required this.challenge});

  String assertionId;
  String rpId;
  String challenge;
}

class RegisterOptions {
  RegisterOptions(
      {required this.registrationId,
      required this.rpId,
      required this.rpName,
      required this.userId,
      required this.username,
      required this.algoId,
      required this.challenge});

  String registrationId;
  String rpId;
  String rpName;
  String username;
  String userId;
  int algoId;
  String challenge;
}
