import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oui/model/message.dart';
import 'package:oui/controller/chat_controller.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as mlkit;
import 'dart:ui' as ui;

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
  List<String> translatedMessages = [];
  StreamSubscription<List<Message>>? _streamSubscription;
  late mlkit.LanguageIdentifier languageIdentifier;
  late mlkit.OnDeviceTranslator translator;
  late String targetLanguage;
  Map<String, String> _translationCache = {};

  @override
  void initState() {
    _messageController = TextEditingController();
    languageIdentifier = mlkit.LanguageIdentifier(
        confidenceThreshold: 0.5); // la confiance de traduction
    super.initState();
    _streamSubscription =
        ChatController() // pour utiliser streamSubscription ne pas oublier d'importer 'dart:async'; pour que ca fonctionne
            .getMessagesStream(
                widget.currentUserId,
                widget
                    .selectedUserId) // widget fait référence a la classe ChatPage
            .listen((newMessages) async {
      print('Nouveaux messages: $newMessages');
      List<String> newTranslatedMessages = [];
      for (Message message in newMessages) {
        final String detectedLanguage = await detectLanguage(message);
        final String deviceLanguage = getDeviceLanguage();
        final String translation = await traduction(message);
        newTranslatedMessages.add(translation);
      }
      setState(() {
        messages = newMessages;
        translatedMessages = newTranslatedMessages;
        print('Nouveaux messages traduits: $translatedMessages');
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<List<String>> translatedMessage() async {
    List<String> result = [];
    for (Message message in messages) {
      String translatedMessage = await traduction(message);
      result.add(translatedMessage);
    }
    return result;
  }

  Future<String> detectLanguage(Message message) async {
    final identifiedLanguage =
        await languageIdentifier.identifyLanguage(message.content);
    languageIdentifier.close();
    return identifiedLanguage;
  }

  // String getDeviceLanguage(BuildContext context) {
  //   Locale deviceLocale = Localizations.localeOf(context);
  //   return deviceLocale.languageCode;
  // }

  String getDeviceLanguage() {
    Locale deviceLocale = ui.window.locale;
    return deviceLocale.languageCode;
  }

  mlkit.TranslateLanguage getTranslateLanguage(String languageCode) {
    switch (languageCode) {
      case 'en':
        return mlkit.TranslateLanguage.english;
      // Ajoutez ici les autres cas pour les langues prises en charge

      case 'fr':
        return mlkit.TranslateLanguage.french;

      case 'es':
        return mlkit.TranslateLanguage.spanish;

      case 'de':
        return mlkit.TranslateLanguage.german;

      case 'it':
        return mlkit.TranslateLanguage.italian;

      case 'pt':
        return mlkit.TranslateLanguage.portuguese;

      case 'ru':
        return mlkit.TranslateLanguage.russian;

      case 'zh':
        return mlkit.TranslateLanguage.chinese;

      case 'ja':
        return mlkit.TranslateLanguage.japanese;

      case 'ko':
        return mlkit.TranslateLanguage.korean;

      case 'ar':
        return mlkit.TranslateLanguage.arabic;

      case 'hi':
        return mlkit.TranslateLanguage.hindi;

      case 'bn':
        return mlkit.TranslateLanguage.bengali;

      case 'hr':
        return mlkit.TranslateLanguage.croatian;

      default:
        return mlkit.TranslateLanguage.arabic; // langue par défaut
    }
  }

  Future<String> traduction(Message text) async {
    final String detectedLanguage = await detectLanguage(text);
    print('Langue détectée: $detectedLanguage');
    final String D = await getDeviceLanguage();
    print('Langue du device: $D');
    final mlkit.TranslateLanguage sourceLanguage =
        getTranslateLanguage(detectedLanguage);
    final mlkit.TranslateLanguage targetLanguage = getTranslateLanguage(D);

    // Vérifiez si la langue de l'appareil et la langue du message sont les mêmes
    if (sourceLanguage == targetLanguage) {
      // Ne pas traduire, retourner le message tel quel
      return text.content;
    }

    translator = mlkit.OnDeviceTranslator(
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    // Traduire le texte
    final String translatedText = await translator.translateText(text.content);

    // Retourner le texte traduit
    return translatedText;
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

                // ... (code pour construire le widget de message)
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
                            translatedMessages[index],
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
