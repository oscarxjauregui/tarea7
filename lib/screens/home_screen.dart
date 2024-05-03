import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tarea7/screens/groups_screen.dart';
import 'package:tarea7/screens/message_list_screen.dart';
import 'package:tarea7/screens/select_avatar_screen.dart';
import 'package:tarea7/screens/users_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;

  const HomeScreen({required this.userEmail, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userEmail;
  String? avatarUrl;
  String? userId;
  int _selectedIndex = 0;
  late List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.userEmail)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        final userData = userQuerySnapshot.docs.first.data();
        setState(() {
          userName = userData['nombre'];
          userEmail = userData['email'];
          userId = userQuerySnapshot.docs.first.id;
          _screens = [
            UsersScreen(myUserId: userId ?? ''),
            MessageListScreen(myUserId: userId ?? ''),
            GroupsScreen(userId: userId ?? ''),
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
      final reference = FirebaseStorage.instance.ref().child('avatar1.png');
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
        title: Text(_getAppBarTitle(_selectedIndex)),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
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
                    builder: (context) => SelectAvatarScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text('Salir'),
              subtitle: Text('Cerrar sesion'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _screens.isNotEmpty ? _screens[_selectedIndex] : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
        return 'Mensajes';
      case 2:
        return 'Grupos';
      default:
        return 'Inicio';
    }
  }
}
