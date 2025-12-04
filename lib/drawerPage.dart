//aqui esta el madafakin drawer mis cabrones
//ESTE ES EL HOME!!! DONDE ESTA EL DRAWER!!!
//te toca yahir, aqui viene la información  del usuario para que pueda usar la app
//aqui mismo en la parte de abajo hay un ranking semanal

import 'package:fit_friend_tracker_proyecto_final/config.dart';
import 'package:fit_friend_tracker_proyecto_final/friends.dart';
import 'package:fit_friend_tracker_proyecto_final/historial.dart';
import 'package:fit_friend_tracker_proyecto_final/iniciarActividad.dart';
import 'package:fit_friend_tracker_proyecto_final/notifs.dart';
import 'package:fit_friend_tracker_proyecto_final/perfil.dart';
import 'package:flutter/material.dart';
import 'package:fit_friend_tracker_proyecto_final/modeloDatosCompartidos.dart';
// Usamos provider para escuchar los cambios en ActivityManager
import 'package:provider/provider.dart';


class drawerPage extends StatefulWidget {
  const drawerPage({super.key});

  @override
  State<drawerPage> createState() => _drawerPageState();
}

class _drawerPageState extends State<drawerPage> {
  //variables
  int _index = 0; //cambio de páginas

// Método para manejar la navegación y recibir el resultado
  void _startActivity() async {
    // 1. Navegar y esperar el resultado (Map con 'pasos', 'kilometros', 'minutos')
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Actividad()),
    );

    // 2. Verificar si se recibió un resultado válido (si el usuario terminó la actividad)
    if (result != null && result is Map<String, dynamic>) {
      // 3. Extraer los datos y sumarlos al manager global
      final pasos = result['pasos'] as int;
      final kilometros = result['kilometros'] as double;
      final minutos = result['minutos'] as int;

      // Obtener la instancia global del manager y agregar la actividad
      activityManager.addActivity(pasos, kilometros, minutos);

      // La llamada a notifyListeners dentro de activityManager.addActivity()
      // se encargará de reconstruir el Home (debido a que usaremos Provider).
    }
  }

  // Esto es para simular tus otras páginas
  Widget Amigos() => const Center(child: Text("Página de Amigos"));
  Widget Notifs() => const Center(child: Text("Página de Notificaciones"));
  Widget Perfil() => const Center(child: Text("Página de Perfil"));
  Widget Config() => const Center(child: Text("Página de Configuración"));


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
    //deberia ser CircleAvatar
    SizedBox(height: 10,),
    Text("el nombre del usuario", style: TextStyle(color: Colors.white, fontSize: 30),)
    ],
    )
    ),
    SizedBox(height: 50,),
    //aqui vamos a poner los items
    _itemDrawer(0,Icons.home, "Home"),
    _itemDrawer(1,Icons.face, "Amigos"),
    _itemDrawer(2,Icons.message, "Notificaciones"),
    _itemDrawer(3,Icons.person, "Perfil"),
    _itemDrawer(4,Icons.edit_note_rounded, "Configuración"),

    Divider(),
    MaterialButton(onPressed: (){},child: Text("Cerrar Sesión"),)
    ],
    ),
    ),
    );

  }

  //Nos ayuda a cambiar las páginas principales
  Widget? contenido() {
    switch(_index){
      //el primero es la página local, el homePage
      case 0: return HomePageContent();

      //el resto de páginas
      case 1: return Amigos();
      case 2: return Notifs();
      case 3: return Perfil();
      case 4: return Config();
    }
  }
Widget HomePageContent(){
    return Consumer<ActivityManager>(
      builder: (context,manager,child){
        final pasos = manager.dailyPasos;
        final kilometros = manager.dailyKilometros.toStringAsFixed(2);
        final minutos = manager.dailyMinutos;

        return Scaffold(
          backgroundColor: Colors.white60,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------- BIENVENIDA -----------------------
                Text(
                  "Hola, Paulina ", //nombre del usuario
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // ------------------ PROGRESO DEL DÍA ----------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //cards con la información importante cabrounes
                    _dailyCard("Pasos", "$pasos", Icons.directions_run), //cantidad de pasos
                    _dailyCard("Distancia", "$kilometros", Icons.map), //cantidad kilómetros
                    _dailyCard("Minutos", "$minutos", Icons.timer), //minutos
                  ],
                ),
                SizedBox(height: 25),
                // ------------------ BOTÓN INICIAR ACTIVIDAD ---------

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startActivity, // Llama al nuevo metodo que espera el resultado
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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
                        leading: Icon(Icons.face), //funciona como la foto de mientras
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
      }

    );
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
          Expanded(child: Text(texto, style: TextStyle(fontSize: 20),), flex: 2,)
        ],
      ),
    );
  }

  //maybe se le tenga que agregar después algo pa lo de la caminata
  _dailyCard(String s, String value, IconData icon) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(12),
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

  //METODOS!!!!!!!!!!!!!!!!!!1111



}

