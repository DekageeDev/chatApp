import 'package:flutter/material.dart';
import 'package:yes_no_app/config/firebase/getUserList.dart';
import 'package:yes_no_app/services/accept_friend_service.dart';
import 'package:yes_no_app/services/auth.dart';
import 'package:yes_no_app/services/firebase_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  @override
  _FriendRequestsScreenState createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final UserConnectionService _userConnectionService = UserConnectionService();
  late List<Map<String, dynamic>> users = []; // Inicializar como lista vacía

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

_loadFriendRequests() async {
  String myEmail = Auth().currentUser?.email ?? '';
  List<String> userEmails = await getFriendRequests(myEmail);

  List<Map<String, dynamic>> userList = [];

  // Obtener detalles de los usuarios (nombre e imageUrl) usando getUserFriendList
  for (var email in userEmails) {
    List<Map<String, dynamic>> friendList = await getUserInfoByEmail(email);
    userList.addAll(friendList);
  }

  setState(() {
    users = userList.map((user) => {
      'email': user['email'],
      'name': user['name'], // Utilizar el nombre del usuario
      'imageURL': user['imageURL'] // Utilizar la imageUrl del usuario
    }).toList();
  });
}


  void _acceptRequest(String email) {
    _userConnectionService.acceptFriendRequest(email).then((_) {
      
    }).catchError((error) {
      print('Error al aceptar la solicitud: $error');
    });
  }
  void _rejectRequest(String email) {
    // Aquí irá la lógica para rechazar la solicitud de amistad
    // Puedes implementar tu lógica para actualizar la base de datos y eliminar la solicitud
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes de Amistad'),
        backgroundColor: Colors.blueGrey[600],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GetUserList(), // Reemplaza "GetUserList" por el nombre de la pantalla anterior
              ),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(users[index]['imageURL']),
            ),
            title: Text(users[index]['name']),
            subtitle: Text(users[index]['email']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    _acceptRequest(users[index]['email']);
                    setState(() {
                      users.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    _rejectRequest(users[index]['email']);
                    setState(() {
                      users.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
