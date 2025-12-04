//Página donde se va a mostrar toda la información acerca de la actividad física
//Botón de Iniciar / Pausar / Continuar / Finalizar
// Mapa en tiempo real (Google Maps)
//
// Info en vivo, distancia, tiempo, velocidad, pasos, Un mini gráfico o contador
//Al finalizar abre un modal con la ruta, los km. la duración, la velocidad, pasos, fecha y hora

import 'dart:async';
import 'package:fitfriends_tracker/drawerPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

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

  //datos de ejemplo
  final List<Map<String, dynamic>> lugaresTepic = [
    {
      "nombre": "Yo",
      "lat": 21.5095,
      "lng": -104.8959,
    },
    {
      "nombre": "Yahir",
      "lat": 21.5008,
      "lng": -104.8970,
    },
    {
      "nombre": "Felipe",
      "lat": 21.4937,
      "lng": -104.8844,
    },
    {
      "nombre": "Paulina",
      "lat": 21.4754,
      "lng": -104.8675,
    },
  ];

  Column _getMarker(String nombre){
      return Column(
      children: [
        Icon(
          Icons.location_on,
          color: (nombre == "Yo" ? Colors.blue : Colors.red),
          size: 35,
        ),
        Text(
          nombre,
          style: TextStyle(
            fontSize: 10,
            color: Colors.black,
            backgroundColor: Colors.white,
          ),
        )
      ],
    );
  }

  List<Marker> _crearMarkers() {
    return lugaresTepic.map((lugar) {
      return Marker(
        child: _getMarker(lugar["nombre"]),
        width: 80,
        height: 80,
        point: LatLng(lugar["lat"], lugar["lng"]),
      );
    }).toList();
  }

  final MapController _mapController = MapController();
  Widget getMap(){
    return FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(21.5008, -104.8970),
          initialZoom: 13,
          minZoom: 0,
          maxZoom: 100,
        ),
        children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',),
          MarkerLayer(markers: _crearMarkers()),
        ],
    );
  }

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
              child: getMap(),
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
