import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/screens/addFriend/user_addFriend.dart';
import 'package:yes_no_app/presentation/screens/chat/chat_screen.dart';
import 'package:yes_no_app/services/auth.dart';
import 'package:yes_no_app/services/firebase_service.dart';

class GetUserList extends StatefulWidget {
  GetUserList({Key? key}) : super(key: key);

  @override
  _GetUserListState createState() => _GetUserListState();
}

class _GetUserListState extends State<GetUserList> {
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Auth().isUserAuthenticated(), // Suponiendo que tienes un método para verificar si el usuario está logueado
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) { // Si el usuario está logueado
              return _buildUserList(); // Muestra la lista de usuarios
            } else { // Si el usuario no está logueado
              return _buildSignInScreen(); // Redirige al usuario a la pantalla de inicio de sesión
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildUserList() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[600],
        title: Text(
          'Bienvenido, ${user?.email}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
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
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      snapshot.data?[index]['imageURL'],
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 7.5),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      ),
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
                    builder: (context) => const UserAddFriend(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Añadir Amigo'),
            ),
            ElevatedButton(
              onPressed: signOut,
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInScreen() {
    // Aquí puedes redirigir al usuario a la pantalla de inicio de sesión
    // o mostrar un mensaje para iniciar sesión
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Inicia sesión para continuar'),
          ElevatedButton(
            onPressed: () {
              // Redirige al usuario a la pantalla de inicio de sesión
              // Puedes implementar tu lógica de inicio de sesión aquí
            },
            child: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
  }
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
          