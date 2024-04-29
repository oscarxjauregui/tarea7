import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuarios'),
      ),
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
                    return ListTile(
                      title: Text(userData['nombre'] ?? ''),
                      subtitle: Text(userData['email'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.message),
                            onPressed: () {
                              // Acción cuando se presiona el icono de mensaje
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.group_add),
                            onPressed: () {
                              // Acción cuando se presiona el icono de agregar a grupo
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Acción cuando se selecciona un usuario
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
