import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> acceptFriendRequest(String email) async {
    String myEmail = _auth.currentUser?.email ?? '';

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('userConnection')
          .where('email1', isEqualTo: email)
          .where('email2', isEqualTo: myEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;

        await _firestore
            .collection('userConnection')
            .doc(docId)
            .update({
              'email2Accepted': true,
            });
      } else {
        print('Documento no encontrado');
      }
    } catch (e) {
      print('Error accepting request: $e');
    }
  }
}
