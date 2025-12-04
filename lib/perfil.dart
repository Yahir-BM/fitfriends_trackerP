//perfil con info del usuario (por si laa quiere cambiar)
//Foto (con Firebase Storage),Nombre
// Email Peso, altura (opcional), Botón “Editar Perfil, Estadísticas generales

import 'package:flutter/material.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("El madafakin perfil"),);
  }
}
