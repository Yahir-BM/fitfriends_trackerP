import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'logins.dart';
import 'editarPerfil.dart';
import 'drawerPage.dart';
import 'package:provider/provider.dart';
import 'modeloDatosCompartidos.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Firebase inicializado correctamente"); //prueba

  AwesomeNotifications().initialize(
    null, // icono por defecto
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        channelDescription: 'Basic channel for notifications',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
      )
    ],
  );

  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  runApp(
    ChangeNotifierProvider<ActivityManager>.value(
      value: activityManager, // Usamos la instancia global que ya definiste
      child: MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: pag_autenticacion(),
      routes: {"/editarPerfil": (context) => Editarperfil()},
    );
  }
}
