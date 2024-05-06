import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarea7/screens/select_avatar_screen.dart';

class MyUserScreen extends StatefulWidget {
  final String userId;

  const MyUserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyUserScreen> createState() => _MyUserScreenState();
}

class _MyUserScreenState extends State<MyUserScreen> {
  late String _userName = '';
  late String _userEmail = '';
  late String _userRole = '';
  late String _userAvatarUrl = '';
  late String _userCarrera = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _userName = userData['nombre'] ?? 'Nombre no disponible';
          _userEmail = userData['email'] ?? 'Correo no disponible';
          _userRole = userData['rol'] ?? 'Rol no disponible';
          _userCarrera = userData['carrera'] ?? 'Carrera no disponible';
        });
      }

      final avatarSnapshot = await FirebaseFirestore.instance
          .collection('avatars')
          .doc(widget.userId)
          .get();
      if (avatarSnapshot.exists) {
        final avatarData = avatarSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _userAvatarUrl = avatarData['imageUrl'];
        });
      }
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi perfil'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 100,
                backgroundImage: _userAvatarUrl.isNotEmpty
                    ? NetworkImage(_userAvatarUrl)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectAvatarScreen(
                              userId: widget.userId,
                            )),
                  );
                },
                child: Text(
                  'Cambiar imagen',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '$_userName',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 15),
              Text(
                '$_userEmail',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '$_userRole',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
