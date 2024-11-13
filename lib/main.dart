import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  initializeDateFormatting().then(
    (_) => runApp(
      const SimpleChat(),
    ),
  );
}

class SimpleChat extends StatelessWidget {
  const SimpleChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Chat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<types.Message> _messaggi = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  @override
  void initState(){
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
  //   final response = await rootBundle.loadString('assets/messaggi.json');
  //   final messages = (jsonDecode(response) as List).map((e) => types.Message.fromJson(e as Map<String, dynamic>)).toList();
  //  setState(() {
  //     _messaggi = messages;
  //   });
    final filepath = await getFilePath();
    final file = File(filepath);
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonList = (jsonDecode(jsonString) as List).map((e) => types.Message.fromJson(e as Map<String,dynamic>)).toList();
      setState(() {
      _messaggi = jsonList;
    });
     
    }

   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chat(
        messages: _messaggi,
        onPreviewDataFetched: _handlePreviewDataFetched,
        onSendPressed: _handleSendPressed,
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
        theme: const DefaultChatTheme(
          seenIcon: Text(
            'read',
            style: TextStyle(
              fontSize: 10.0,
            ),
          )
        ),
      ),
    );
  }

  void _handlePreviewDataFetched(types.TextMessage message, types.PreviewData previewData,){
    final index = _messaggi.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messaggi[index] as types.TextMessage).copyWith(previewData: previewData,);

    setState(() {
      _messaggi[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message){
    final textMessage = types.TextMessage(author: _user, createdAt: DateTime.now().millisecondsSinceEpoch, id: const Uuid().v4(), text: message.text);

    _addMessage(textMessage);
  }

  void _addMessage(types.Message message) async {
     final filepath = await getFilePath();
      final file = File(filepath);
    setState(() {
      _messaggi.insert(0, message);
    });
    final jsonString = jsonEncode(_messaggi);
    await file.writeAsString(jsonString);
  }
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/welcome_message.json';
  }


}