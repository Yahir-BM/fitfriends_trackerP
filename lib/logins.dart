import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitfriends_tracker/drawerPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class pag_autenticacion extends StatefulWidget {
  const pag_autenticacion({super.key});

  @override
  State<pag_autenticacion> createState() => _pag_autenticacionState();
}

class _pag_autenticacionState extends State<pag_autenticacion> {

  bool mostrarLogin = true;

  //Los controladores
  final TextEditingController nombreCont = TextEditingController();
  final TextEditingController contrasenaCont = TextEditingController();
  final TextEditingController emailCont = TextEditingController();

  //Función para registrar
  Future<void> registrar() async {
    String nombre = nombreCont.text.trim();
    String email = emailCont.text.trim();
    String pass = contrasenaCont.text.trim();

    // Validación rápida
    if (nombre.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, llena todos los campos.")),
      );
      return;
    }

    try {
      // Crear usuario en Firebase Auth
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      String uid = cred.user!.uid;

      //Campos que se van a generar en Firestore AUTOMÁTICAMENTE
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "nombre": nombre,
        "email": email,
        "fechaRegistro": DateTime.now(),
        "peso": null,
        "altura": null,
        "amigos": [],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cuenta creada correctamente")),
      );

      // Ir a la app principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => drawerPage()),
      );

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error Firebase: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: $e")),
      );
    }
  }

  //Función para iniciar sesión
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCont.text.trim(),
          password: contrasenaCont.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bienvenido!")),
      );

      //Navegar al drawer
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => drawerPage()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: mostrarLogin ? LoginCard() : RegistroCard(),
            )
          ),
        ),
      ),
    );
  }

  Widget LoginCard() {
    return Card(
      key: ValueKey("loginCard"),
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, size: 60, color: Colors.blueAccent,),
            SizedBox(height: 15,),
            
            Text("FitFriends", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent.shade700),),

            SizedBox(height: 20,),
            
            Text("Iniciar sesion", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
            SizedBox(height: 25),

            _inputText(emailCont, "Correo electrónico", Icons.email),
            SizedBox(height: 15,),

            _inputText(contrasenaCont, "Contraseña", Icons.lock, obscure: true),

            /*
            TextField(
              controller: nombreCont,
              decoration: InputDecoration(
                labelText: "Nombre de usuario",
                border: OutlineInputBorder(),
              ),
            ),*/

          /*  TextField(
              controller: emailCont,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: contrasenaCont,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(),
              ),
            ), */

            SizedBox(height: 25),
            
            _botonPrincipal("Iniciar sesión", login),

            /*
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: login,
                  child: Text("Iniciar sesion")
              ),
            ), */

            SizedBox(height: 20,),

            GestureDetector(
              onTap: (){
                setState(() {
                  mostrarLogin = false;
                });
              },
              child: Text("Aun no tienes cuenta? !Registrate aqui!", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),),
            ),
          ],
        ),
      ),
    );
  }

  //El Card de registro
  Widget RegistroCard() {
    return Card(
      key: ValueKey("registroCard"),
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add, size: 60, color: Colors.purpleAccent,),
            SizedBox(height: 10,),
            
            Text("Crear Cuenta", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),

            SizedBox(height: 25),

            /*
            TextField(
              controller: nombreCont,
              decoration: InputDecoration(
                labelText: "Nombre de usuario",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: emailCont,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15,),

            TextField(
              controller: contrasenaCont,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder()
              ),
            ),*/
            _inputText(nombreCont, "Nombre de usuario", Icons.person),
            SizedBox(height: 15,),
            
            _inputText(emailCont, "Correo electrónico", Icons.email),
            SizedBox(height: 15,),

            _inputText(contrasenaCont, "Contraseña", Icons.lock, obscure: true),

            SizedBox(height: 25,),

            /*SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: registrar,
                  child: Text("Registrate"),
              ),
            ), */
            
            _botonPrincipal("Registrarse", registrar),

            SizedBox(height: 20),

            GestureDetector(
              onTap: (){
                setState(() {
                  mostrarLogin = true;
                });
              },
              child: Text("Ya tienes cuenta? Inicia sesion", style: TextStyle(color: Colors.blue,decoration: TextDecoration.underline),),
            )
          ],
        ),
      ),
    );
  }

  //Widget que reemplaza los texfields normalones por unos un poco mejor detallados
  Widget _inputText(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  //Widget que remplaza el elevated buttom por uno con mejor diseño
  Widget _botonPrincipal(String texto, Function accion) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () => accion(),
        child: Text(texto, style: TextStyle(fontSize: 18)),
      ),
    );
  }

}
