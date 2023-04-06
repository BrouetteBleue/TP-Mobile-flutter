import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oui/model/message.dart';
import 'package:oui/controller/chat_controller.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String selectedUserId;

  ChatPage({required this.currentUserId, required this.selectedUserId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late TextEditingController _messageController;
  List<Message> messages = [];
  StreamSubscription<List<Message>>? _streamSubscription;

  @override
  void initState() {
    _messageController = TextEditingController();
    super.initState();
    _streamSubscription =
        ChatController() // pour utiliser streamSubscription ne pas oublier d'importer 'dart:async'; pour que ca fonctionne
            .getMessagesStream(
                widget.currentUserId,
                widget
                    .selectedUserId) // widget fait référence a la classe ChatPage
            .listen((newMessages) {
      setState(() {
        messages = newMessages;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                Message message = messages[index];
                bool isSentByMe = message.senderId == widget.currentUserId;

                // Personnalisez l'apparence des messages en fonction de `isSentByMe`
                // Par exemple, vous pouvez aligner les messages envoyés par l'utilisateur à droite
                // et les messages de l'autre utilisateur à gauche
                return ListTile(
                  title: Text(message.content),
                  subtitle: Text(message.timestamp.toString()),
                  trailing: isSentByMe ? Icon(Icons.done_all) : null,
                );
              },
            ),
          ),
          // Message input and send button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Type a message"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      Message message = Message.empty();
                      message.senderId = widget.currentUserId;
                      message.receiverId = widget.selectedUserId;
                      message.content = _messageController.text;
                      message.timestamp = DateTime.now();

                      await ChatController().sendMessage(message);
                      print('Message envoyé: ${_messageController.text}');
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
