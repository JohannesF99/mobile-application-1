import 'package:http/http.dart' as http;
import 'package:mobileapplication1/model/UserData.dart';

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

  /// Übernimmt die Benutzerdaten und registriert den Benutzer im Backend.
  /// Sollte der Status-Code nicht "200 (OK)" sein, so wird eine Fehlermeldung
  /// zurück gegeben.
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

  /// Übernimmt die Benutzerdaten und meldet den Benutzer im Backend an.
  /// Sollte der Status-Code nicht "200 (OK)" sein, so wird eine Fehlermeldung
  /// zurück gegeben -
  /// bei erfolgreicher Anmeldung wird der Login-Token zurückgegeben.
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

  /// Übernimmt das Login-Token und meldet den Benutzer im Backend ab
  /// und der Token wird ungültig.
  /// Sollte der Status-Code nicht "200 (OK)" sein, so wird eine Fehlermeldung
  /// zurück gegeben.
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