import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarea7/screens/message_screen.dart';

class UsersScreen extends StatefulWidget {
  final String myUserId;

  const UsersScreen({
    Key? key,
    required this.myUserId,
  }) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  TextEditingController _searchController = TextEditingController();

  String _otherUserName =
      'Cargando...'; // Variable para almacenar el nombre del otro usuario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o correo electrónico...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final users = snapshot.data?.docs ?? [];
                final searchText = _searchController.text.toLowerCase();
                final filteredUsers = users.where((user) {
                  final userData = user.data() as Map<String, dynamic>;
                  final userName = userData['nombre']?.toLowerCase() ?? '';
                  final userEmail = userData['email']?.toLowerCase() ?? '';
                  return userName.contains(searchText) ||
                      userEmail.contains(searchText);
                }).toList();
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userData =
                        filteredUsers[index].data() as Map<String, dynamic>;
                    final userId = filteredUsers[index].id;
                    return ListTile(
                      title: Text(userData['nombre'] ?? ''),
                      subtitle: Text(userData['email'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.message),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessageScreen(
                                    userId: userId ?? '',
                                    myUserId: widget.myUserId,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.group_add),
                            onPressed: () {
                              _showAddToGroupBottomSheet(context, userId);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Al hacer tap en el usuario, obtén su nombre
                        _getOtherUserName(widget.myUserId);
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Muestra el nombre del otro usuario al final del body
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     'Nombre del otro usuario: $_otherUserName',
          //     style: TextStyle(fontSize: 16),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _showAddToGroupBottomSheet(BuildContext context, String userId) {
    // Implementación de showModalBottomSheet
  }

  Future<void> _getOtherUserName(String userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _otherUserName = userData['nombre'] ?? 'No proporcionado';
        });
      }
    } catch (e) {
      print('Error obteniendo el nombre del usuario: $e');
    }
  }
}
