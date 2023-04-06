import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitaldschool/controller/FirestoreHepler.dart';
import 'package:digitaldschool/globale.dart';
import 'package:digitaldschool/model/utilisateur.dart';
import 'package:flutter/material.dart';

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
        builder: (context,snap){
        List documents = snap.data?.docs ?? [];
        if(documents.isEmpty){
          return const Center(
              child: CircularProgressIndicator.adaptive()
          );
        } else
          {
            return ListView.builder(
              itemCount: documents.length,
                itemBuilder: (context,index) {
                  Utilisateur otherUser = Utilisateur(documents[index]);
                  if (monUtilisateur.id == otherUser.id) {
                    return Container();
                  }
                  else {
                    return Card(
                      elevation: 5,
                      color: Colors.purple,
                      child: ListTile(
                        onTap: (){
                          //ouvrir une nouvller page de chat
                          print("message");
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
                }
            );
          }

        }
    );
  }
}

