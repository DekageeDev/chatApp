import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/chat_service.dart';
import 'package:yes_no_app/config/theme/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yes_no_app/services/auth.dart'; // Importa Firebase Firestore
import 'package:yes_no_app/services/firebase_message_service.dart';

class ChatProvider with ChangeNotifier {
  final GetYesNoAnser getYesNoAnser = GetYesNoAnser();
  final ScrollController chatScrollController = ScrollController();
  final User? user = Auth().currentUser;

  final _messagesController = StreamController<List<Message>>.broadcast();
  Stream<List<Message>> get messagesStream => _messagesController.stream;

  List<Message> messageList = [];

  // Método para cargar los mensajes desde Firestore
  Future<void> loadMessagesFromFirestore(String? userEmail, String otherUserEmail) async {
    try {
      // Identificar la conversación correspondiente en la base de datos
      String conversationId = await _getConversationId(userEmail!, otherUserEmail);
      if (conversationId.isEmpty) {
        print('No se encontró una conversación entre los usuarios $userEmail y $otherUserEmail');
        return;
      }

      // Limpiar la lista de mensajes antes de cargar los nuevos mensajes
      messageList.clear();
var userID = await getUserIdFromEmail(userEmail);
      // Obtener los mensajes de la conversación desde Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('conversations')
              .doc(conversationId)
              .collection('messages')
              .orderBy('timestamp', descending: false)
              .get();

      querySnapshot.docs.forEach((doc) {
        Message message = Message(
          text: doc['text'],
          fromWho: doc['sender_id'] == userID ? FromWho.me : FromWho.her,
        );
        messageList.add(message);
      });

      // Emitir la lista actualizada de mensajes al stream
      _messagesController.add(messageList);

      notifyListeners(); // Notificar a los widgets que se deben actualizar
    } catch (error) {
      print('Error al cargar mensajes desde Firestore: $error');
    }
  }

Future<String> _getConversationId(String userEmail, String otherUserEmail) async {
  try {
    String senderId = await getUserIdFromEmail(userEmail) as String;
    String receiverId = await getUserIdFromEmail(otherUserEmail) as String;

    // Intentar obtener el conversationId de una forma
    String conversationId = '${senderId}_${receiverId}';
    
    // Comprobar si el conversationId existe en la base de datos
    bool exists = await checkConversationIdExists(conversationId);

    // Si no existe, intentar la otra forma
    if (!exists) {
      conversationId = '${receiverId}_${senderId}';
    }

    return conversationId;
  } catch (error) {
    print('Error al obtener los IDs de usuario: $error');
    return ''; // Otra acción o valor por defecto si es necesario
  }
}
Future<bool> checkConversationIdExists(String conversationId) async {
  try {
    // Consulta Firestore para comprobar si el conversationId existe
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('conversations')
      .doc(conversationId)
      .collection('messages')
      .limit(1)  // Limitamos la consulta a 1 para optimizar
      .get();

    // Devuelve true si hay algún documento en la colección de mensajes
    return snapshot.docs.isNotEmpty;
  } catch (error) {
    print('Error al comprobar la existencia del conversationId: $error');
    return false;
  }
}
  Future<String> getUserIdFromEmail(String email) async {
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

  Future<void> sendMessage(String text, String? email) async {
    final newMessage = Message(text: text, fromWho: FromWho.me);
    messageList.add(newMessage);

    await insertFirstMessage(text, user?.email, email);
    await loadMessagesFromFirestore(user?.email, email!);
    notifyListeners();
    moveScrollToBottom();

    if (text.endsWith('?')) {
      // Solo llamar a herReply si el mensaje termina con un signo de interrogación
      herReply();
    }
  }

  Future<void> herReply() async {
    final herMessage = await getYesNoAnser.getAnswer();
    messageList.add(herMessage);
    notifyListeners();

    moveScrollToBottom();
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));

    chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }
}
