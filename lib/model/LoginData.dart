class LoginData {
  String email;
  String username;
  String password;

  LoginData(this.email, this.username, this.password);

  String toJson(){
    return "{\n"
    "\"email\": \"" + email + "\",\n"
    "\"username\": \"" + username + "\",\n"
    "\"password\": \"" + password + "\"\n"
    "}";
  }
}