//Recordatorios diarios ON/OFF
// Privacidad del perfil
// Cambiar foto
// Notificaciones push ON/OFF

import 'package:flutter/material.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Configuración"),);
  }
}
