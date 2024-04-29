import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupDescriptionController = TextEditingController();

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
      FirebaseFirestore.instance.collection('groups').add({
        'nombre': groupName,
        'descripcion': groupDescription,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grupos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showCreateGroupBottomSheet(context);
            },
          ),
        ],
      ),
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
                    return InkWell(
                      onTap: () {
                        // Implementa aquí la acción al hacer clic en el grupo
                      },
                      child: Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(groupData['nombre'] ?? ''),
                          subtitle: Text(groupData['descripcion'] ?? ''),
                          // Agregar cualquier otro campo relevante para tu grupo aquí
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
    );
  }
}
