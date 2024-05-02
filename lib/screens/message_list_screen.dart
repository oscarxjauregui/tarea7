import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_screen.dart'; // Importar el archivo de la pantalla de mensajes

class MessageListScreen extends StatefulWidget {
  final String myUserId;

  const MessageListScreen({Key? key, required this.myUserId}) : super(key: key);

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final Map<String, String> _userNames =
      {}; // Map to store user names efficiently
  final Set<String> _displayedUserIds = {}; // Set to store displayed user IDs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('ids', arrayContains: widget.myUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final messages = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final messageData =
                  messages[index].data() as Map<String, dynamic>;
              final ids = List<String>.from(messageData['ids'] ?? []);

              // Check if myUserId is in the first position to avoid unnecessary processing
              if (ids.indexOf(widget.myUserId) != 0) {
                return const SizedBox.shrink(); // Don't show message
              }

              final otherUserId = ids[1];

              // Retrieve user name only if not already stored and displayed
              if (!_userNames.containsKey(otherUserId)) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherUserId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink(); // Wait for data
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final userData =
                        snapshot.data?.data() as Map<String, dynamic>;
                    final userName = userData['nombre'] ?? 'Usuario';
                    _userNames[otherUserId] = userName;

                    // Call the helper method to build ListTile with user name
                    return _buildListTile(userName, otherUserId);
                  },
                );
              } else {
                // Use stored user name for efficiency
                final userName = _userNames[otherUserId]!;
                return _buildListTile(userName, otherUserId);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildListTile(String userName, String otherUserId) {
    // Verificar si otherUserId ya se ha mostrado antes
    if (_displayedUserIds.contains(otherUserId)) {
      // Si ya se ha mostrado, retornar un widget vacío
      return const SizedBox.shrink();
    } else {
      // Si no se ha mostrado, agregarlo al conjunto de IDs mostrados
      _displayedUserIds.add(otherUserId);
      return ListTile(
        title: Text(userName),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageScreen(
                userId: otherUserId,
                myUserId: widget.myUserId,
              ),
            ),
          );
        },
      );
    }
  }
}
