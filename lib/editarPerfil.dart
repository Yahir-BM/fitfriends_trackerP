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


  final List<String> avataresDisponibles = const [
    'kurisu.png',
    'halo.png',
    'bad.png','chango.png','gear.png','happy.png','hola.png','peter.png','po.png',
    'pvz.png','shrek.png','steve.png','xbox.png','saber.jpg'
  ];

  static const String assetsPath = 'assets/avatares/';


  final TextEditingController nombreCont = TextEditingController();
  final TextEditingController pesoCont = TextEditingController();
  final TextEditingController alturaCont = TextEditingController();

  String? fotoURL; // Ahora guarda el nombre del archivo (ej: 'oso.png')
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      cargarDatos();
    } else {
      setState(() {
        cargando = false;
      });
    }
  }

  // --- LÓGICA DE DATOS ---

  Future<void> cargarDatos() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection("users").doc(user!.uid).get();
    final data = doc.data()!;

    nombreCont.text = data["nombre"] ?? "";
    pesoCont.text = "${data["peso"] ?? ""}";
    alturaCont.text = "${data["altura"] ?? ""}";


    fotoURL = data["foto"];

    setState(() {
      cargando = false;
    });
  }


  Future<void> mostrarSelectorAvatar() async {
    if (user == null) return;

    // Mostrar un diálogo con una cuadrícula de avatares
    final String? nuevoAvatar = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        // Usa el widget selector definido al final
        return SeleccionarAvatar(
            avataresDisponibles: avataresDisponibles,
            assetsPath: assetsPath
        );
      },
    );

    if (nuevoAvatar != null) {
      try {

        await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({"foto": nuevoAvatar});

        setState(() {
          fotoURL = nuevoAvatar;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Avatar actualizado correctamente")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar el avatar: ${e.toString()}")),
        );
      }
    }
  }


  Future<void> guardarCambios() async {
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
        "nombre": nombreCont.text.trim(),
        "peso": int.tryParse(pesoCont.text.trim()) ?? 0,
        "altura": int.tryParse(alturaCont.text.trim()) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado correctamente")),
      );

      Navigator.pop(context);

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
        body: const Center(child: CircularProgressIndicator(),),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Error: Usuario no autenticado"),),
      );
    }

    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          title: const Text("Editar Perfil"),
          backgroundColor: Colors.amberAccent,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit, size: 60, color: Colors.orangeAccent,),
                      const SizedBox(height: 15,),

                      Text("Editar perfil", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orangeAccent.shade700),),
                      const SizedBox(height: 10,),


                      fotoPerfil(),

                       SizedBox(height: 25,),

                      inputText(nombreCont, "Nombre", Icons.person),
                       SizedBox(height: 15,),

                      inputText(pesoCont, "Peso (kg)", Icons.fitness_center_rounded),
                       SizedBox(height: 15,),

                      inputText(alturaCont, "Altura (cm)", Icons.height),
                       SizedBox(height: 25,),

                      botonPrincipal("Guardar cambios", guardarCambios),

                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }


  Widget fotoPerfil() {

    final bool tieneAvatar = (fotoURL != null && fotoURL!.isNotEmpty);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [

            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.grey.shade200,

              backgroundImage: tieneAvatar
                  ? AssetImage(assetsPath + fotoURL!) as ImageProvider
                  : null,
              child: !tieneAvatar
                  ? const Icon(Icons.person, size: 55, color: Colors.white,)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 10,),


        TextButton.icon(
          onPressed: mostrarSelectorAvatar,
          icon: const Icon(Icons.photo, color: Colors.orange,),
          label: const Text("Cambiar avatar"),
        )
      ],
    );
  }

  // Widget para la entrada de texto
  Widget inputText(TextEditingController controller, String label, IconData icon, {bool obscure=false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: (label.contains("Peso") || label.contains("Altura"))
          ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.edit, color: Colors.redAccent,),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


  Widget botonPrincipal(String texto, Function accion) {
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
        child: Text(texto, style: const TextStyle(fontSize: 18),),
      ),
    );
  }
}



class SeleccionarAvatar extends StatelessWidget {
  final List<String> avataresDisponibles;
  final String assetsPath;

  const SeleccionarAvatar({required this.avataresDisponibles, required this.assetsPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Selecciona tu Avatar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: avataresDisponibles.length,
              itemBuilder: (context, index) {
                final avatarName = avataresDisponibles[index];
                final fullPath = assetsPath + avatarName;

                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, avatarName);
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(fullPath),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}