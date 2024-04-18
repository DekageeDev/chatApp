import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/services/firebase_service.dart';

class GetUser extends StatefulWidget {
  const GetUser({super.key});

  @override
  State<GetUser> createState() => _getUser();
}

class _getUser extends State<GetUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Page'),
      ),
      body: FutureBuilder(
          future: getUser('Juan'),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              final querySnapshot = snapshot.data as QuerySnapshot;
              final docs = querySnapshot.docs;
              if (docs.isNotEmpty) {
                final data = docs.first['username'];
                return Text("¡Hola, $data");
              } else {
                return const Text("No se encontraron datos");
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          })),
    );
  }
}

@override
State<StatefulWidget> createState() {
  // TODO: implement createState
  throw UnimplementedError();
}


/* FutureBuilder(
          future: getUser(),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return Text(
                      "¡Hola, ${snapshot.data?[index]['name']}! con nombre de usuario ${snapshot.data?[index]['username']}");
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          })), */