import 'package:http/http.dart' as http;
import 'package:mobileapplication1/UserData.dart';

class BackendAPI{
  final String baseURL = "http://89.58.36.232:8080";
  final String register = "/public/api/v1/account";
  final String login = "/public/api/v1/account/login";

  Future<bool> registerUser(UserData userData) async {
    var response = await http.post(
        Uri.parse(baseURL+register),
        headers: {"Content-Type": "application/json"},
        body: userData.toJson()
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }

  Future<String> loginUser(UserData userData) async {
    var response = await http.post(
        Uri.parse(baseURL+login),
        headers: {"Content-Type": "application/json"},
        body: userData.toJson()
    );
    if (response.statusCode != 200){
      return "Error";
    }
    return response.body;
  }
}