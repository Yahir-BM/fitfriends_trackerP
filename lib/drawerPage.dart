//aqui esta el madafakin drawer mis cabrones
//ESTE ES EL HOME!!! DONDE ESTA EL DRAWER!!!
//te toca yahir, aqui viene la información  del usuario para que pueda usar la app
//aqui mismo en la parte de abajo hay un ranking semanal

import 'package:fitfriends_tracker/config.dart';
import 'package:fitfriends_tracker/friends.dart';
import 'package:fitfriends_tracker/historial.dart';
import 'package:fitfriends_tracker/iniciarActividad.dart';
import 'package:fitfriends_tracker/notifs.dart';
import 'package:fitfriends_tracker/perfil.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logins.dart';


class drawerPage extends StatefulWidget {
  const drawerPage({super.key});

  @override
  State<drawerPage> createState() => _drawerPageState();
}

class _drawerPageState extends State<drawerPage> {
  //variables
  String nombreUsuario = "";
  int _index = 0; //cambio de páginas

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (doc.exists) {
        setState(() {
          nombreUsuario = doc["nombre"];
        });
      } else {
        setState(() {
          nombreUsuario = "Usuario";
        });
      }
    } catch (e) {
      print("Error cargando usuario: $e");
      setState(() => nombreUsuario = "Usuario");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FitFriend", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),

      body: contenido(),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.blueAccent),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    SizedBox(height: 10,),
                    Text(nombreUsuario.isEmpty ? "Cargando..." : nombreUsuario, style: TextStyle(color: Colors.white, fontSize: 30),)
                  ],
                )
            ),
            SizedBox(height: 50,),

            _itemDrawer(0,Icons.home, "Home"),
            _itemDrawer(1,Icons.face, "Amigos"),
            _itemDrawer(2,Icons.message, "Notificaciones"),
            _itemDrawer(3,Icons.person, "Perfil"),
            _itemDrawer(4,Icons.edit_note_rounded, "Configuración"),

            Divider(),
            MaterialButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  pag_autenticacion(),
                  ),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text("Cerrar Sesión"),
            )
          ],
        ),
      ),
    );
  }


  Widget? contenido() {
    switch(_index){

      case 0: return Scaffold(
        backgroundColor: Colors.white60,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------- BIENVENIDA -----------------------
              Text(
                nombreUsuario.isEmpty ? "Hola..." : "Hola, $nombreUsuario", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // ------------------ PROGRESO DEL DÍA ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //cards con la información importante cabrounes
                  _dailyCard("Pasos", "pasos", Icons.directions_run), //cantidad de pasos
                  _dailyCard("Kilómetros", "km", Icons.map), //cantidad kilómetros
                  _dailyCard("Minutos", "minutos", Icons.timer), //minutos
                ],
              ),
              SizedBox(height: 25),
              // ------------------ BOTÓN INICIAR ACTIVIDAD ---------

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>Actividad())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Iniciar actividad",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 10),

              //---------------------- Botón Historial------------------------
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Historial())
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Historial de actividades"),
                ),
              ),
              SizedBox(height: 30),

              //AQUI VA EL PINCHE MAPA
              SizedBox(height: 70,),

              //----z-------------- ACTIVIDADES DE AMIGOS ------------

              Text(
                "Últimas actividades de amigos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              //Column( ESTE YA ES PA CUANDO ESTÉ CONECTADO AL BACK PUES, TOCA ALG ESTÁTICO
                //children: lastFriendActivities.map((act) {
                  //return Card(
                    //child: ListTile(
                      //leading: CircleAvatar(
                        //backgroundImage: NetworkImage(act["photo"]),
                      //),
                      //title: Text("${act["name"]} recorrió ${act["km"]} km"),
                      //subtitle: Text("Hace ${act["timeAgo"]}"),
                    //),
                  //);
                //}).toList(),
              //),
              
              Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.face),
                      title: Text("Eddilson recorrió 7 kilómetros"),
                      subtitle: Text("Hace 60 minutos"),
                    ),
                  )
                ],
              ),
              
              SizedBox(height: 30),

              // ------------------ RANKING SEMANAL -------------------
              Text(
                "Ranking semanal 🏆",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              Column(
                children: [
                  Card(
                    color: Colors.amber.shade400,
                    //primer lugar amigo
                    child: ListTile(
                      leading: Icon(Icons.face), //funciona como la foto de mientras
                      title: Text("Eddilson recorrió 7 kilómetros"),
                      subtitle: Text("Hace 60 minutos"),
                    ),
                  ),

                  Card(
                    color: Colors.white24,
                    //Segundo lugar amigo
                    child: ListTile(
                      leading: Icon(Icons.face), //funciona como la foto de mientras
                      title: Text("Eddilson recorrió 7 kilómetros"),
                      subtitle: Text("Hace 60 minutos"),
                    ),
                  ),

                  Card(
                    color: Colors.deepOrange.shade400,
                    //tercer lugar amigo
                    child: ListTile(
                      leading: Icon(Icons.face), //funciona como la foto de mientras
                      title: Text("Eddilson recorrió 7 kilómetros"),
                      subtitle: Text("Hace 60 minutos"),
                    ),
                  ),

                  Card(
                    // amigo x
                    child: ListTile(
                      leading: Icon(Icons.face), //funciona como la foto de mientras
                      title: Text("Eddilson recorrió 7 kilómetros"),
                      subtitle: Text("Hace 60 minutos"),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      );


      //el resto de páginas
      case 1: return Amigos();
      case 2: return Notifs();
      case 3: return Perfil();
      case 4: return Config();
    }
    return null;
  }

  //Metodo para lso iconos en el drawe, los que llevan a las diferentes paginas
  //crea los cosos pues, ustedes saben
  Widget _itemDrawer(int indice, IconData icono, String texto ){
    return ListTile(
      onTap: (){
        setState(() {
          _index = indice;
        });
        Navigator.pop(context);
      },
      title: Row(
        children: [
          Expanded(child: Icon(icono, size: 30,)),
          Expanded(flex: 2,child: Text(texto, style: TextStyle(fontSize: 20),),)
        ],
      ),
    );
  }

  //maybe se le tenga que agregar después algo pa lo de la caminata
  Container _dailyCard(String s, String value, IconData icon) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.blue),
          SizedBox(height: 6),
          Text(s, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
  
}

