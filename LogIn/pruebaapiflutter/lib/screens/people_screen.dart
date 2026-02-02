import 'package:flutter/material.dart';
import 'package:pruebaapiflutter/models/people_list_response.dart';
import 'package:pruebaapiflutter/screens/people_details.dart';
// ignore: depend_on_referenced_packages

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late Future<PeopleListResponse> peopleResponse;
  
  get http => null;

  @override
  void initState() {
    super.initState();
    peopleResponse = fetchPeopleList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 20, 20, 20),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Container(
          alignment: Alignment.center,
          child: const Text(
            "STAR WHAT???",
            style: TextStyle(color: Colors.amber, fontFamily: "JediFont"),
          ),
        ),
      ),
      body: FutureBuilder<PeopleListResponse>(
          future: peopleResponse,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Character list",
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 22,
                          fontFamily: "JediFont"),
                      textAlign: TextAlign.left),
                  SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: _buildPeopleList(snapshot.data!),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            );
          }),
    );
  }

  Future<PeopleListResponse> fetchPeopleList() async {
    final response = await http.get(Uri.parse('https://swapi.dev/api/people'));

    if (response.statusCode == 200) {
      return PeopleListResponse.fromJson(response.body);
    } else {
      throw Exception("Failed to load people");
    }
  }

  Widget _buildPeopleList(PeopleListResponse peopleResponse) {
    return ListView.builder(
        itemCount: peopleResponse.results!.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PeopleDetails(
                          people: peopleResponse.results![index])))
            },
            child: Container(
                margin: const EdgeInsets.only(top: 100, left: 50, right: 50),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        colorFilter: const ColorFilter.mode(
                            Colors.black38, BlendMode.colorBurn),
                        image: NetworkImage(
                            "https://starwars-visualguide.com/assets/img/characters/${index + 1}.jpg"),
                        fit: BoxFit.cover)),
                child: Card(
                  color: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 120, bottom: 70),
                        child: Text(
                          peopleResponse.results![index].name!.toLowerCase(),
                          style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "JediFont"),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              "birth year: ${peopleResponse.results![index].birthYear!}",
                              style: const TextStyle(
                                  color: Colors.amber, fontFamily: "JediFont")),
                          Text(
                              "gender: ${peopleResponse.results![index].gender!.toLowerCase()}",
                              style: const TextStyle(
                                  color: Colors.amber, fontFamily: "JediFont"))
                        ],
                      )
                    ],
                  ),
                )),
          );
        });
  }
}