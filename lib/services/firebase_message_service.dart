import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationService {
  final String conversationId; // ID de la conversación

  ConversationService({required this.conversationId});

  Future<List<Map<String, dynamic>>> getConversationMessages() async {
  try {
    List<Map<String, dynamic>> messages = [];

    // Obtener los mensajes de Firestore
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    querySnapshot.docs.forEach((doc) {
      messages.add({
        'sender_id': doc['sender_id'],
        'text': doc['text'],
        // Añade otros campos si los necesitas
      });
    });

    return messages;
  } catch (error) {
    print('Error al obtener mensajes de la conversación: $error');
    return [];
  }
}
}
