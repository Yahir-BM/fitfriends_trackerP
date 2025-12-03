import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Editarperfil extends StatefulWidget {
  const Editarperfil({super.key});

  @override
  State<Editarperfil> createState() => _EditarperfilState();
}

class _EditarperfilState extends State<Editarperfil> {
  final user = FirebaseAuth.instance.currentUser;

  //Controladores
  final TextEditingController nombreCont = TextEditingController();
  final TextEditingController pesoCont = TextEditingController();
  final TextEditingController alturaCont = TextEditingController();

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final doc = await FirebaseFirestore.instance.collection("users").doc(user!.uid).get();

    final data = doc.data()!;

    //Cargar datos actuales en los textfield
    nombreCont.text = data["nombre"] ?? "";
    pesoCont.text = "${data["peso"] ?? 0}";
    alturaCont.text = "${data["altura"] ?? 0}";

    setState(() {
      cargando = false;
    });
  }

  Future<void> guardarCambios() async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        "nombre": nombreCont.text.trim(),
        "peso": int.tryParse(pesoCont.text.trim()) ?? 0,
        "altura": int.tryParse(alturaCont.text.trim()) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Perfil actualizado correctamente")),
      );

      Navigator.pop(context); //Para regresar al perfil

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Center(child: CircularProgressIndicator(),),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text("Editar Perfil"),
        backgroundColor: Colors.amberAccent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                  padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 60, color: Colors.orangeAccent,),
                    SizedBox(height: 15,),
                    
                    Text("Editar perfil", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orangeAccent.shade700),),

                    SizedBox(height: 25,),

                    _inputText(nombreCont, "Nombre", Icons.person),
                    SizedBox(height: 15,),
                    
                    _inputText(pesoCont, "Peso (kg)", Icons.fitness_center_rounded),
                    SizedBox(height: 15,),

                    _inputText(alturaCont, "Altura (cm)", Icons.height),
                    SizedBox(height: 25,),
                    
                    _botonPrincipal("Guardar cambios", guardarCambios),

                  ],
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  //Widget para los campos más bonitos
  Widget _inputText(TextEditingController controller, String label, IconData icon, {bool obscure=false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: (label.contains("Peso") || label.contains("Altura"))
        ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.redAccent,),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  //Widget del boton
  Widget _botonPrincipal(String texto, Function accion) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.redAccent.shade200]
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () => accion(),
        child: Text(texto, style: TextStyle(fontSize: 18),),
      ),
    );
  }
}
