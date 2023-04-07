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
      // listen = méthode qui permet de récupérer les données d'un objet stream
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
          // Messages list TOUT LE EXANDED LA C DU DESIGN POUR LE CHAT
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == widget.currentUserId;

                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isMe)
                        CircleAvatar(
                          backgroundImage: NetworkImage("otherUser.avatar!"),
                        ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: isMe ? Colors.blueAccent : Colors.grey[300],
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      if (isMe)
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage("monUtilisateur.avatar!"),
                        ),
                    ],
                  ),
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
