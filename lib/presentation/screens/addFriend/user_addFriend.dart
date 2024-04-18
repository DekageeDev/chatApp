import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/config/firebase/getUserList.dart';
import 'package:yes_no_app/services/auth.dart';
import 'package:yes_no_app/services/firebase_service.dart';

class UserAddFriend extends StatefulWidget {
  const UserAddFriend({Key? key}) : super(key: key);

  @override
  State<UserAddFriend> createState() => _LoginPageState();
}

class _LoginPageState extends State<UserAddFriend> {
  String? errorMessage = '';
  bool isLogin = true;
  final User? user = Auth().currentUser;
  bool _showEmailError = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _entryField(String title, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      keyboardType: TextInputType
          .emailAddress, // Configurar el teclado para mostrar el tipo de entrada de correo electrónico
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: _handleSubmit,
      child: Text(isLogin ? 'Añadir' : 'Register'),
    );
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await createTwoFriendRecords(user?.email, _controllerEmail.text);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => GetUserList()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Función para validar si el correo electrónico es válido
  bool _isEmailValid(String email) {
    // Expresión regular para validar el correo electrónico
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Función para manejar el envío del formulario
  void _handleSubmit() {
    setState(() {
      // Mostrar mensaje de error si el correo electrónico no es válido
      _showEmailError = !_isEmailValid(_controllerEmail.text);
    });
    // Aquí puedes agregar la lógica adicional para enviar el formulario si el correo electrónico es válido
    signInWithEmailAndPassword();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _title()),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _entryField('email', _controllerEmail),
              if (_showEmailError)
                const Text(
                  'Por favor, introduce un correo electrónico válido.',
                  style: TextStyle(color: Colors.red),
                ),
              _submitButton(),
            ],
          )),
    );
  }
}
