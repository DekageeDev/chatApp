import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/chat_service.dart';
import 'package:yes_no_app/config/firebase/user_config.dart';
import 'package:yes_no_app/presentation/screens/addFriend/user_addFriend.dart';
import 'package:yes_no_app/presentation/screens/addFriend/user_addFriendRequest.dart';
import 'package:yes_no_app/presentation/screens/chat/chat_screen.dart';
import 'package:yes_no_app/presentation/screens/register/login_register_page.dart';
import 'package:yes_no_app/services/auth.dart';
import 'package:yes_no_app/services/firebase_service.dart';

import 'package:flutter/material.dart';

class GetUserList extends StatefulWidget {
  GetUserList({Key? key}) : super(key: key);

  @override
  _GetUserListState createState() => _GetUserListState();
}

class _GetUserListState extends State<GetUserList> {
  late String name = 'Cargando...';
  final User? user = Auth().currentUser;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  _loadUserName() async {
    if (user != null) {
      String? userId = await getUserIdFromEmail(user?.email);
      String? userName = await Auth().getUserNameById(userId);

      setState(() {
        name = userName ?? 'Nombre no encontrado';
      });
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const UserAddFriend(),
            ),
            (route) => false,
          );
          break;
        case 1:
          signOut();
          buildAuth(context);
          break;
        case 2:
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => FriendRequestsScreen(),
            ),
            (route) => false,
          );
          break;
      }
    });
  }

    @override
  Widget buildAuth(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Auth().isUserAuthenticated(), // Suponiendo que tienes un método para verificar si el usuario está logueado
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) { // Si el usuario está logueado
              return _buildUserList(); // Muestra la lista de usuarios
            } else { // Si el usuario no está logueado
              return LoginPage(); // Redirige al usuario a la pantalla de inicio de sesión
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[600],
        title: Text(
          'Bienvenido, $name',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder(
        future: Auth().isUserAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return _buildUserList();
            } else {
              return const UserConfig();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Añadir Amigo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Cerrar Sesión',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Solicitudes',
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return FutureBuilder(
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
    );
  }
}
