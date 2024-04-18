import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<Object> getUser(String name) async {
  CollectionReference collectionReferenceUser = db.collection('user');

  final QuerySnapshot querySnapshot =
      await collectionReferenceUser.where('name', isEqualTo: name).get();

  if (querySnapshot.docs.isNotEmpty) {
    final DocumentSnapshot doc = querySnapshot.docs.first;

    final Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
    final String username = userData['username'];
    final String name = userData['name'];
    final String imageURL = userData['imageURL'];

    // Imprimir los valores de los campos
    print('Username: $username');
    print('Name: $name');
    print('imageURL: $imageURL');
  } else {
    print('No se encontró un usuario con ese nombre.');
  }

  return querySnapshot;
}

Future<List> getUserList() async {
  List userList = [];
  CollectionReference collectionReferenceUser = db.collection('user');

  QuerySnapshot queryUser = await collectionReferenceUser.get();

  queryUser.docs.forEach((documento) {
    userList.add(documento.data());
  });

  return userList;
}

Future<List<Map<String, dynamic>>> getUserFriendList(String? email) async {
  List<Map<String, dynamic>> userList = [];
  CollectionReference collectionReferenceUserConnection =
      db.collection('userConnection');

  final QuerySnapshot querySnapshot = await collectionReferenceUserConnection
      .where('email1', isEqualTo: email)
      .get();

  for (var documento in querySnapshot.docs) {
    final String user2Email = documento['email2'];
    // Consultar los datos del usuario en la colección 'user' filtrando por el email2
    final userQuerySnapshot =
        await db.collection('user').where('email', isEqualTo: user2Email).get();

    // Agregar los datos del usuario a la lista de usuarios
    userQuerySnapshot.docs.forEach((userDoc) {
      userList.add(userDoc.data());
    });
  }

  return userList;
}

//Guardar name en user bbdd
Future<void> addUser(String? name, String? email) async {
  await db.collection("user").add({
    "name": name,
    "email": email,
    'imageURL':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRo3ABGeThIKnKPQ3a0wTosC9Lg9aB7bF1kbw&usqp=CAU'
  });
}

Future<void> addFriend(String? email11, String? email12) async {
  await db.collection("userConnection").add({
    "email1": email11,
    "email2": email12,
  });
}

Future<void> createTwoFriendRecords(String? email1, String? email2) async {
  // Llamada a la función addFriend con valores proporcionados
  await addFriend(email1, email2);

  // Llamada a la función addFriend con correos electrónicos hardcodeados
  await addFriend(email2, email1);
}

Future<bool> getUserName(String? name) async {
  CollectionReference collectionReferenceUser = db.collection('user');

  final QuerySnapshot querySnapshot =
      await collectionReferenceUser.where('email', isEqualTo: name).get();

  if (querySnapshot.docs.isNotEmpty) {
    final DocumentSnapshot doc = querySnapshot.docs.first;

    final Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

    if (userData['name'] != null) {
      return true;
    }
  } else {
    print('No se encontró un usuario con ese nombre.');
    return false;
  }

  return false;
}
