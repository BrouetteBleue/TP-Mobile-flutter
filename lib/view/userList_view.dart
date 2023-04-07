import 'package:flutter/material.dart';
import 'package:oui/controller/chat_controller.dart';
import 'package:oui/model/utilisateur.dart';
import 'package:oui/view/chat_view.dart';
import 'package:oui/controller/FirestoreHepler.dart';

class UsersListPage extends StatefulWidget {
  final String currentUserId;

  UsersListPage({required this.currentUserId});

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users List"),
      ),
      body: FutureBuilder<List<Utilisateur>>(
        future: FirestoreHelper().getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text("Erreur: ${snapshot.error}");
          }

          List<Utilisateur> users = snapshot.data!;
          users.removeWhere((user) =>
              user.id ==
              widget.currentUserId); // Remove current user from the list

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              Utilisateur user = users[index];

              return ListTile(
                title: Text(user.fullName),
                subtitle: Text(user.email),
                onTap: () {
                  Navigator.pushNamed(context, "chatPage");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        currentUserId: widget.currentUserId,
                        selectedUserId: user.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
