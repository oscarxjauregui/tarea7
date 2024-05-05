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

  String _otherUserName = 'Cargando...';

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
                  final userId = user.id;
                  // Excluir el usuario actual
                  return userId != widget.myUserId &&
                      (userName.contains(searchText) ||
                          userEmail.contains(searchText));
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
                        _getOtherUserName(userId);
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

  void _showAddToGroupBottomSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder(
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
                final groupData = groups[index].data() as Map<String, dynamic>;
                final groupId = groups[index].id;
                final groupName = groupData['nombre'] ?? '';
                final groupDescription = groupData['descripcion'] ?? '';
                return InkWell(
                  child: Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(
                        groupName,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      subtitle: Text(groupDescription),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          final isAlreadyInGroup =
                              await _checkIfUserInGroup(userId, groupId);
                          if (isAlreadyInGroup) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('No se puede agregar, el usuario ya está en este grupo'),
                            ));
                          } else {
                            _addToGroup(userId, groupId);
                            Navigator.pop(context); // Cerrar el BottomSheet
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _checkIfUserInGroup(String userId, String groupId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('group-user')
          .where('groupId', isEqualTo: groupId)
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar si el usuario está en el grupo: $e');
      return false;
    }
  }

  Future<void> _addToGroup(String userId, String groupId) async {
    try {
      await FirebaseFirestore.instance.collection('group-user').add({
        'userId': userId,
        'groupId': groupId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario agregado al grupo')),
      );
    } catch (e) {
      print('Error al agregar usuario al grupo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar usuario al grupo')),
      );
    }
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
