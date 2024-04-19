import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:yes_no_app/config/theme/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

Future<void> insertFirstMessage(
    String messageText, String? senderEmail, String? receiverEmail) async {
  // Obtener referencias a las colecciones y documentos relevantes
  CollectionReference conversationsRef =
      FirebaseFirestore.instance.collection('conversations');
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

  // Obtener los IDs de los usuarios a partir de sus correos electrónicos
  String senderId = await getUserIdFromEmail(senderEmail!);
  String receiverId = await getUserIdFromEmail(receiverEmail!);

  // Crear una nueva conversación si aún no existe una entre los dos usuarios
  String conversationId = await getOrCreateConversationId(senderId, receiverId);

  // Insertar el primer mensaje en la conversación
  await conversationsRef.doc(conversationId).collection('messages').add({
    'sender_id': senderId,
    'text': messageText,
    'timestamp': Timestamp.now(),
  });
}

Future<String> getUserIdFromEmail(String? email) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('user')
      .where('email', isEqualTo: email)
      .get();
  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first.id;
  } else {
    throw Exception('Usuario con correo electrónico $email no encontrado');
  }
}

Future<String> getOrCreateConversationId(String senderId, String receiverId) async {
  // Comprobar si la conversación ya existe en el registro del usuario
  String? conversationId = await getConversationIdFromUser(senderId, receiverId);

  if (conversationId == null) {
    // Intentar con el otro orden de IDs
    conversationId = await getConversationIdFromUser(receiverId, senderId);
  }

  if (conversationId == null) {
    // Si no existe, crear una nueva conversación
    conversationId = await createNewConversation(senderId, receiverId);
  }

  return conversationId!;
}

Future<String?> getConversationIdFromUser(String userId, String otherUserId) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('conversations')
      .doc(otherUserId)
      .get();

    if (snapshot.exists) {
      return snapshot.data()?['conversationId'];
    } else {
      return null;
    }
  } catch (error) {
    print('Error al obtener el conversationId del usuario: $error');
    return null;
  }
}

Future<String> createNewConversation(String senderId, String receiverId) async {
  try {
    String conversationId = senderId + '_' + receiverId;

    // Crear un nuevo documento en la colección de conversaciones
    await FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationId)
      .set({
        'sender_id': senderId,
        'receiver_id': receiverId,
      });

    // Actualizar el registro del usuario
    await updateConversationIdInUser(senderId, receiverId, conversationId);
    await updateConversationIdInUser(receiverId, senderId, conversationId);

    return conversationId;
  } catch (error) {
    print('Error al crear una nueva conversación: $error');
    return '';
  }
}

Future<void> updateConversationIdInUser(String userId, String otherUserId, String conversationId) async {
  try {
    await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('conversations')
      .doc(otherUserId)
      .set({
        'conversationId': conversationId,
      });
  } catch (error) {
    print('Error al actualizar el conversationId del usuario: $error');
  }
}
