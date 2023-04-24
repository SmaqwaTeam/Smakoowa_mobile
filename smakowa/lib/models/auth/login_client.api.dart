import 'dart:io';
// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smakowa/main.dart';
import 'package:smakowa/utils/endpoints.api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginApiClient extends GetxController {
  final Future<SharedPreferences> _userData = SharedPreferences.getInstance();

  final storage = new FlutterSecureStorage();

  Future<void> login(String name, String password) async {
    Map data = {
      'userName': name,
      'password': password,
    };
    // var body = json.encode(data);
    try {
      final responce = await http.post(
        Uri.parse(ApiEndPoints.baseUrl + '/api/Account/Login'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'text/plain',
        },
        body: jsonEncode(data),
      );

      // print(responce.statusCode);
      if (responce.statusCode == 200) {
        final decode = jsonDecode(responce.body);
        var token = decode['content']['token'];

        await storage.write(key: 'access', value: token);

        showDialog(
            context: Get.context!,
            builder: (context) {
              return AlertDialog(
                title: Text("Success"),
                content: Text(decode['message'].toString()),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.off(const MyHomePage());
                    },
                    child: Text('OK'),
                  )
                ],
              );
            });
      } else {
        throw jsonDecode(responce.body)['message'];
      }
    } catch (e) {
      print(e.toString());

      showDialog(
          context: Get.context!,
          builder: (context) {
            return SimpleDialog(
              title: Text('Error'),
              contentPadding: const EdgeInsets.all(20),
              children: [Text(e.toString())],
            );
          });
    }
  }
}
