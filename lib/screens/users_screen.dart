import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarea7/screens/message_screen.dart';

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
                      onTap: () {},
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

  void _showAddToGroupBottomSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(top: 20),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('groups').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final groups = snapshot.data?.docs ?? [];
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final groupData =
                      groups[index].data() as Map<String, dynamic>;
                  final groupId = groups[index].id;
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('group-user')
                        .where('groupId', isEqualTo: groupId)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final userCount = snapshot.data?.docs.length ?? 0;
                      final userExists = snapshot.data?.docs
                              .any((doc) => doc['userId'] == userId) ??
                          false;
                      return ListTile(
                        title: Text(groupData['nombre'] ?? ''),
                        subtitle: Text(groupData['descripcion'] ?? ''),
                        trailing: Text('$userCount usuarios'),
                        onTap: () {
                          if (userExists) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('No se puede agregar'),
                                  content: Text('¡Ya está en este grupo!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirmar'),
                                  content: Text(
                                      '¿Desea agregar a este usuario al grupo?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        _joinGroup(userId, groupId);
                                        Navigator.pop(
                                            context); // Cierra el cuadro de diálogo
                                        Navigator.pop(
                                            context); // Cierra el bottom sheet
                                      },
                                      child: Text('Sí'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Cierra el cuadro de diálogo
                                      },
                                      child: Text('Cancelar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> _checkIfUserIsInGroup(String userId, String groupId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('group-user')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isEqualTo: userId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> _joinGroup(String userId, String groupId) async {
    try {
      await FirebaseFirestore.instance.collection('group-user').add({
        'groupId': groupId,
        'userId': userId,
      });
    } catch (e) {
      print(e);
    }
  }
}
