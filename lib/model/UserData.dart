import '../enum/Gender.dart';

/// Datenklasse, welche alle nötigen Informationen zur Registration und
/// Anmeldung enthält.
/// Enthält zusätzlich noch eine manuelle Methode, um ein Objekt als JSON
/// auszugeben.
class UserData {
  String username;
  String email;
  String? name;
  String? vorname;
  Gender gender;
  DateTime? birthday;

  UserData(
      this.username,
      this.email,
      this.name,
      this.vorname,
      this.gender,
      String birthdayDate
  ): birthday = DateTime.tryParse(birthdayDate);

  UserData.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        email = json['email'],
        name = json['name'],
        vorname = json['vorname'],
        gender = Gender.values.byName(json['gender']),
        birthday = DateTime.tryParse(json['birthday'].toString());

  /// Konvertiert eine Objekt der Klasse in JSON.
  /// In diesem Fall noch manuell programmiert, in späteren Iterationen soll
  /// dies automatisch geschehen.
  String toJson() => {
    '"username"': '"$username"',
    '"email"': '"$email"',
    '"name"': '"$name"',
    '"vorname"': '"$vorname"',
    '"gender"': '"${gender.name}"',
    '"birthday"': '"${birthday!.year.toString()}-${birthday!.month.toString().padLeft(2,'0')}-${birthday!.day.toString().padLeft(2,'0')}"',
  }.toString();

  String getBirthday(){
    if (birthday == null) {
      return "null";
    } else {
      return "${birthday!.year.toString()}-${birthday!.month.toString().padLeft(2,'0')}-${birthday!.day.toString().padLeft(2,'0')}";
    }
  }
}