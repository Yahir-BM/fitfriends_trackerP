//Página donde se va a mostrar toda la información acerca de la actividad física
//Botón de Iniciar / Pausar / Continuar / Finalizar
// Mapa en tiempo real (Google Maps)
//
// Info en vivo, distancia, tiempo, velocidad, pasos, Un mini gráfico o contador
//Al finalizar abre un modal con la ruta, los km. la duración, la velocidad, pasos, fecha y hora

import 'dart:async';
import 'drawerPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';

// Define un callback o función estática para guardar el progreso
// Usaremos un Map<String, dynamic> simple como ejemplo para simular el guardado
typedef SaveActivityCallback = void Function(Map<String, dynamic> activityData);

// *******************************************************************
// SIMULACIÓN DE PROVEEDOR DE DATOS
// (Esto debería estar en un State Management real, pero lo simulamos aquí)
// *******************************************************************
class ActivityData {
  // VARIABLES GLOBALES (Finales) para guardar el total o el historial
  static int finalPasos = 0;
  static double finalKilometros = 0.0;
  static int finalMinutos = 0;

  static void addActivity(int pasos, double km, int minutos) {
    // Aquí se enviaría la información a la base de datos o un proveedor global
    finalPasos += pasos;
    finalKilometros += km;
    finalMinutos += minutos;
    print('Actividad Finalizada y Guardada:');
    print(
      'Pasos: $pasos, Kilómetros: ${km.toStringAsFixed(2)}, Minutos: $minutos',
    );
    print(
      'Totales Acumulados: Pasos: $finalPasos, KM: ${finalKilometros.toStringAsFixed(2)}',
    );
  }

  static Map<String, dynamic> getTotals() {
    return {
      'pasos': finalPasos,
      'kilometros': finalKilometros,
      'minutos': finalMinutos,
    };
  }
}
// *******************************************************************

class Actividad extends StatefulWidget {
  const Actividad({super.key});

  @override
  State<Actividad> createState() => _ActividadState();
}

class _ActividadState extends State<Actividad> {
  //DATOS MOCK
  int countdown = 3;
  bool isPaused = false;

  // VARIABLES DEL TEMPORIZADOR
  Timer? _countdownTimer;
  Timer? _activityTimer;
  final Random _random = Random();
  String tiempoTotal = "00:35:20"; // Ejemplo
  String kilometros = "4.2 km"; // Ejemplo

  // 1. VARIABLES INICIALES (CONTADORES EN CURSO)
  int _currentPasos = 0;
  double _currentKilometros = 0.0;
  int _currentMinutos = 0;
  //datos de ejemplo
  final List<Map<String, dynamic>> lugaresTepic = [
    {"nombre": "Yo", "lat": 21.5095, "lng": -104.8959},
    {"nombre": "Yahir", "lat": 21.5008, "lng": -104.8970},
    {"nombre": "Felipe", "lat": 21.4937, "lng": -104.8844},
    {"nombre": "Paulina", "lat": 21.4754, "lng": -104.8675},
  ];

  // 2. VARIABLES FINALES (DATOS A GUARDAR)
  // Estas se llenarán al finalizar y se enviarán al ActivityData
  int _finalPasos = 0;
  double _finalKilometros = 0.0;
  int _finalMinutos = 0;
  Column _getMarker(String nombre) {
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
        ),
      ],
    );
  }

  // CONSTANTES DE SIMULACIÓN (Para que sea más fácil ajustarlas)
  static const double PASOS_POR_KM = 1500.0; // Estimación promedio
  static const int SIM_PASOS_PER_SECOND = 2; // Simulación: 2 pasos cada segundo
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
  Widget getMap() {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(21.5008, -104.8970),
        initialZoom: 13,
        minZoom: 0,
        maxZoom: 100,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(markers: _crearMarkers()),
      ],
    );
  }

  //AHORA SI EL WIDGET BIEN BIEN
  @override
  Widget build(BuildContext context) {
    String texto = countdown > 0
        ? "Inicia en: $countdown"
        : (isPaused ? "¡PAUSADO!" : "¡ACTIVIDAD EN CURSO!");

    // Formatear Kilómetros y Minutos para la UI
    String kmDisplay = _currentKilometros.toStringAsFixed(2);
    String minDisplay = _currentMinutos.toString().padLeft(2, '0');

    String secDisplay =
        (_activityTimer != null && _activityTimer!.isActive && !isPaused)
        ? (_activityTimer!.tick % 60).toString().padLeft(2, '0')
        : '00';
    String timeDisplay = "$minDisplay:$secDisplay"; // M:SS

    return Scaffold(
      appBar: AppBar(
        title: const Text("Iniciando recorrido"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Si el contador está activo, preguntamos antes de salir
            if (countdown == 0 && !isPaused) {
              showFinishDialog();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Texto de estado
            Text(
              texto,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: countdown > 0
                    ? Colors.orange
                    : (isPaused ? Colors.red : Colors.green),
              ),
            ),

            const SizedBox(height: 20),

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
              child: Center(child: getMap()),
            ),

            SizedBox(height: 40),

            // NUEVOS CONTADORES DE MÉTRICAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Contador de Minutos (Tiempo)
                  _buildMetricCard(
                    label: 'Tiempo',
                    value: timeDisplay, // Minutos:Segundos
                    unit: 'm:s',
                  ),
                  // Contador de Pasos
                  _buildMetricCard(
                    label: 'Pasos',
                    value: _currentPasos.toString(),
                    unit: 'pasos',
                  ),
                  // Contador de Kilómetros
                  _buildMetricCard(
                    label: 'Distancia',
                    value: kmDisplay,
                    unit: 'km',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // PAUSAR
                ElevatedButton.icon(
                  onPressed: countdown == 0 && !isPaused
                      ? _pauseActivity
                      : null,
                  icon: const Icon(Icons.pause, color: Colors.white),
                  label: const Text(
                    "Pausar",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),

                // REANUDAR
                ElevatedButton.icon(
                  onPressed: isPaused ? _resumeActivity : null,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    "Reanudar",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),

                // TERMINAR
                ElevatedButton.icon(
                  onPressed: countdown == 0 ? showFinishDialog : null,
                  icon: const Icon(Icons.stop, color: Colors.white),
                  label: const Text(
                    "Terminar",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
    _startCountdown();
  }

  // ***************************************************************
  // LÓGICA DE TEMPORIZADORES Y ESTADO
  // ***************************************************************

  @override
  void dispose() {
    // Cancelar todos los temporizadores al salir
    _countdownTimer?.cancel();
    _activityTimer?.cancel();
    super.dispose();
  }

  // --- CUENTA REGRESIVA ---
  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        // Iniciar la actividad una vez que el contador llega a 0
        _startActivity();
      }
    });
  }

  // --- CONTEO DE ACTIVIDAD ---
  void _startActivity() {
    // Si ya está activo o en pausa, no se inicia de nuevo
    if (_activityTimer != null && _activityTimer!.isActive) return;

    // Reiniciamos solo si es una nueva actividad, pero aquí estamos
    // reanudando desde el final del countdown.

    // El temporizador de actividad se ejecuta cada segundo
    _activityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          // 1. Incrementar Minutos: se incrementa cada 60 tics (segundos)
          if (timer.tick % 60 == 0) {
            _currentMinutos++;
          }

          // 2. Incrementar Pasos (SIMULADO)
          // Simula una persona caminando 1-3 pasos por segundo
          int newSteps = 1 + _random.nextInt(3);
          _currentPasos += newSteps;

          // 3. Calcular Kilómetros (Pasos / Pasos por KM)
          _currentKilometros = _currentPasos / PASOS_POR_KM;
        });
      }
    });
  }

  void _pauseActivity() {
    setState(() {
      isPaused = true;
    });
  }

  void _resumeActivity() {
    setState(() {
      isPaused = false;
    });
    // El _activityTimer ya está corriendo, solo se desbloquea la lógica
  }

  void _finishActivity() {
    // 1. Parar el Conteo
    _activityTimer?.cancel();

    // 2. Mover los valores INICIALES a FINALES
    _finalPasos = _currentPasos;
    _finalKilometros = _currentKilometros;
    _finalMinutos = _currentMinutos;

    // 3. Enviar a la clase de datos (simulando guardado)
    ActivityData.addActivity(_finalPasos, _finalKilometros, _finalMinutos);

    // 4. Reiniciar los contadores en curso (INICIALES)
    _currentPasos = 0;
    _currentKilometros = 0.0;
    _currentMinutos = 0;
    isPaused = false;
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
                // 1. Cierra el diálogo (la pequeña ventana emergente).
                Navigator.pop(context);

                // 2. Llama a la función que detiene, guarda los datos en un Map
                // y regresa a la página anterior (drawerPage) enviando el Map.
                _finishAndReturn();
              },
              child: const Text("SÍ"),
            ),
          ],
        );
      },
    );
  }

  //metodo para mandar los datos a la drawer page
  // Función clave: Detiene el conteo y devuelve los resultados a la página anterior
  void _finishAndReturn() {
    // 1. Parar el Conteo
    _activityTimer?.cancel();

    // 2. Crear un Map (diccionario) con los resultados.
    if (_currentPasos > 0) {
      final Map<String, dynamic> results = {
        'pasos': _currentPasos,
        'kilometros': _currentKilometros,
        'minutos': _currentMinutos,
      };

      // 3. ¡La Magia! Usar Navigator.pop(context, data)
      // El segundo argumento 'results' es lo que se devuelve a drawerPage.
      Navigator.pop(context, results);
    } else {
      // Si no se hizo nada, simplemente salimos sin devolver datos.
      Navigator.pop(context);
    }
  }

  // --- WIDGET PARA MOSTRAR LAS MÉTRICAS ---
  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      width: 100, // Ancho fijo para las 3 tarjetas
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}
