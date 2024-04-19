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

  // Consultar documentos donde email1 o email2 coincidan con el email y ambos estén aceptados
  final QuerySnapshot querySnapshot = await collectionReferenceUserConnection
      .where('email1', isEqualTo: email)
      .where('email1Accepted', isEqualTo: true)
      .where('email2Accepted', isEqualTo: true)
      .get();

  final QuerySnapshot querySnapshot2 = await collectionReferenceUserConnection
      .where('email2', isEqualTo: email)
      .where('email1Accepted', isEqualTo: true)
      .where('email2Accepted', isEqualTo: true)
      .get();

  // Combinar los resultados de las dos consultas
  List<QueryDocumentSnapshot> allDocs = [...querySnapshot.docs, ...querySnapshot2.docs];

  for (var documento in allDocs) {
    String user2Email;

    if (documento['email1'] == email) {
      user2Email = documento['email2'];
    } else {
      user2Email = documento['email1'];
    }

    // Consultar los datos del usuario en la colección 'user' filtrando por el email2
    final userQuerySnapshot =
        await db.collection('user').where('email', isEqualTo: user2Email).get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      // Agregar los datos del usuario a la lista de usuarios
      userQuerySnapshot.docs.forEach((userDoc) {
        userList.add(userDoc.data());
      });
    }
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
    "email1Accepted": true,
    "email2Accepted": false
  });
}

Future<List<Map<String, dynamic>>> getUserInfoByEmail(String email) async {
  List<Map<String, dynamic>> userInfoList = [];

  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .get();

    querySnapshot.docs.forEach((doc) {
      userInfoList.add(doc.data());
    });

    return userInfoList;
  } catch (e) {
    print('Error fetching user info: $e');
    return [];
  }
}


//Recogemos la peticion de amistad
Future<List<String>> getFriendRequests(String myEmail) async {
  List<String> friendRequestsList = [];

  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('userConnection')
        .where('email2', isEqualTo: myEmail)
        .where('email2Accepted', isEqualTo: false)
        .get();

    querySnapshot.docs.forEach((doc) {
      friendRequestsList.add(doc['email1']);
    });

    return friendRequestsList;
  } catch (e) {
    print('Error fetching friend requests: $e');
    return [];
  }
}

Future<void> createTwoFriendRecords(String? email1, String? email2) async {
  // Llamada a la función addFriend con valores proporcionados
  await addFriend(email1, email2);
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
