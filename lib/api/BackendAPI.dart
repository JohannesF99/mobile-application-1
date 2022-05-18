import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mobileapplication1/enum/Gender.dart';
import 'package:mobileapplication1/model/InteractionData.dart';
import 'package:mobileapplication1/model/LoginData.dart';
import 'package:mobileapplication1/model/UserData.dart';

import '../model/ContentData.dart';

/// Verwaltet die Kommuniktation mit dem Backend der Anwendung.
/// Dazu enthält die Klasse alle Endpunkte, sowie Funktionen, welche diese
/// Endpunkte ansprechen.
/// Die OpenAPI Documentation des Backend ist
/// [hier](http://89.58.36.232:8080/swagger-ui/index.html) zu finden.
class BackendAPI{
  // API-Endpunkte des Backend
  final String _baseURL = "http://89.58.36.232:8080";
  final String _register = "/public/api/v1/account";
  final String _login = "/public/api/v1/account/login";
  final String _logout = "/public/api/v1/account/logout";
  final String _deleteUser = "/api/v1/account";
  String _getUserDataUrl(String username) => "/api/v1/user/$username";
  String _getBaseContentUrl(String username) => "/api/v1/user/$username/content";
  String _getBaseInteractionUrl(String username) => "/api/v1/user/$username/interaction";
  String _getBaseFriendsUrl(String username) => "/api/v1/user/$username/friend";

  /// Übernimmt die Benutzerdaten und registriert den Benutzer im Backend.
  /// Sollte der Status-Code nicht "200 (OK)" sein, so wird eine Fehlermeldung
  /// zurück gegeben.
  Future<String> registerUser(LoginData loginData) async {
    var response = await http.post(
        Uri.parse(_baseURL + _register),
        headers: {"Content-Type": "application/json"},
        body: loginData.toJson()
    );
    if (response.statusCode != 200){
      return "Register-Error!";
    }
    return "Account erfolgreich erstellt!";
  }

  /// Übernimmt die Benutzerdaten und meldet den Benutzer im Backend an.
  /// Sollte der Status-Code nicht "200 (OK)" sein, so wird eine Fehlermeldung
  /// zurück gegeben -
  /// bei erfolgreicher Anmeldung wird der Login-Token zurückgegeben.
  Future<String> loginUser(LoginData loginData) async {
    var response = await http.post(
        Uri.parse(_baseURL + _login),
        headers: {"Content-Type": "application/json"},
        body: loginData.toJson()
    );
    if (response.statusCode != 200){
      return "Login-Error!";
    }
    return response.body;
  }

  /// Übernimmt das Login-Token und meldet den Benutzer im Backend ab
  /// und der Token wird ungültig.
  /// Sollte der Status-Code nicht "200 (OK)" sein, so wird eine Fehlermeldung
  /// zurück gegeben.
  Future<String> logoutUser(String bearerToken) async {
    var response = await http.post(
        Uri.parse(_baseURL + _logout),
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
        Uri.parse(_baseURL + _getUserDataUrl(username)),
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
      Uri.parse(_baseURL + _getUserDataUrl(username)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: userData.toJson()
    );
    return response.statusCode;
  }

  Future<bool> deleteUser(LoginData loginData, String bearerToken) async {
    var response = await http.delete(
        Uri.parse(_baseURL + _deleteUser),
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

  Future<bool> sendNewPost(String bearerToken, String username, ContentData contentData) async {
    var response = await http.post(
        Uri.parse(_baseURL + _getBaseContentUrl(username)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: contentData.toJsonWithoutId()
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }

  Future<List<ContentData>> getUserContent(String bearerToken, String username) async {
    var response = await http.get(
        Uri.parse(_baseURL + _getBaseContentUrl(username) + '/all'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
        }
    );
    if (response.statusCode != 200){
      return [];
    }
    return List<ContentData>.from(
        jsonDecode(response.body).map((i) =>
            ContentData.fromJson(i))
    );
  }

  Future<bool> deleteUserContent(String bearerToken, String username, int contentId) async {
    var response = await http.delete(
        Uri.parse(_baseURL + _getBaseContentUrl(username) + '/$contentId'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
        }
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }

  Future<InteractionData?> getInteractionDataForContent(String bearerToken, String username, int contentId) async {
    var response = await http.get(
        Uri.parse(_baseURL + _getBaseInteractionUrl(username) + '/$contentId'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
        }
    );
    if (response.statusCode != 200){
      return null;
    }
    return InteractionData.fromJson(jsonDecode(response.body));
  }

  Future<bool> likeContent(String bearerToken, String username, int contentId) async {
    var response = await http.post(
        Uri.parse(_baseURL + _getBaseInteractionUrl(username) + '/$contentId/like'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
        }
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }

  Future<bool> dislikeContent(String bearerToken, String username, int contentId) async {
    var response = await http.post(
        Uri.parse(_baseURL + _getBaseInteractionUrl(username) + '/$contentId/dislike'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
        }
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }

  Future<bool> removeInteraction(String bearerToken, String username, int contentId) async {
    var response = await http.delete(
        Uri.parse(_baseURL + _getBaseInteractionUrl(username) + '/$contentId/remove'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
        }
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }

  Future<bool> addFriend(String bearerToken, String username, String friendName) async {
    var response = await http.post(
        Uri.parse(_baseURL + _getBaseFriendsUrl(username)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      body: friendName
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }

  Future<bool> removeFriend(String bearerToken, String username, String friendName) async {
    var response = await http.delete(
        Uri.parse(_baseURL + _getBaseFriendsUrl(username)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: friendName
    );
    if (response.statusCode != 200){
      return false;
    }
    return true;
  }

  Future<List<String>> getFriendsList(String bearerToken, String username) async {
    var response = await http.get(
        Uri.parse(_baseURL + _getBaseFriendsUrl(username) + '/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        }
    );
    if (response.statusCode != 200){
      return [];
    }
    return List<String>.from(json.decode(response.body));
  }

  Future<List<ContentData>> getFriendsContent(String bearerToken, String username) async {
    var response = await http.get(
        Uri.parse(_baseURL + _getBaseContentUrl(username) + '/friends'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
        }
    );
    if (response.statusCode != 200){
      return [];
    }
    return List<ContentData>.from(
        jsonDecode(response.body).map((i) =>
            ContentData.fromJson(i))
    );
  }
}