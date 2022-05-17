import 'package:flutter/material.dart';

import '../api/BackendAPI.dart';
import '../model/ContentData.dart';
import '../utils/StoreManager.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({Key? key}) : super(key: key);

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen>  {

  final _createContentController = TextEditingController();
  bool submit = false;

  @override
  void initState() {
    super.initState();
    _createContentController.addListener(() {
      setState(() {
        submit = _createContentController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 100,
            child: TextFormField(
              controller: _createContentController,
              minLines: 2,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                hintText: 'Was gibt\'s neues?',
                focusColor: Colors.red
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
                onPressed: submit ? () => _sendText() : null,
                child: const Text("Send")
            ),
          )
        ],
      ),
    );
  }

  Future<bool> _createPost(ContentData content) async {
    final token = await StorageManager.readData("token");
    final username = await StorageManager.readData("username");
    return await BackendAPI().sendNewPost(token, username, content);
  }

  Future<void> _sendText() async {
    final content = ContentData.withoutId(_createContentController.text);
    final result = await _createPost(content);
    Navigator.pop(context, result);
  }
}