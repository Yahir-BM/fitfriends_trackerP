//aqui te toca el login yahir mi pa
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 800),
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
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Iniciar sesion", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            SizedBox(height: 25),

            /*
            TextField(
              controller: nombreCont,
              decoration: InputDecoration(
                labelText: "Nombre de usuario",
                border: OutlineInputBorder(),
              ),
            ),*/

            TextField(
              controller: emailCont,
              decoration: InputDecoration(
                labelText: "Correo electronico",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: contrasenaCont,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contrasena",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: (){
                    //Para conectar a firebase
                  },
                  child: Text("Iniciar sesion")
              ),
            ),

            SizedBox(height: 20,),

            GestureDetector(
              onTap: (){
                setState(() {
                  mostrarLogin = false;
                });
              },
              child: Text("Aun no tienes cuenta? Registrate aqui!", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),),
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
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Crear Cuenta", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),

            SizedBox(height: 25),

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
                labelText: "Correo electronico",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15,),

            TextField(
              controller: contrasenaCont,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "Contrasena",
                  border: OutlineInputBorder()
              ),
            ),

            SizedBox(height: 20,),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  //Para registrar con firebase
                },
                child: Text("Registrate"),
              ),
            ),

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

}
