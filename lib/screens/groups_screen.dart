import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarea7/constant/callPage.dart';
import 'package:tarea7/screens/group_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  final String userId;

  const GroupsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupDescriptionController = TextEditingController();

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = widget.userId;
  }

  void _showCreateGroupBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del grupo',
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _groupDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción del grupo',
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _createGroup();
                    Navigator.pop(context);
                  },
                  child: Text('Guardar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createGroup() {
    final String groupName = _groupNameController.text.trim();
    final String groupDescription = _groupDescriptionController.text.trim();
    if (groupName.isNotEmpty) {
      // Añadir el grupo a la colección 'groups'
      final groupRef = FirebaseFirestore.instance.collection('groups').doc();
      groupRef.set({
        'nombre': groupName,
        'descripcion': groupDescription,
        'callID': Random().nextInt(9999),
      }).then((_) {
        // Agregar el ID del grupo a la colección 'group-user'
        FirebaseFirestore.instance.collection('group-user').add({
          'groupId': groupRef.id,
          'userId': currentUserId,
        }).then((_) {
          // Éxito al agregar el ID del grupo en 'group-user'
          print('ID del grupo agregado en group-user');
        }).catchError((error) {
          // Error al agregar el ID del grupo en 'group-user'
          print('Error al agregar el ID del grupo: $error');
        });
      }).catchError((error) {
        // Error al agregar el grupo en 'groups'
        print('Error al agregar el grupo: $error');
      });
    }
  }

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
                hintText: 'Buscar por nombre de grupo...',
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
                  FirebaseFirestore.instance.collection('groups').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final groups = snapshot.data?.docs ?? [];
                final searchText = _searchController.text.toLowerCase();
                final filteredGroups = groups.where((group) {
                  final groupData = group.data() as Map<String, dynamic>;
                  final groupName = groupData['nombre']?.toLowerCase() ?? '';
                  return groupName.contains(searchText);
                }).toList();
                return ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final groupData =
                        filteredGroups[index].data() as Map<String, dynamic>;
                    final groupId = filteredGroups[index].id;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupChatScreen(
                              groupId: groupId,
                              myUserId: currentUserId ?? '',
                            ),
                          ),
                        );
                        // Implementa aquí la acción al hacer clic en el grupo
                      },
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(groupData['nombre'] ?? ''),
                          subtitle: Text(groupData['descripcion'] ?? ''),
                          // Agregar el número de usuarios en el grupo
                          trailing: FutureBuilder<int>(
                            future: _getGroupUserCount(groupId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox.shrink();
                              }
                              if (snapshot.hasError) {
                                return Text('Error');
                              }
                              return Text('${snapshot.data ?? 0} usuarios');
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateGroupBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<int> _getGroupUserCount(String groupId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('group-user')
          .where('groupId', isEqualTo: groupId)
          .get();
      return querySnapshot.size;
    } catch (e) {
      print('Error al obtener el número de usuarios del grupo: $e');
      return 0;
    }
  }
}
