import 'dart:async';
import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

class ActivityData {
  static int finalPasos = 0;
  static double finalKilometros = 0.0;
  static int finalMinutos = 0;

  static void addActivity(int pasos, double km, int minutos) {
    finalPasos += pasos;
    finalKilometros += km;
    finalMinutos += minutos;
  }
}


class Actividad extends StatefulWidget {
  const Actividad({super.key});

  @override
  State<Actividad> createState() => _ActividadState();
}

class _ActividadState extends State<Actividad> {

  Future<void> sendNotification(String title, String content) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: title,
        body: content,
      ),
    );
  }


  int countdown = 3;
  bool isPausado = false;
  final Random random = Random();
  final MapController mapController = MapController();


  static  double PASOS_POR_KM = 1500.0;
  static  String LAST_LAT_KEY = 'last_map_latitude';
  static  String LAST_LNG_KEY = 'last_map_longitude';


  Timer? countdow;
  Timer? contadorActividad;
  Timer? gpsTimer; // Timer para enviar ubicación a Firestore

  // VARIABLES DE UBICACIÓN Y ESTADO DE AMIGOS
  LatLng ultimaPosicion =  LatLng(21.5008, -104.8970); // Posición inicial Tepic
  List<String> idAmigo = [];
  Map<String, String> nombreAmigo = {}; // {UID: Nombre} para mostrar en el mapa
  final List<Map<String, dynamic>> lugaresTepic = [];

  // VARIABLES DEL CONTADOR DE ACTIVIDAD
  int pasos = 0;
  double kilometros = 0.0;
  int minutos = 0;

  late Stream<StepCount> _stepCountStream;
  int _initialSteps = 0; // Para calcular los pasos tomados DURANTE la actividad
  bool _pedometerInitialized = false;

  void _initPedometer() async {
    try {
      _stepCountStream = Pedometer.stepCountStream;

      // Obtener el conteo inicial
      Pedometer.stepCountStream.listen((StepCount event) {
        if (!_pedometerInitialized) {
          _initialSteps = event.steps;
          _pedometerInitialized = true;
          print("Pasos iniciales: $_initialSteps");
        }

        // Calcular pasos tomados DURANTE la actividad (restando los iniciales)
        int stepsDuringActivity = event.steps - _initialSteps;

        if (!isPausado && countdown == 0) {
          setState(() {
            pasos = stepsDuringActivity > 0 ? stepsDuringActivity : 0;
            kilometros = pasos / PASOS_POR_KM;
          });
        }
      }).onError((error) {
        print("Pedometer error: $error");
      });
    } catch (e) {
      print("Error al inicializar pedómetro: $e");
    }
  }

  Future<bool> checkOrRequestBodySensors() async {
    return await Permission.sensors.request().isGranted;
  }

  void _checkPermissions() async {
    // FOR ANDROID
    if (Platform.isAndroid) {
      var status = await Permission.activityRecognition.request();

      bool status2 = await checkOrRequestBodySensors();

      if (status.isGranted) {
        _initPedometer();
      } else {
        print("PERMISSION DENIED");
      }
    }
    // FOR iOS
    else if (Platform.isIOS) {
      var status = await Permission.sensors.request();
      if (status.isGranted) {
        _initPedometer();
      } else {
        print("PERMISSION DENIED ON iOS");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    CargarUltimaActividad();
    CargarIdAmigo(); 
    empezarContador();
    sendNotification('FitFriends', 'Iniciando tu actividad');
  }

  @override
  void dispose() {
    GuardarUltimaUbicacion();
    countdow?.cancel();
    contadorActividad?.cancel();
    gpsTimer?.cancel();
    super.dispose();
  }

 

  Future<void> GuardarUltimaUbicacion() async {
    try {
      final LatLng center = mapController.camera.center;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setDouble(LAST_LAT_KEY, center.latitude);
      await prefs.setDouble(LAST_LNG_KEY, center.longitude);

      print('Ubicación guardada: ${center.latitude}, ${center.longitude}');

    } catch (e) {
      print('Error al guardar ubicación: ($e)');
    }
  }

  Future<void> CargarUltimaActividad() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? lastLat = prefs.getDouble(LAST_LAT_KEY);
    final double? lastLng = prefs.getDouble(LAST_LNG_KEY);

    if (lastLat != null && lastLng != null) {
      setState(() {
        ultimaPosicion = LatLng(lastLat, lastLng);
      });
    }
  }


  Future<void> CargarIdAmigo() async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID == null) {
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('amigos')) {
        final amigosList = userDoc.data()!['amigos'];

        if (amigosList is List && amigosList.isNotEmpty) {
          final List<String> loadedUids = amigosList.map((uid) => uid.toString()).toList();

          Map<String, String> nombresMap = {};

          // Cargar el documento de cada amigo para obtener su nombre
          for (String uid in loadedUids) {
            final friendDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();

            if (friendDoc.exists) {
              final friendData = friendDoc.data();
              final String name = friendData?['nombre'];
              nombresMap[uid] = name;
            }
          }

          setState(() {
            idAmigo = loadedUids;
            nombreAmigo = nombresMap;
          });
          print('ID y Nombres cargados con éxito: $nombreAmigo');
        }
      }
    } catch (e) {
      print('Error al cargar amigos: $e');
    }
  }


  
  Future<bool> ConPermisitoDijoMonchito() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("ubicación desactivada.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Permisos de ubicación negados.");
        return false;
      }
    }
    return true;
  }

  Future<void> RegistraUbicacinFirestore() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
      );

      final userID = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('live_locations')
          .doc(userID)
          .set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userID,
        'is_active': true,
      }, SetOptions(merge: true));

      try {
        if (!isPausado) {
          mapController.move(LatLng(position.latitude, position.longitude), 15);
        }
      } catch (e) {
        // Ignoramos el error si el mapa no está listo.
      }

    } catch (e) {
      print('Error al enviar ubicación a Firestore: $e');
    }
  }

  void ActualizaUbicacion() async {
    bool granted = await ConPermisitoDijoMonchito();
    if (!granted) return;

    
    gpsTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!isPausado) {
        RegistraUbicacinFirestore();
      }
    });
  }

  
  void empezarContador() {
    countdow = Timer.periodic( Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        EmpezarActividad();
      }
    });
  }

  void EmpezarActividad() {
    if (contadorActividad != null && contadorActividad!.isActive) return;

    ActualizaUbicacion();

    contadorActividad = Timer.periodic( Duration(seconds: 1), (timer) {
      if (!isPausado) {
        setState(() {
          if (timer.tick % 60 == 0) {
            minutos++;
          }
        });
      }
    });
  }

  void pause() {
    setState(() {
      isPausado = true;
    });
  }

  void reanudar() {
    setState(() {
      isPausado = false;
    });
  }

  void FinalizaActividad() {
    sendNotification('FitFriends', 'Terminando tu actividad');
    contadorActividad?.cancel();
    gpsTimer?.cancel();

    final userID = FirebaseAuth.instance.currentUser!.uid;
    // Marcar como inactivo
    try {
      FirebaseFirestore.instance
          .collection('live_locations')
          .doc(userID)
          .update({'is_active': false});
    } catch (e) {
      print('Errorcito: $e');
    }

    if (pasos > 0) {
      final Map<String, dynamic> resultados = {
        'pasos': pasos,
        'kilometros': kilometros,
        'minutos': minutos,
      };

      Navigator.pop(context, resultados);
    } else {
      Navigator.pop(context);
    }
  }

  void finalizar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:  Text("Terminar recorrido"),
          content:  Text("¿Estás seguro que quieres terminar tu recorrido?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text("NO"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                FinalizaActividad();
              },
              child:  Text("SÍ"),
            ),
          ],
        );
      },
    );
  }



  Widget marcador(String userId, Color color, String statusText) {
    final String SmilingFriend = nombreAmigo[userId] ?? 'Amigo';

    return Column(
      children: [
        Icon(
          Icons.person_pin_circle,
          color: color,
          size: 35,
        ),
        Text(
          SmilingFriend, 
          style:  TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            backgroundColor: Colors.white,
          ),
        ),
        Text(
          statusText,
          style:  TextStyle(
            fontSize: 8,
            color: Colors.grey,
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget ConstruirMapa({required List<Marker> friendMarkers}) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: ultimaPosicion,
        initialZoom: 13,
        minZoom: 0,
        maxZoom: 100,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),

        MarkerLayer(markers: friendMarkers),

        CurrentLocationLayer(
          style: LocationMarkerStyle(
            marker: Container(
              decoration:  BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
              ),
              child:  Icon(
                Icons.directions_run,
                color: Colors.white,
                size: 20,
              ),
            ),
            markerSize:  Size(30, 30),
          ),
        ),
      ],
    );
  }


  Widget getMap() {
    if (idAmigo.isEmpty) {
      return ConstruirMapa(friendMarkers: []);
    }

    final List<String> amigosParaConsulta = idAmigo.take(10).toList();

    final Stream<QuerySnapshot> filteredStream = FirebaseFirestore.instance
        .collection('live_locations')
        .where('userId', whereIn: amigosParaConsulta)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: filteredStream,
      builder: (context, snapshot) {

        List<Marker> friendMarkers = [];

        if (snapshot.hasError) {
          print("Error: ${snapshot.error}");
        }

        if (snapshot.hasData) {
          final UserActual = FirebaseAuth.instance.currentUser?.uid;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final AmigoID = data['userId'] as String;
            final bool isActive = data['is_active'] ?? false;


            if (AmigoID == UserActual) continue;

            if (data['latitude'] != null && data['longitude'] != null) {

              final Color markerColor = isActive ? Colors.red : Colors.grey;
              final String statusText = isActive ? 'Activo' : 'Última Ubicación';

              friendMarkers.add(
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(data['latitude'], data['longitude']),
                  child: marcador(AmigoID, markerColor, statusText),
                ),
              );
            }
          }
        }

        return ConstruirMapa(friendMarkers: friendMarkers);
      },
    );
  }


  Widget _buildMetricCard({
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      width: 100,
      padding:  EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset:  Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style:  TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
           SizedBox(height: 4),
          Text(label, style:  TextStyle(fontSize: 14, color: Colors.grey)),
          Text(unit, style:  TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String texto = countdown > 0
        ? "Inicia en: $countdown"
        : (isPausado ? "¡PAUSADO!" : "¡ACTIVIDAD EN CURSO!");

    String kmDisplay = kilometros.toStringAsFixed(2);
    String minDisplay = minutos.toString().padLeft(2, '0');
    String secDisplay = (contadorActividad != null && contadorActividad!.isActive && !isPausado)
        ? (contadorActividad!.tick % 60).toString().padLeft(2, '0')
        : '00';
    String timeDisplay = "$minDisplay:$secDisplay";

    return Scaffold(
      appBar: AppBar(
        title:  Text("Iniciando recorrido"),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back),
          onPressed: () {
            if (countdown == 0 && !isPausado) {
              finalizar();
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
             SizedBox(height: 20),
            Text(
              texto,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: countdown > 0
                    ? Colors.orange
                    : (isPausado ? Colors.red : Colors.green),
              ),
            ),
             SizedBox(height: 20),
            Container(
              height: 300,
              width: double.infinity,
              margin:  EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Center(child: getMap()),
            ),
             SizedBox(height: 40),
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricCard(
                    label: 'Tiempo',
                    value: timeDisplay,
                    unit: 'm:s',
                  ),
                  _buildMetricCard(
                    label: 'Pasos',
                    value: pasos.toString(),
                    unit: 'pasos',
                  ),
                  _buildMetricCard(
                    label: 'Distancia',
                    value: kmDisplay,
                    unit: 'km',
                  ),
                ],
              ),
            ),
             SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: countdown == 0 && !isPausado ? pause : null,
                  icon:  Icon(Icons.pause, color: Colors.white),
                  label:  Text("Pausar", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isPausado ? reanudar : null,
                  icon:  Icon(Icons.play_arrow, color: Colors.white),
                  label:  Text("Reanudar", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: countdown == 0 ? finalizar : null,
                  icon:  Icon(Icons.stop, color: Colors.white),
                  label:  Text("Terminar", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:  EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}