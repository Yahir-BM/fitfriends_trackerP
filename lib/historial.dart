//el historial de las corridad guardadas en firestore
//queeeeeee


import 'package:flutter/material.dart';

class Historial extends StatefulWidget {
  const Historial({super.key});

  @override
  State<Historial> createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context); //regresa a la pagina anterior
        }, icon: Icon(Icons.arrow_back)),
      ),

      body: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: 3, //cantidad de tarjetitas que se van a mostrar
        itemBuilder: (context, i) {
          //los datos de los dolls

          return Card(
            color: Colors.green,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text("X cantidad de kilometros"),
              subtitle: Text("Bien fakin rapido"),
              trailing:
              Icon(Icons.directions_run, color: Colors.white),
            ),
          );
        },
      ), //si lo quito aqui va el ;
    );
  }
}
