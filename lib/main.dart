import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart'
    as io; //messo minuscolo per risolvere un problema che non volevo avere

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
        title: "Flutter Test",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: "La grande Chat"));
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
    id: '82ejf58-a484-4a89-ae75-a22bf8d6f3acertgertert', firstName:"Miriam", lastName :"Santi"
  ); 
  late io.Socket socket;
  final StreamController<String> _stControl = StreamController<String>();
  Stream<String> get msgStream => _stControl.stream;
  String toSend = "no";

  @override
  void initState() {
    super.initState();
    socket = io.io("http://10.1.0.6:3000", <String, dynamic>{
      "transports": ["websocket"]
    });
    socket.on("connect", (_) {});

    socket.on('message', (data) {
      final messageData = jsonDecode(data);
      final receivedMessage = types.TextMessage.fromJson(messageData);

      final otherUser = const types.User(
        id: 'other-user-id',
      );

      final newMessage = receivedMessage.copyWith(author: otherUser);
      addMessage(newMessage);
      // setState(() {
      //   _messaggi.insert(0, newMessage);

      // });
    });
    _loadMessages();
  }

  @override
  void dispose() {
    socket.disconnect();
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
          "read",
          style: TextStyle(fontSize: 10.0),
        )),
      ),
    );
  }

  Future<void> _checkExistence() async {
    final file = File(await _getFilePath());
    if (await file.exists()) {
    } else {
      final response = await rootBundle.loadString("assets/messaggi.json");
      final messages = (jsonDecode(response) as List)
          .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
          .toList();
      _messaggi = messages;
      final jsonString = jsonEncode(_messaggi);
      await file.writeAsString(jsonString);
    }
    return;
  }

  void _loadMessages() async {
    await _checkExistence();
    final file = File(await _getFilePath());
    final messages = (jsonDecode(await file.readAsString()) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messaggi = messages;
    });
  }

  void _handlePreviewDataFetched(
      types.TextMessage message, types.PreviewData previewData) {
    final index = _messaggi.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messaggi[index] as types.TextMessage)
        .copyWith(previewData: previewData);
    sendMessage("a");
    setState(() {
      _messaggi[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
   
    if (socket.connected && message.text.startsWith("/room")) 
    {
      socket.emit("join-room", message.text.substring(5));
    } else {
       final textMessage = types.TextMessage(
        author: _user,
        id: const Uuid().v4(),
        text: message.text,
        createdAt: DateTime.now().millisecondsSinceEpoch);
      await prepMsg(textMessage);
      sendMessage(toSend);
      setState(() {
        _loadMessages();
      });
    }
  }

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/messaggi.json";
  }

  Future<void> addMessage(types.Message message) async {
    if (!_messaggi.any((msg) => msg.id == message.id) || (true == true)) {
    _messaggi.insert(0, message);
    final jsonString = jsonEncode(_messaggi);
    final file = File(await _getFilePath());
    await file.writeAsString(jsonString);

    setState(() {
      _loadMessages();
    });
    }
  }

  Future<void> prepMsg(types.Message message) async {
    _messaggi.insert(0, message);
    final jsonString = jsonEncode(_messaggi);
    final file = File(await _getFilePath());
    await file.writeAsString(jsonString);
    final jsonString2 = jsonDecode(jsonString)[0];

    toSend = jsonEncode(jsonString2);
  }

  Future<void> sendMessage(String message) async {
    socket.emit("sendMessage", message);
  }
}
