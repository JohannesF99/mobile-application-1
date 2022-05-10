import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobileapplication1/enum/Gender.dart';
import 'package:mobileapplication1/model/LoginData.dart';
import 'package:mobileapplication1/model/UserData.dart';

class BackendAPI{
  final String _baseURL = "http://89.58.36.232:8080";
  final String _register = "/public/api/v1/account";
  final String _deleteUser = "/api/v1/account";
  final String _login = "/public/api/v1/account/login";
  final String _logout = "/public/api/v1/account/logout";
  String _getUserDataUrl(String username) => "/api/v1/user/$username";

  Future<String> registerUser(LoginData loginData) async {
    var response = await http.post(
        Uri.parse(_baseURL+_register),
        headers: {"Content-Type": "application/json"},
        body: loginData.toJson()
    );
    if (response.statusCode != 200){
      return "Register-Error!";
    }
    return "Account erfolgreich erstellt!";
  }

  Future<String> loginUser(LoginData loginData) async {
    var response = await http.post(
        Uri.parse(_baseURL+_login),
        headers: {"Content-Type": "application/json"},
        body: loginData.toJson()
    );
    if (response.statusCode != 200){
      return "Login-Error!";
    }
    return response.body;
  }

  Future<String> logoutUser(String bearerToken) async {
    var response = await http.post(
        Uri.parse(_baseURL+_logout),
        headers: {"Content-Type": "application/json"},
        body: '"$bearerToken"'
    );
    if (response.statusCode != 200){
      return "Logout-Error";
    }
    return "Abgemeldet!";
  }

  Future<UserData> getUserData(String bearerToken, String username) async {
    var response = await http.get(
        Uri.parse(_baseURL+_getUserDataUrl(username)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
    );
    if (response.statusCode != 200) {
      return UserData("Error", "Error", "Error", "Error", Gender.Unkown, "2022-01-01");
    }
    var json = UserData.fromJson(jsonDecode(response.body));
    return json;
  }

  Future<int> sendNewUserData(String bearerToken, String username, UserData userData) async {
    var response = await http.put(
      Uri.parse(_baseURL+_getUserDataUrl(username)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: userData.toJson().toString()
    );
    return response.statusCode;
  }

  Future<bool> deleteUser(LoginData loginData, String bearerToken) async {
    var response = await http.delete(
        Uri.parse(_baseURL+_deleteUser),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: loginData.toJson()
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }
}