class UserData {
  String email;
  String username;
  String password;

  UserData(this.email, this.username, this.password);

  String toJson(){
    return "{\n"
    "\"email\": \"" + email + "\",\n"
    "\"username\": \"" + username + "\",\n"
    "\"password\": \"" + password + "\"\n"
    "}";
  }
}