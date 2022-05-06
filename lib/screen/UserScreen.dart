import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobileapplication1/api/BackendAPI.dart';
import 'package:mobileapplication1/utils/StoreManager.dart';

import '../enum/Gender.dart';
import '../model/UserData.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key, required this.userData}) : super(key: key);

  final UserData userData;
  
  @override
  State<UserScreen> createState() => _UserScreen();
}

class _UserScreen extends State<UserScreen> {

  late UserData userData;
  bool showEdit = false;
  final nameController = TextEditingController();
  final vornameController = TextEditingController();

  @override
  void initState() {
    userData = widget.userData;
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    vornameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Benutzer"),
          actions: getEditOrSaveButton(),
          automaticallyImplyLeading: true,
        ),
        body: Row(
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
                getTextOrEditWidget(userData.name ?? "null", nameController),
                getTextOrEditWidget(userData.vorname ?? "null", vornameController),
                getTextOrDropdownWidget(userData.gender.name),
                getTextOrDatePickerWidget(userData.getBirthday()),
              ],
            ),
          ],
        ),
    );
  }

  Widget getTextOrEditWidget(String value, TextEditingController textController){
    if(showEdit) {
      return SizedBox(
        width: 50,
        child: TextField(
          controller: textController,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            hintText: value,
          ),
        ),
      );
    } else {
      return Text(value);
    }
  }

  Widget getTextOrDropdownWidget(String value){
    if(showEdit) {
      return SizedBox(
        width: 100,
        child: DropdownButton<Gender>(
          value: Gender.values.byName(value),
          items: Gender.values.map((listValue) {
            return DropdownMenuItem<Gender>(
              value: listValue,
              child: Text(listValue.name),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              userData.gender = newValue!;
            });
          },
        )
      );
    } else {
      return Text(value);
    }
  }

  Widget getTextOrDatePickerWidget(String value){
    if(showEdit) {
      return SizedBox(
          width: 100,
          child: IconButton(
            icon: const Icon(
              Icons.calendar_today,
            ),
            onPressed: () async {
              final DateTime? selected = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              );
              if (selected != null && selected != userData.birthday) {
                setState(() {
                  userData.birthday = selected;
                });
              }
            },
          )
      );
    } else {
      return Text(value);
    }
  }

  List<Widget> getEditOrSaveButton(){
    if (showEdit) {
      return [
        IconButton(
          icon: const Icon(
            Icons.cancel_outlined,
          ),
          onPressed: () async {
            nameController.clear();
            vornameController.clear();
            var token = await StorageManager.readData("token") as String;
            userData = await BackendAPI().getUserData(token, userData.username);
            setState(() {
              showEdit = !showEdit;
            });
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.save,
          ),
          onPressed: () async {
            var token = await StorageManager.readData("token") as String;
            var editedData = UserData(
              userData.username,
              userData.email,
              nameController.text,
              vornameController.text,
              userData.gender,
              userData.birthday.toString(),
            );
            var response = await BackendAPI().sendNewUserData(
              token,
              userData.username,
              editedData
            );
            if (response != 200) {
              Navigator.pop(context);
              var snackBar = const SnackBar(
                content: Text("Error bei Info-Update!"),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
            var newData = await BackendAPI().getUserData(token, userData.username);
            setState(() {
              userData = newData;
              showEdit = !showEdit;
            });
          },
        ),
      ];
    } else {
      return [
        IconButton(
          icon: const Icon(
            Icons.edit,
          ),
          onPressed: () {
            setState(() {
              showEdit = !showEdit;
            });
          },
        )
      ];
    }
  }
}