//C'est de faire les opérations sur la base de donnée

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitaldschool/model/utilisateur.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreHelper {

  //attributs
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final cloudUsers = FirebaseFirestore.instance.collection("UTILISATEURS");
  final cloudMessage = FirebaseFirestore.instance.collection("MESSAGES");




  //méthode

  //créer un utilisateur dans la base
   Future<Utilisateur> Inscription(String email, String password, String nom , String prenom) async{
    //creer dans l'authentification
      UserCredential credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = credential.user;
      if (user == null) {return Future.error("error");}
      else {
        String uid = user.uid;
        Map<String,dynamic> map = {
          "NOM": nom,
          "PRENOM":prenom,
          "EMAIL": email,
          "FAVORIS":[]
        };
        //stocker dans la partie du firestore database
        addUser(uid,map);
        return getUser(uid);

      }



  }


  //Récupérer les infos de l'utilisateur
  Future<Utilisateur> getUser(String id) async {
     DocumentSnapshot snapshots =await cloudUsers.doc(id).get();
     return Utilisateur(snapshots);

  }


//se connecter à un compte
  Future<Utilisateur>Connect(String email, String password) async{
     UserCredential credential = await auth.signInWithEmailAndPassword(email: email, password: password);
     User? user = credential.user;
     if(user == null){return Future.error("erreur");}
     else {
       String uid = user.uid;
       return getUser(uid);
     }



  }

  //ajouter un utilisateur
 addUser(String id, Map<String,dynamic> map){
    cloudUsers.doc(id).set(map);

 }


//supprimer un utlisateur



//mise à jour des infos utlisateurs
 updateUser(String id,Map<String,dynamic> data){
    cloudUsers.doc(id).update(data);
 }


//ajouter un message



//supprimer un message


// upload une image
Future<String>stockageImage({required String dossier,required String dossierPersonnel,required String nameImage, required Uint8List bytesImage}) async{
     String url = "";
     TaskSnapshot taskSnapshot = await storage.ref("$dossier/$dossierPersonnel/$nameImage").putData(bytesImage);
     url = await taskSnapshot.ref.getDownloadURL();
     return url;
   }






}