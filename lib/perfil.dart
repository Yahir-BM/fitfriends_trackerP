import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});


  static  String assetsPath = 'assets/avatares/';
  // --------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuario no autenticado")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text("Perfil"),
        centerTitle: true,
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("No se encontró información del usuario"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String nombre = data["nombre"] ?? "Sin nombre";
          final String email = user.email ?? "Sin email";
          final int peso = data["peso"] ?? 0;
          final int altura = data["altura"] ?? 0;

          // --- LECTURA DEL AVATAR ---
          // 'foto' ahora contiene el nombre del archivo (ej: 'oso.png')
          final String? avatarName = data["foto"];
          final bool tieneAvatar = (avatarName != null && avatarName.isNotEmpty);
          // --------------------------

          //Fecha de registro
          DateTime fecha = (data["fechaRegistro"] as Timestamp).toDate();
          String fechaFormateada = "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${(fecha.year % 100).toString().padLeft(2, '0')}";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ---------------------------------------------------
                // MODIFICACIÓN: Mostrar el avatar o el ícono por defecto
                // ---------------------------------------------------
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blueAccent,
                  // Si tiene avatarName, construye la ruta local y usa AssetImage
                  backgroundImage: tieneAvatar
                      ? AssetImage(assetsPath + avatarName!) as ImageProvider // <--- USANDO EL ASSET LOCAL
                      : null,
                  // Muestra el ícono si NO tiene foto (o el campo 'foto' es nulo/vacío)
                  child: !tieneAvatar
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                // ---------------------------------------------------

                const SizedBox(height: 20),

                // CARD DE PERFIL
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.cyanAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
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
                      const Text("Nombre:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text(nombre, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      const Text("Email:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text(email, style: const TextStyle(fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 15),

                      const Text("Peso:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text("$peso kg", style: const TextStyle(fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 15),

                      const Text("Altura:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text("$altura cm", style: const TextStyle(fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 15),

                      const Text("Fecha de registro:", style: TextStyle(fontSize: 15, color: Colors.white70)),
                      Text(fechaFormateada, style: const TextStyle(fontSize: 18, color: Colors.white)),

                    ],
                  ),
                ),

                const SizedBox(height: 30),


                const SizedBox(height: 20,),

                // BOTÓN EDITAR PERFIL
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyanAccent, Colors.blueAccent.shade200!],
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
                    child: const Text("Editar Perfil", style: TextStyle(fontSize: 18, color: Colors.white),
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