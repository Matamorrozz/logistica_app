import 'package:entregas/CalidadPage.dart';
import 'package:entregas/LogisticaPage.dart';
import 'package:entregas/pages/maquinas_screen.dart';
import 'package:entregas/pages/personal_screen.dart';
import 'package:entregas/pages/usuarios_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    CalidadPage(),
    LogisticaPage(),
    MaquinasScreen(),
    UsuariosScreen(),
    PersonalScreen(),
  ];

  final User? user = FirebaseAuth.instance.currentUser;
  final bool isAdmin = FirebaseAuth.instance.currentUser?.email ==
          'maximiliano.martinez@bladecsi.com' ||
      FirebaseAuth.instance.currentUser?.email ==
          'jaime.flores@asiarobotica.com' ||
      FirebaseAuth.instance.currentUser?.email ==
          'fernando.reyes@asiarobotica.com' ||
      FirebaseAuth.instance.currentUser?.email == 'ana.lira@asiarobotica.com' ||
      FirebaseAuth.instance.currentUser?.email == 'prueba@hotmail.com';

  Future<void> signOutWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  void cerrarSesion() async {
    FirebaseAuth.instance.signOut();
    await signOutWithGoogle();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Container(
                color: Colors.white,
                child: Image.asset(
                  'lib/images/ar_inicio.png',
                  height: 44,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Inicio',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: cerrarSesion,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Center(
                  child: Text(
                    'Salir',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: 'Calidad',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Logística',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.precision_manufacturing),
            label: 'Máquinas',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Colaboradores',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Personal',
            backgroundColor: Colors.black,
          ),
          
   
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 240, 5, 5),
        onTap: _onItemTapped,
      ),
    );
  }
}
