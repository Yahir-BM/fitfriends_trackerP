//Página donde se va a mostrar toda la información acerca de la actividad física
//Botón de Iniciar / Pausar / Continuar / Finalizar
// Mapa en tiempo real (Google Maps)
//
// Info en vivo, distancia, tiempo, velocidad, pasos, Un mini gráfico o contador
//Al finalizar abre un modal con la ruta, los km. la duración, la velocidad, pasos, fecha y hora

import 'dart:async';
import 'package:fitfriends_tracker/drawerPage.dart';
import 'package:flutter/material.dart';

class Actividad extends StatefulWidget {
  const Actividad({super.key});

  @override
  State<Actividad> createState() => _ActividadState();
}

class _ActividadState extends State<Actividad> {
//DATOS MOCK
  int countdown = 3;
  bool isPaused = false;

  String tiempoTotal = "00:35:20"; // Ejemplo
  String kilometros = "4.2 km";   // Ejemplo

  @override
  Widget build(BuildContext context) {
    String texto =
    countdown > 0 ? "$countdown" : "¡A caminar!";

    return Scaffold(
      appBar: AppBar(
        title: Text("Iniciando recorrido"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          // Texto de cuenta regresiva
          Text(
            texto,
            style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.green),
          ),

          SizedBox(height: 20),

          // Espacio donde irá el mapa
          Container(
            height: 300,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Center(
              child: Text(
                "Aquí irá el mapa ",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ),
          ),

          SizedBox(height: 40),

          // BOTONES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: countdown == 0 && !isPaused
                    ? () {
                  setState(() {
                    isPaused = true;
                  });
                }
                    : null,
                child: Text("Pausar"),
              ),

              ElevatedButton(
                onPressed: isPaused
                    ? () {
                  setState(() {
                    isPaused = false;
                  });
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
                ),
                child: Text("Reanudar", style: TextStyle(color: Colors.white),),
              ),

              ElevatedButton(
                onPressed: countdown == 0
                    ? () {
                  showFinishDialog();
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text("Terminar", style: TextStyle(
                  color: Colors.white
                ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //METODOS A LA VERGA
  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Terminar recorrido"),
          content: Text("¿Estás seguro que quieres terminar tu recorrido?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // cerrar modal
              },
              child: Text("NO"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // cerrar modal
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => drawerPage(),
                  ),
                );
              },
              child: Text("SÍ"),
            ),
          ],
        );
      },
    );
  }


}
