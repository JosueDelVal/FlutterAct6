import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valenzuela/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PaperClip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: PaginaSesion(),
    );
  }
}

// ignore: must_be_immutable
class PaginaSesion extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // ignore: prefer_final_fields
  CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('registro');

  PaginaSesion({super.key});

  void _login(BuildContext context) async {
    String correo = _emailController.text;
    String clave = _passwordController.text;

    QuerySnapshot querySnapshot = await _usersCollection
        .where('correo', isEqualTo: correo)
        .where('clave', isEqualTo: clave)
        .get();

    if (querySnapshot.size > 0) {
      // Inicio de sesión exitoso, redirigir a la página principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PaginaInicio(correo)),
      );
    } else {
      // Mostrar un diálogo de error en caso de inicio de sesión fallido
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ah ocurrido un error!'),
            content:
                const Text('Correo o clave incorrectos. Inténtalo de nuevo.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _registro(BuildContext context) async {
    String correo = _emailController.text;
    String clave = _passwordController.text;

    QuerySnapshot querySnapshot =
        await _usersCollection.where('correo', isEqualTo: correo).get();

    if (querySnapshot.size > 0) {
      // Mostrar un diálogo de error en caso de que el usuario ya esté registrado
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error de registro'),
            content: const Text('Usuario ya registrado.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Registrar al usuario en Firestore
      await _usersCollection.add({
        'correo': correo,
        'clave': clave,
      });

      // Mostrar un diálogo de registro exitoso
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Registro exitoso'),
            content: const Text('Registrado correctamente.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('PaperClip'),
        backgroundColor: Colors.green,
        elevation: 15,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              "Inicio de sesión o registro",
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 2.5,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(190, 40),
                backgroundColor: Colors.red,
              ),
              onPressed: () => _login(context),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: const Text(
                'Registrarse',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 40),
                backgroundColor: Colors.red,
              ),
              onPressed: () => _registro(context),
            ),
          ],
        ),
      ),
    );
  }
}

class PaginaInicio extends StatelessWidget {
  final String _correo;

  const PaginaInicio(this._correo, {super.key});

  void _cerrarSesion(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PaginaSesion()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('PaperClip'),
        backgroundColor: Colors.green,
        elevation: 8,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¡Inicio de sesión exitoso!'),
            const SizedBox(height: 20.0),
            Text('Bienvenido $_correo'),
            const SizedBox(height: 20.0),
            ElevatedButton(
              child: const Text('Cerrar sesión'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(190, 40),
                backgroundColor: Colors.red,
              ),
              onPressed: () => _cerrarSesion(context),
            ),
          ],
        ),
      ),
    );
  }
}
