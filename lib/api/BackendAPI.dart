import 'package:http/http.dart' as http;
import 'package:mobileapplication1/model/UserData.dart';

class BackendAPI{
  final String _baseURL = "http://89.58.36.232:8080";
  final String _register = "/public/api/v1/account";
  final String _login = "/public/api/v1/account/login";
  final String _logout = "/public/api/v1/account/logout";

  Future<String> registerUser(UserData userData) async {
    var response = await http.post(
        Uri.parse(_baseURL+_register),
        headers: {"Content-Type": "application/json"},
        body: userData.toJson()
    );
    if (response.statusCode != 200){
      return "Register-Error!";
    }
    return "Account erfolgreich erstellt!";
  }

  Future<String> loginUser(UserData userData) async {
    var response = await http.post(
        Uri.parse(_baseURL+_login),
        headers: {"Content-Type": "application/json"},
        body: userData.toJson()
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
        body: bearerToken
    );
    if (response.statusCode != 200){
      return "Logout-Error";
    }
    return "Abgemeldet!";
  }
}