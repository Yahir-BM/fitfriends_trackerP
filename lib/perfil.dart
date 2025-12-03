import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Usuario no autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil"),
        centerTitle: true,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return Center(child: Text("No se encontró información del usuario"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String nombre = data["nombre"] ?? "Sin nombre";
          final String email = user.email ?? "Sin email";
          final int peso = data["peso"] ?? 0;
          final int altura = data["altura"] ?? 0;

          //Fecha de registro
          DateTime fecha = (data["fechaRegistro"] as Timestamp).toDate();
          String fechaFormateada = "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${(fecha.year % 100).toString().padLeft(2, '0')}";

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Foto (default temporal)
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),

                SizedBox(height: 20),

                // CARD DE PERFIL
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.cyanAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nombre:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text(nombre, style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),

                      Text("Email:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text(email, style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(height: 15),

                      Text("Peso:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text("$peso kg", style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(height: 15),

                      Text("Altura:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text("$altura cm", style: TextStyle(fontSize: 18, color: Colors.white)),
                      SizedBox(height: 15),

                      Text("Fecha de registro:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text(fechaFormateada, style: TextStyle(fontSize: 18, color: Colors.white)),

                    ],
                  ),
                ),

                SizedBox(height: 30),

                Text("Amigos:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),

                SizedBox(height: 10,),

                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data["amigos"] == null || data["amigos"].isEmpty)
                        Center(
                          child: Text("Aun no tienes amigos agregados", style: TextStyle(fontSize: 16, color: Colors.grey),),
                        )
                      else
                        Column(
                          children: List.generate(
                              data["amigos"].length,
                              (index) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(Icons.person, color: Colors.white,),
                                ),
                                title: Text(data["amigos"][index], style: TextStyle(fontSize: 18),
                                ),
                              )
                          )
                        )
                    ],
                  ),
                ),
                SizedBox(height: 20,),

                // BOTÓN EDITAR PERFIL
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyanAccent, Colors.blueAccent.shade200],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/editarPerfil");
                    },
                    child: Text("Editar Perfil", style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
