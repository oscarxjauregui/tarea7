import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tarea7/screens/groups_screen.dart';
import 'package:tarea7/screens/login_screen.dart';
import 'package:tarea7/screens/message_list_screen.dart';
import 'package:tarea7/screens/myuser_screen.dart';
import 'package:tarea7/screens/select_avatar_screen.dart';
import 'package:tarea7/screens/users_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({required this.userId, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userEmail;
  String? avatarUrl;
  int _selectedIndex = 0;
  late List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDocument.exists) {
        final userData = userDocument.data()!;
        setState(() {
          userName = userData['nombre'];
          userEmail = userData['email'];
          _screens = [
            UsersScreen(myUserId: widget.userId),
            MessageListScreen(myUserId: widget.userId),
            GroupsScreen(userId: widget.userId),
          ];
        });
      }
    } catch (e) {
      print(e);
    }

    // Llamar a la función para obtener la URL del avatar después de obtener los datos del usuario.
    _getAvatarUrl();
  }

  Future<void> _getAvatarUrl() async {
    try {
      final reference =
          FirebaseStorage.instance.ref().child('avatars/${widget.userId}.png');
      final url = await reference.getDownloadURL();
      setState(() {
        avatarUrl = url;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 15, 182, 104),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: avatarUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(avatarUrl!),
                      )
                    : CircleAvatar(
                        child: Icon(
                          Icons.person,
                          size: 50,
                        ),
                      ),
                accountName: Text(userName ?? 'Cargando...'),
                accountEmail: Text(userEmail ?? 'Cargando...'),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 15, 182, 104),
                      Color.fromARGB(255, 10, 150, 85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Mi perfil'),
                subtitle: Text('Ver mi perfil'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyUserScreen(userId: widget.userId),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.add_photo_alternate),
                title: Text('Seleccionar foto'),
                subtitle: Text('Cambiar foto de perfil'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SelectAvatarScreen(userId: widget.userId),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Salir'),
                subtitle: Text('Cerrar sesión'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _screens.isNotEmpty
            ? _screens[_selectedIndex]
            : Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscar Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Grupos',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Buscar Usuarios';
      case 1:
        return 'Lista de Mensajes';
      case 2:
        return 'Grupos';
      default:
        return 'Inicio';
    }
  }
}
