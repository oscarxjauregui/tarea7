import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tarea7/screens/groups_screen.dart';
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
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getAvatarUrl();
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
        });
      }
    } catch (e) {
      print(e);
    }
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
        title: Text('Inicio'),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.search),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => UsersScreen(),
          //       ),
          //     );
          //   },
          // ),
        ],
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
      body: Column(
        children: [
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            childAspectRatio: 1.0,
            children: [
              _buildIconBox(Icons.search, 'Buscar Usuarios', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsersScreen(),
                  ),
                );
              }),
              _buildIconBox(Icons.message, 'Mensajes', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsersScreen(),
                  ),
                );
              }),
              _buildIconBox(Icons.group, 'Grupos', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupsScreen(
                      userId: userId ?? '',
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.all(8.0), // Agrega espacio alrededor del cuadro
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300], // Gris claro
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48.0,
              ),
              SizedBox(height: 8.0),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
