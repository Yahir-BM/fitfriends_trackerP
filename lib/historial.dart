//el historial de las corridad guardadas en firestore
//queeeeeee


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'modeloDatosCompartidos.dart';
import 'package:intl/intl.dart';


class Historial extends StatelessWidget {
  const Historial({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para escuchar los cambios en el historial
    return Consumer<ActivityManager>(
      builder: (context, manager, child) {
        final history = manager.history;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Historial de Actividades"),
            leading: IconButton(onPressed: (){
              Navigator.pop(context); //regresa a la pagina anterior
            }, icon: const Icon(Icons.arrow_back)),
          ),

          body: history.isEmpty
              ? const Center(
            child: Text(
              "¡Aún no hay actividades completadas! ¡Sal a caminar!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: history.length,
            itemBuilder: (context, i) {
              final record = history[i];
              // Formatear la fecha
              final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
              final dateString = dateFormat.format(record.date);

              return Card(
                color: Colors.green.shade400,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.directions_run, color: Colors.white, size: 40),
                  title: Text(
                    record.title, // Título de la actividad
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        "${record.kilometros.toStringAsFixed(2)} km - ${record.pasos} pasos",
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        "${record.minutos} minutos. Completada el $dateString",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onTap: () {
                    // Acción al hacer clic en el historial (ej. ver detalles)
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}