/// Datenklasse, welche alle nötigen Informationen zur Registration und
/// Anmeldung enthält.
/// Enthält zusätzlich noch eine manuelle Methode, um ein Objekt als JSON
/// auszugeben.
class UserData {
  String email;
  String username;
  String password;

  UserData(this.email, this.username, this.password);

  /// Konvertiert eine Objekt der Klasse in JSON.
  /// In diesem Fall noch manuell programmiert, in späteren Iterationen soll
  /// dies automatisch geschehen.
  String toJson(){
    return "{\n"
    "\"email\": \"" + email + "\",\n"
    "\"username\": \"" + username + "\",\n"
    "\"password\": \"" + password + "\"\n"
    "}";
  }
}