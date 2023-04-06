import 'package:digitaldschool/main.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{

  late AnimationController animatation;

  @override
  void initState() {
    animatation = AnimationController(
        vsync: this,
      duration: const Duration(seconds: 10)
    )
    ..forward()
    ..addListener(() {
      setState(() {

      });
    })
    ..addStatusListener((status) {
       if(status == AnimationStatus.completed){
         Navigator.push(context, MaterialPageRoute(
             builder: (context){
               return const MyHomePage(title: 'Coucou',);
             }
         ));
       }
    });



    super.initState();
  }

  @override
  void dispose() {
    animatation.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Flexible(
          child: Column(
            children: [
              //afficher une lottiefiles
              Lottie.asset("assets/welcome.json"),
              
              
              //barre de chargerment
              LinearProgressIndicator(
                minHeight: 5,
                value: animatation.value,
                valueColor: const AlwaysStoppedAnimation(Colors.green),
              )
            ],
          ),
        )
    );
  }
}

