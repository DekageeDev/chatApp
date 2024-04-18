import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yes_no_app/config/firebase/getUserList.dart';
import 'package:yes_no_app/presentation/screens/register/login_register_page.dart';
import 'package:yes_no_app/services/auth.dart';
import 'package:yes_no_app/services/firebase_service.dart';
import 'package:yes_no_app/config/firebase/user_config.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final User? user = Auth().currentUser;
          return FutureBuilder<bool>(
            future: getUserName(user?.email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Mientras el Future se esté resolviendo, puedes mostrar un indicador de carga
                return CircularProgressIndicator();
              } else {
                // Una vez que el Future se haya resuelto, puedes verificar el valor devuelto
                if (snapshot.hasData && snapshot.data == true) {
                  // Si el valor es verdadero, navega a GetUserList()
                  return GetUserList();
                } else {
                  // Si el valor no es verdadero o el snapshot no tiene datos, navega a UserConfig()
                  return UserConfig();
                }
              }
            },
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
