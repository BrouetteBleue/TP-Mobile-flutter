import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late String id;
  late String senderId;
  late String receiverId;
  late String content;
  late DateTime timestamp;

  Message(DocumentSnapshot snapshot) {
    id = snapshot.id; //id du document
    Map<String, dynamic> map = snapshot.data()
        as Map<String, dynamic>; // la il récupère les données du document
    senderId = map['senderId'];
    receiverId = map['receiverId'];
    content = map['content'];
    timestamp = (map['timestamp'] as Timestamp).toDate();
  }

  Message.empty() {
    id = "";
    senderId = "";
    receiverId = "";
    content = "";
    timestamp = DateTime.now();
  }
}
