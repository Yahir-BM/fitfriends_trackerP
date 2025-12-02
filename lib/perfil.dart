//perfil con info del usuario (por si laa quiere cambiar)
//Foto (con Firebase Storage),Nombre
// Email Peso, altura (opcional), Botón “Editar Perfil

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? datosUser;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatosUsuarios();
  }

  Future<void> cargarDatosUsuarios() async {
    final docRef = FirebaseFirestore.instance.collection("users").doc(user!.uid);
    final doc = await docRef.get();
    //Crea campos por defautl que no vienen en la cole de users pero los añade
    Map<String, dynamic> data = doc.data()!;
    bool actualizar = false;

    if (!data.containsKey("peso")) {
      data["peso"] = 0;
      actualizar = true;
    }
    if (!data.containsKey("altura")) {
      data["altura"] = 0;
      actualizar = true;
    }
    if (!data.containsKey("fotoPerfil")) {
      data["fotoPerfil"] = "";
      actualizar = true;
    }

    if (!data.containsKey("amigos")) {
      data["amigos"] = [];
      actualizar = true;
    }

    //Si faltaba algo, actualiza en firestore
    if (actualizar) {
      await docRef.update({
        "peso": data["peso"],
        "altura": data["altura"],
        "fotoPerfil": data["fotoPerfil"],
        "amigos": data["amigos"],
      });
    }

    setState(() {
      datosUser = data;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Center(child: CircularProgressIndicator(),);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mi perfil"),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //El Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: (datosUser!["fotoPerfil"] != "") ? NetworkImage(datosUser!["fotoPerfil"]) : null,
                    child: datosUser!["fotoPerfil"] == "" ? Icon(Icons.person, size: 60, color: Colors.white,) : null,
                  ),
                  
                  SizedBox(height: 15,),
                  Text(datosUser!["nombre"] ?? "Sin nombre",
                    style: TextStyle(fontSize: 26, color: Colors.white,
                    fontWeight: FontWeight.bold),
                  ),
                  
                  SizedBox(height: 15,),
                  Text(datosUser!["email"] ?? "",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  )
                ],
              ),
            ),
            SizedBox(height: 20,),
            //El card de la información
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child:  Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      infoItem("Peso:", "${datosUser!["peso"]} kg"),
                      infoItem("Altura:", "${datosUser!["altura"]} cm"),
                      infoItem("Fecha de registro",
                          datosUser!["fechaRegistro"].toDate().toString()),
                      infoItem("Amigos", "${datosUser!["amigos"].length} usuarios"),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 20,),
            //Boton
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/editarPerfil");
                  },
                  child: const Text(
                    "Editar Perfil",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30,)
          ],
        ),
      ),
    );
  }

  //Widget para mostrar cada campo
  Widget infoItem (String label, String value) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 12,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

}
