import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oui/globale.dart';

class Utilisateur {
  //attributs
  late String id;
  late String lastname;
  late String name;
  String? avatar;
  DateTime? birthday;
  String? nickname;
  late String email;
  List? favoris;

  //variable calculé
  String get fullName {
    return name + " " + lastname;
  }

  //un ou des constructeurs
  Utilisateur(DocumentSnapshot snapshot) {
    // pour récuperer les données d'un document dans la base de données firestore
    // en gros la dans le code c'est juste un moule (constructeur) qui va permettre de créer un objet de type Utilisateur et ducoup il prend en paramètre
    //un document snapshot qui est un document de la base de données firestore et il va récupérer les données de ce document et les mettre dans les attributs de l'objet de type Utilisateur
    id = snapshot.id;
    Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
    lastname = map['NOM'];
    name = map['PRENOM'];
    email = map['EMAIL'];
    avatar = map["AVATAR"] ?? defaultImage;
    favoris = map["FAVORIS"] ?? [];
    Timestamp? timeprovisoire = map["BIRTHDAY"];
    if (timeprovisoire == null) {
      birthday = DateTime.now();
    } else {
      birthday = timeprovisoire.toDate();
    }
  }

  Utilisateur.empty() {
    id = "";
    lastname = "";
    name = "";
    email = "";
  }

  //méthode
}
