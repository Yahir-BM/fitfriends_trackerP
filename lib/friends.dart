import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Amigos extends StatefulWidget {
  const Amigos({Key? key}) : super(key: key);

  @override
  _AmigosState createState() => _AmigosState();
}

class _AmigosState extends State<Amigos> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController usuarioController = TextEditingController();
  bool carganding = false;



  @override
  void dispose() {
    usuarioController.dispose();
    super.dispose();
  }


  // metodo para agregar amigo
  Future<void> agregarAmigo(String nombreAmigo, String uidActual) async {
    try {
      //Busca el id de otro usuario a partir del nombre
      QuerySnapshot query = await firestore
          .collection('users')
          .where('nombre', isEqualTo: nombreAmigo)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Nombre de usuario no encontrado');
      }

      String idAmigo = query.docs.first.id;

      if (idAmigo == uidActual) {
        throw Exception('No puedes agregarte a ti mismo'); //para que no te agregues a ti mismo
      }

      //Comprobacion para saber si el amiguito ya existe
      DocumentSnapshot usuarioDoc = await firestore
          .collection('users')
          .doc(uidActual)
          .get();

      if (usuarioDoc.exists) {
        final amigosData = usuarioDoc.get('amigos');
        List<dynamic> amigosActuales = (amigosData is List) ? amigosData : [];
        if (amigosActuales.contains(idAmigo)) {
          throw Exception('Ya está en tu lista de amigos');
        }
      }

      // Agregar a el id al campo amigos
      await firestore.collection('users').doc(uidActual).update({
        'amigos': FieldValue.arrayUnion([idAmigo])
      });

    } catch (e) {
      rethrow;
    }
  }

  // Metodo para eliminar a un amigo
  Future<void> _eliminarAmigo(String idAmigo) async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }
    setState(() => carganding = true);

    try {
      await firestore.collection('users').doc(user.uid).update({ 
        'amigos': FieldValue.arrayRemove([idAmigo]) // con FieldValue.arrayRemove se quita el id del amigo
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya no eres amigo de esta persona :(' )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => carganding = false);
      }
    }
  }


  // Metodo para actualizar la lista in real time cuando eliminas o agregas un amigo
  Stream<List<Map<String, dynamic>>> obtenerAmigos(String uidActual) {
    if (uidActual.isEmpty) {
      return Stream.value([]);
    }

    return firestore
        .collection('users')
        .doc(uidActual)
        .snapshots()
        .asyncMap((usuarioDoc) async {

      if (!usuarioDoc.exists) return [];

      final amigosData = usuarioDoc.get('amigos');
      List<String> amigosIds = [];
      if (amigosData is List) {
        amigosIds = amigosData.map((id) => id.toString()).toList();
      }

      if (amigosIds.isEmpty) return [];

      // Segun el un pajarito el 'whereIn' tiene un limite por restriciones del firebase
      // para mostrar solo 10 amigos (tu que opinas felipe?)
      final idsToQuery = amigosIds.length > 10 ? amigosIds.sublist(0, 10) : amigosIds;

      QuerySnapshot amigosQuery = await firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: idsToQuery)
          .get();

      return amigosQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'nombre': data['nombre'],
          'email': data['email'],
        };
      }).toList();
    });
  }



  Future<void> AmigoAgregado(String nombre) async {
    if (!mounted) return;

    setState(() => carganding = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No autenticado');

      await agregarAmigo(nombre, user.uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amigo agregado exitosamente :)')),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => carganding = false);
      }
    }
  }

  void DialogoAgregarAmigo() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        usuarioController.clear();
        return AlertDialog(
          title:  Text('Agrega un Amigo'),
          content: TextField(
            controller: usuarioController,
            decoration:  InputDecoration(
              labelText: 'Nombre amigo',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); },
              child:  Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = usuarioController.text.trim();
                if (nombre.isEmpty) return;

                Navigator.pop(context);
                await AmigoAgregado(nombre);
              },
              child:  Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Dialogo para confirmar si se elimina un amigo
  void confirmarEliminarAmigo(BuildContext context, String nombreAmigo, String idAmigo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text('Confirmar Eliminación'),
          content: Text('¿Seguro que quieres eliminar a: $nombreAmigo de tu lista de amigos? :('),
          actions: <Widget>[
            TextButton(
              child:  Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _eliminarAmigo(idAmigo);
              },
            ),
          ],
        );
      },
    );
  }



  @override

  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;


    return Scaffold(
      appBar: AppBar(title: const Text('Mis Amigos')),


      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: obtenerAmigos(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final amigos = snapshot.data ?? [];

          if (amigos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.group, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Sin amigos...'),
                  Text('Agrega amigos usando el botón +'),
                ],
              ),
            );
          }

          // Mostrar la lista de amigos
          return ListView.builder(
            itemCount: amigos.length,
            itemBuilder: (context, index) {
              final amigo = amigos[index];
              final String idAmigo = amigo['id'];
              final String nombreAmigo = amigo['nombre'];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(nombreAmigo.isNotEmpty ? nombreAmigo[0].toUpperCase() : '?'),
                ),
                title: Text(nombreAmigo),
                subtitle: Text(amigo['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.blueGrey),
                      tooltip: 'Iniciar Chat',
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar amigo',
                      onPressed: carganding
                          ? null
                          : () { confirmarEliminarAmigo(context, nombreAmigo, idAmigo);}
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: carganding ? null : DialogoAgregarAmigo,
        child: carganding
            ? const Center(child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
        ))
            : const Icon(Icons.add),
      ),
    );
  }
}