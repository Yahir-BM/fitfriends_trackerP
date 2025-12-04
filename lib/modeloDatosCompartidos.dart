import 'package:flutter/material.dart';

// 1. Modelo de Datos para una Sola Actividad
class ActivityRecord {
  final DateTime date;
  final int pasos;
  final double kilometros;
  final int minutos;
  final String title;

  ActivityRecord({
    required this.date,
    required this.pasos,
    required this.kilometros,
    required this.minutos,
    required this.title,
  });
}

// 2. Administrador Global de Datos (Simplificado)
// Usamos este Singleton para simular la persistencia y el State Management.
class ActivityManager extends ChangeNotifier {
  // Acumuladores del día
  int _dailyPasos = 0;
  double _dailyKilometros = 0.0;
  int _dailyMinutos = 0;

  // Historial de actividades completadas
  final List<ActivityRecord> _history = [];

  // Getters para acceder a los datos
  int get dailyPasos => _dailyPasos;
  double get dailyKilometros => _dailyKilometros;
  int get dailyMinutos => _dailyMinutos;
  List<ActivityRecord> get history => _history;

  // Función para agregar una actividad finalizada
  void addActivity(int pasos, double km, int minutos) {
    // 1. Crear el nuevo registro de actividad
    final newRecord = ActivityRecord(
      date: DateTime.now(),
      pasos: pasos,
      kilometros: km,
      minutos: minutos,
      title: 'Caminata Rápida', // Título simple
    );

    // 2. Acumular al progreso diario
    _dailyPasos += pasos;
    _dailyKilometros += km;
    _dailyMinutos += minutos;

    // 3. Agregar al historial
    _history.insert(0, newRecord); // Insertar al inicio para mostrar lo más reciente

    // 4. Notificar a los Widgets que dependen de esta clase (como drawerPage e Historial)
    notifyListeners();

    print('Actividad registrada: Pasos: $pasos, Acumulado: $_dailyPasos');
  }

  // Reinicia los contadores diarios (útil para el final del día o pruebas)
  void resetDailyProgress() {
    _dailyPasos = 0;
    _dailyKilometros = 0.0;
    _dailyMinutos = 0;
    notifyListeners();
  }
}

// Instancia global para ser accesible en toda la app
final activityManager = ActivityManager();