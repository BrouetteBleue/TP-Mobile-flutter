import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oui/model/message.dart';

class ChatController {
  Future<void> sendMessage(Message message) async {
    CollectionReference conversations = FirebaseFirestore.instance
        .collection('conversations'); // on récupère la collection conversations

    String
        conversationId; // id de la conversation composé de l'id de l'expéditeur et du destinataire ex (identifiantExpéditeur-identifiantDestinataire)
    if (message.senderId.compareTo(message.receiverId) < 0) {
      // on compare les id des deux utilisateurs pour savoir qui est l'expéditeur et qui est le destinataire et on crée l'id de la conversation en fonction
      conversationId = '${message.senderId}-${message.receiverId}';
    } else {
      conversationId = '${message.receiverId}-${message.senderId}';
    }

    final conversationRef = conversations.doc(conversationId);
    final messagesRef = conversationRef.collection(
        'messages'); // on récupère la collection messages de la conversation

    return messagesRef.add({
      // on ajoute le message dans la collection messages
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'content': message.content,
      'timestamp': message.timestamp,
    }).then((_) =>
        null); // on retourne null pour dire que l'opération s'est bien déroulée (apart si on veut retourner un message ou une erreur)
  }

  Stream<List<Message>> getMessagesStream(String senderId, String receiverId) {
    CollectionReference conversations = FirebaseFirestore.instance
        .collection('conversations'); // on récupère la collection conversations

    String conversationId;
    if (senderId.compareTo(receiverId) < 0) {
      // on compare les id des deux utilisateurs pour savoir qui est l'expéditeur et qui est le destinataire et on crée l'id de la conversation en fonction
      conversationId = '$senderId-$receiverId';
    } else {
      conversationId = '$receiverId-$senderId';
    }

    final conversationRef = conversations.doc(conversationId);
    final messagesRef = conversationRef.collection('messages');

    print('Conversation ID : $conversationId'); // console log

    return messagesRef
        .orderBy('timestamp',
            descending:
                true) // on trie les messages par ordre décroissant de temps
        .snapshots() // je sais plus trop ce que ça fait mais c'est important
        .map((querySnapshot) {
      List<Message> messagesList =
          querySnapshot.docs.map((doc) => Message(doc)).toList();
      print('Messages récupérés : ${messagesList.length}');
      return messagesList;
    });
  }
}
