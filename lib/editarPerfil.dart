import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  String? fotoURL;
  bool cargando = true;
  bool subiendoFoto = false;

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
    fotoURL = data["fotoPerfil"] ?? "";

    setState(() {
      cargando = false;
    });
  }

  //Para seleccionar y subir la foto
  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null)
      return; //Por si cancela el cambio

    setState(() {
      subiendoFoto = true;
    });

    String nombreArchivo = "perfil_${user!.uid}.jpg";
    final ref = FirebaseStorage.instance.ref().child("fotosPerfil").child(nombreArchivo);

    await ref.putFile(File(file.path));
    String url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({"fotoPerfil": url,});

    setState(() {
      fotoURL = url;
      subiendoFoto = false;
    });
  }

  //Para guardar los cambios
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
                    SizedBox(height: 10,),
                    _fotoPerfil(),

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

  Widget _fotoPerfil() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            //Foto
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (fotoURL != null && fotoURL!.isNotEmpty) ? NetworkImage(fotoURL!) : null,
              child: (fotoURL == null || fotoURL!.isEmpty) ? Icon(Icons.person, size: 55, color: Colors.white,) : null,
            ),

            if (subiendoFoto) CircularProgressIndicator(color: Colors.orangeAccent,),
          ],
        ),
        SizedBox(height: 10,),

        TextButton.icon(
            onPressed: subiendoFoto ? null : seleccionarImagen,
            icon: Icon(Icons.photo, color: Colors.orange,),
            label: Text("Cambiar foto"),
        )
      ],
    );
  }
}
