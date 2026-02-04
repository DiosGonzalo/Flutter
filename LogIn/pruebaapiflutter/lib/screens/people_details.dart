import 'package:flutter/material.dart';
import 'package:pruebaapiflutter/models/people.dart';
// ignore: depend_on_referenced_packages

class PeopleDetails extends StatefulWidget {
  final People people;
  const PeopleDetails({super.key, required this.people});

  @override
  State<PeopleDetails> createState() => _PeopleDetailsState();
}

class _PeopleDetailsState extends State<PeopleDetails> {

  
  @override
  Widget build(BuildContext context) {
    People character = widget.people;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Container(
          alignment: Alignment.center,
          child: Text(character.name!.toLowerCase(),
          style: const TextStyle(color: Colors.amber,
          fontFamily: "JediFont")),
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.network("https://starwars-visualguide.com/assets/img/characters/${_searchIdByUrl(character.url!)}.jpg", fit: BoxFit.cover,)),
            Column(
              
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 50,bottom: 50),
                        child: Text("birthyear: ${character.birthYear}", 
                        style: const TextStyle(color: Colors.amber,
                        fontFamily: "JediFont")),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50,
                        bottom: 50),
                        child: Text("height: ${character.height!.toLowerCase()}cm",
                        style: const TextStyle(
                          color: Colors.amber, 
                          fontFamily: "JediFont"
                        ),),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text("mass: ${character.mass!}kg",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontFamily: "JediFont"
                        ),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text("gender: ${character.gender!.toLowerCase()}",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontFamily: "JediFont"
                        ),),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text("hair color: ${character.hairColor!.toLowerCase()}",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontFamily: "JediFont"
                        ),),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text("skin color: ${character.skinColor!.toLowerCase()}",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontFamily: "JediFont",
                        ),),
                        )
                    ],
                  )
                ],
              ),
        ],
      ),
    );
  }

  String _searchIdByUrl(String url) {
    RegExp regExp = RegExp(r"people/(\d+)/");
    final match = regExp.firstMatch(url);
    return match!.group(1)!;
  }
}