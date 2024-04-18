import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/config/firebase/getUserList.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import 'package:yes_no_app/presentation/screens/chat/her_message_bubble.dart';
import 'package:yes_no_app/presentation/screens/chat/my_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/message_field_box.dart';

class ChatScreen extends StatelessWidget {
  final String name;
  final String imageURL;
  final String email;

  const ChatScreen({
    required this.name,
    required this.email,
    required this.imageURL,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: Colors.blueGrey[600],
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10, left: 5),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GetUserList()),
                );
              },
              child: const Icon(Icons.arrow_back, size: 25),
            ),
          ),
          leadingWidth: 20,
          title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(imageURL, height: 45, width: 45),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 19),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: _chatView(email: email),
    );
  }
}

class _chatView extends StatefulWidget {
  final String email;
  final User? user = FirebaseAuth.instance.currentUser; 

  _chatView({required this.email, Key? key}) : super(key: key);

  @override
  _chatViewState createState() => _chatViewState();
}

class _chatViewState extends State<_chatView> {
  @override
  void initState() {
    super.initState();
    final chatProvider = context.read<ChatProvider>();
    chatProvider.loadMessagesFromFirestore(widget.user?.email, widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return StreamBuilder<List<Message>>(
      stream: chatProvider.messagesStream, // Un stream que emite la lista de mensajes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center( // Muestra un indicador de carga mientras se carga el chat
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar los mensajes'), // Muestra un mensaje de error si hay algún problema
          );
        } else {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: chatProvider.chatScrollController,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final message = snapshot.data![index];
                        return (message.fromWho == FromWho.her)
                            ? HerMessageBubble(message: message)
                            : MyMessageBubble(message: message);
                      },
                    ),
                  ),

                  // Caja de Mensajes
                  MessageFieldBox(
                    onValue: (value) => chatProvider.sendMessage(value, widget.email),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
