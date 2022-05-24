import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/model/UserData.dart';
import 'package:mobileapplication1/utils/StoreManager.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key, required this.username}) : super(key: key);

  final String username;

  @override
  State<StatefulWidget> createState() => _UserInfoScreen();
}

class _UserInfoScreen extends State<UserInfoScreen> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserDetails(widget.username),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator()
            );
          }
          if (snapshot.hasData) {
            final userData = snapshot.data as UserData;
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width/1.5,
                child: Container(
                  decoration: ShapeDecoration(
                      color: Theme.of(context).backgroundColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0))
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            children: [
                              const ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                ),
                                child: Image(
                                  image: AssetImage('images/settings.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                left: 10,
                                bottom: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(200.0),
                                  child: Image(
                                    width: MediaQuery.of(context).size.width/6,
                                    image: const AssetImage('images/profilbild.jpg'),
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Username:"),
                                  Text("E-Mail:"),
                                  Text("Name:"),
                                  Text("Vorname:"),
                                  Text("Geschlecht:"),
                                  Text("Geburtstag:"),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(userData.username),
                                  Text(userData.email),
                                  Text(userData.name ?? "null"),
                                  Text(userData.vorname?? "null"),
                                  Text(userData.gender.name),
                                  Text(userData.getBirthday()),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                  ),
                ),
              ),
            );
          } else {
            return const Center(
                child: CircularProgressIndicator()
            );
          }
        }
    );
  }

  Future<UserData> _getUserDetails(String username) async {
    final token = await StorageManager.readData("token");
    final userData = await BackendAPI().getUserData(token, username);
    return userData;
  }
}