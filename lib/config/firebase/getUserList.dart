import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/screens/addFriend/user_addFriend.dart';
import 'package:yes_no_app/presentation/screens/chat/chat_screen.dart';
import 'package:yes_no_app/services/auth.dart';
import 'package:yes_no_app/services/firebase_service.dart';

class GetUserList extends StatefulWidget {
  GetUserList({super.key});

  @override
  State<GetUserList> createState() => _getUser();

  Future<void> signOut() async {
    await Auth().signOut();

    Widget _signOutButton() {
      return ElevatedButton(onPressed: signOut, child: const Text('Sign Out'));
    }
  }
}

class _getUser extends State<GetUserList> {
  final User? user = Auth().currentUser;
  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[600],
          title: Text(
            'Bienvenido, ${user?.email}',
            style: const TextStyle(
              fontWeight: FontWeight.w600, // Texto en negrita
            ),
          ),
        ),
        body: FutureBuilder(
            future: getUserFriendList(user?.email),
            builder: ((context, snapshot) {
              if (snapshot.hasData) {
                return ListView.separated(
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "${snapshot.data?[index]['name']}",
                        style: const TextStyle(
                          fontSize: 18, // Tamaño de fuente aumentado
                          fontWeight: FontWeight.w500, // Texto en negrita
                        ),
                      ),
                      tileColor: Colors.blueGrey[400],
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                    name: snapshot.data?[index]['name'],
                                    email: snapshot.data?[index]['email'],
                                    imageURL: snapshot.data?[index]['imageURL'],
                                  )),
                          (route) => false,
                        );
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            25), // Puedes ajustar el radio según tus necesidades
                        child: Image.network(
                          snapshot.data?[index]['imageURL'],
                          height: 45,
                          width: 45,
                          fit: BoxFit
                              .cover, // Para asegurarte de que la imagen se ajuste correctamente al radio del borde
                        ),
                      ),
                      //trailing: const Icon(Icons.menu),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 7.5),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            })),
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserAddFriend()),
                        (route) => false,
                      );
                    },
                    child: Text('Añadir Amigo'),
                  ),
                  ElevatedButton(
                    onPressed: signOut,
                    child: Text('Cerrar sesión'),
                  ),
                ])));
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
          