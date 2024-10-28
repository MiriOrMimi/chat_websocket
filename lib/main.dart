import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

void main() {
  initializeDateFormatting().then(
    (_) => runApp(const Chat()),
  );
  
}

class Chat extends StatelessWidget {
  const Chat({super.key});  // per identificare univocamente tutti i widget

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

  final String title; // non ne conosco il valore al momento della dichiarazione sarà inizzializzato runtime a differenza del const che viene inizializzato subito

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<types.Message> _messaggi = [];
  final _user = const types.User(
    id:'213123123jj312j3bjk2b3ekj12hek3juhekhk'
  );
  @override
 void initState() {
    super.initState();
    _loadMessages();
  }
  
  @override
  Widget build(BuildContext context) {
    
    throw UnimplementedError();
  }





