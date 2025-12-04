import 'dart:ui';
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
          SnackBar(content: Text('Ya no eres amigo de esta persona :(' )),
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

  // Metodo para actualizar lista in real time
  Stream<List<Map<String, dynamic>>> obtenerAmigos(String uidActual) {
    if (uidActual.isEmpty) return Stream.value([]);

    return firestore
        .collection('users')
        .doc(uidActual)
        .snapshots()
        .asyncMap((usuarioDoc) async {

      if (!usuarioDoc.exists) return [];

      final amigosData = usuarioDoc.get('amigos');
      List<String> amigosIds = [];
      if (amigosData is List) amigosIds = amigosData.map((id) => id.toString()).toList();

      if (amigosIds.isEmpty) return [];

      // Limitamos a 10 amigos (por whereIn)
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
          'fotoPerfil': data['fotoPerfil'] ?? null, // 🔥 foto agregada
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
          SnackBar(content: Text('Amigo agregado exitosamente :)')),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
        );
      }
    } finally {
      if (mounted) setState(() => carganding = false);
    }
  }

  void DialogoAgregarAmigo() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: AlertDialog(
            backgroundColor: Colors.white38,
            title: Text('Agrega un Amigo', style: TextStyle(color: Colors.white)),
            content: TextField(
              controller: usuarioController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre amigo',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white38,
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nombre = usuarioController.text.trim();
                  if (nombre.isEmpty) return;
                  Navigator.pop(context);
                  await AmigoAgregado(nombre);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Agregar'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Dialogo para confirmar si elimina un amigo
  void confirmarEliminarAmigo(BuildContext context, String nombreAmigo, String idAmigo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Seguro que quieres eliminar a: $nombreAmigo de tu lista de amigos? :('),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              _eliminarAmigo(idAmigo);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text('Mis Amigos ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: obtenerAmigos(user.uid),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));

          final amigos = snapshot.data ?? [];

          if (amigos.isEmpty) {
            return Center(
              child: Text("Sin amigos aún 😢\nAgrega algunos con el botón +",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 18)),
            );
          }

          // Mostrar la lista de amigos
          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: amigos.length,
            itemBuilder: (context, index) {

              final amigo = amigos[index];
              final String idAmigo = amigo['id'];
              final String nombreAmigo = amigo['nombre'];
              final String? foto = amigo["fotoPerfil"];

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Container(

                  //Estilo chido
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),

                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      backgroundImage: (foto != null && foto.isNotEmpty)
                          ? NetworkImage(foto)
                          : null,
                      child: (foto == null || foto.isEmpty)
                          ? Text(
                        nombreAmigo[0].toUpperCase(),
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      )
                          : null,
                    ),

                    title: Text(nombreAmigo,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    subtitle: Text(amigo['email'], style: TextStyle(color: Colors.white70)),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
                          tooltip: 'Iniciar Chat',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          tooltip: 'Eliminar amigo',
                          onPressed: carganding ? null : () => confirmarEliminarAmigo(context, nombreAmigo, idAmigo),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: carganding ? null : DialogoAgregarAmigo,
        backgroundColor: Colors.blueAccent,
        child: carganding
            ? CircularProgressIndicator(color: Colors.white)
            : Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
