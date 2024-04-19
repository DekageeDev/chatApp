import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> singInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<bool> isUserAuthenticated() async {
  final user = FirebaseAuth.instance.currentUser;
  return user != null;
}


  Future<void> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Suponiendo que tienes un método para obtener el nombre del usuario por ID
  Future<String?> getUserNameById(String? userId) async {
    // Aquí iría tu lógica para obtener el nombre del usuario desde Firestore o donde lo almacenes
    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc['name']; // Suponiendo que el campo se llama 'name'
      }
    }
    return null;
  }
}
