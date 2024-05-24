import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarea7/screens/group_chat_screen.dart';
import 'package:tarea7/screens/home_screen.dart';

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

  void _showCreateGroupBottomSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del grupo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: _groupDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción del grupo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    _createGroup();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 10, 162, 91),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Guardar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createGroup() async {
    final String groupName = _groupNameController.text.trim();
    final String groupDescription = _groupDescriptionController.text.trim();
    if (groupName.isNotEmpty) {
      final groupRef = FirebaseFirestore.instance.collection('groups').doc();
      groupRef.set({
        'nombre': groupName,
        'descripcion': groupDescription,
        'callID': Random().nextInt(9999),
      }).then((_) {
        FirebaseFirestore.instance.collection('group-user').add({
          'groupId': groupRef.id,
          'userId': currentUserId,
        }).then((_) {
          print('ID del grupo agregado en group-user');
          Future.delayed(Duration(seconds: 1));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                userId: currentUserId ?? '',
              ),
            ),
          );
        }).catchError((error) {
          print('Error al agregar el ID del grupo: $error');
        });
      }).catchError((error) {
        print('Error al agregar el grupo: $error');
      });
    }
  }

  Future<List<String>> _getUserGroupIds() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('group-user')
        .where('userId', isEqualTo: currentUserId)
        .get();
    return querySnapshot.docs.map((doc) => doc['groupId'] as String).toList();
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
            child: FutureBuilder<List<String>>(
              future: _getUserGroupIds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final userGroupIds = snapshot.data ?? [];
                if (userGroupIds.isEmpty) {
                  return Center(child: Text('No tienes grupos.'));
                }
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('groups')
                      .where(FieldPath.documentId, whereIn: userGroupIds)
                      .snapshots(),
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
                      final groupName =
                          groupData['nombre']?.toLowerCase() ?? '';
                      return groupName.contains(searchText);
                    }).toList();
                    return ListView.builder(
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, index) {
                        final groupData = filteredGroups[index].data()
                            as Map<String, dynamic>;
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
                          },
                          child: Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(groupData['nombre'] ?? ''),
                              subtitle: Text(groupData['descripcion'] ?? ''),
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
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showCreateGroupBottomSheet(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 28, 215, 128),
        foregroundColor: Colors.black,
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
