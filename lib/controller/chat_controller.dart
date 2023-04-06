import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oui/model/message.dart';

class ChatController {
  Future<void> sendMessage(Message message) async {
    CollectionReference conversations =
        FirebaseFirestore.instance.collection('conversations');

    String conversationId;
    if (message.senderId.compareTo(message.receiverId) < 0) {
      conversationId = '${message.senderId}-${message.receiverId}';
    } else {
      conversationId = '${message.receiverId}-${message.senderId}';
    }

    final conversationRef = conversations.doc(conversationId);
    final messagesRef = conversationRef.collection('messages');

    return messagesRef.add({
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'content': message.content,
      'timestamp': message.timestamp,
    }).then((_) => null);
  }

  Stream<List<Message>> getMessagesStream(String senderId, String receiverId) {
    CollectionReference conversations =
        FirebaseFirestore.instance.collection('conversations');

    String conversationId;
    if (senderId.compareTo(receiverId) < 0) {
      conversationId = '$senderId-$receiverId';
    } else {
      conversationId = '$receiverId-$senderId';
    }

    final conversationRef = conversations.doc(conversationId);
    final messagesRef = conversationRef.collection('messages');

    print('Conversation ID : $conversationId'); // Ajout de cette ligne

    return messagesRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      List<Message> messagesList =
          querySnapshot.docs.map((doc) => Message(doc)).toList();
      print('Messages récupérés : ${messagesList.length}');
      return messagesList;
    });
  }
}
