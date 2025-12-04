//las notificaciones
//Locales (recordatorios)
//Push (actividad de amigos, ranking, retos)
//Marcar como leído
//maybe yo?

import 'package:flutter/material.dart';

class Notifs extends StatefulWidget {
  const Notifs({super.key});

  @override
  State<Notifs> createState() => _NotifsState();
}

class _NotifsState extends State<Notifs> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Las notificaciones"),);
  }
}
