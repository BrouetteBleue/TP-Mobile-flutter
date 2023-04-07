import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oui/controller/FirestoreHepler.dart';
import 'package:oui/globale.dart';
import 'package:oui/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:oui/view/chat_view.dart';
import 'package:oui/view/userList_view.dart';

class ListPersonn extends StatefulWidget {
  const ListPersonn({Key? key}) : super(key: key);

  @override
  State<ListPersonn> createState() => _ListPersonnState();
}

class _ListPersonnState extends State<ListPersonn> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper().cloudUsers.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData ||
              snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          List documents = snap.data?.docs ?? [];
          if (documents.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else {
            return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  Utilisateur otherUser = Utilisateur(documents[index]);
                  if (monUtilisateur.id == otherUser.id) {
                    return Container();
                  } else {
                    return Card(
                      elevation: 5,
                      color: Colors.purple,
                      child: ListTile(
                        onTap: () {
                          //on ouvre la page de chat
                          Navigator.pushNamed(context, "chatPage", arguments: {
                            "currentUserId": monUtilisateur.id,
                            "selectedUserId": otherUser.id
                          });
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ChatPage(
                          //         currentUserId: monUtilisateur.id,
                          //         selectedUserId: otherUser.id),
                          //   ),
                          // );
                        },
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(otherUser.avatar!),
                        ),
                        title: Text(otherUser.fullName),
                        subtitle: Text(otherUser.email),
                      ),
                    );
                  }
                });
          }
        });
  }
}
