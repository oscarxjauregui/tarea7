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
  final Map<String, String> _lastMessages =
      {}; // Map to store last messages for each user
  final Set<String> _displayedUserIds = {}; // Set to store displayed user IDs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('ids', arrayContains: widget.myUserId)
            .orderBy('timestamp', descending: true)
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

              final otherUserId = ids.firstWhere((id) => id != widget.myUserId);

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
                    return _buildListTile(context, userName, otherUserId);
                  },
                );
              } else {
                // Use stored user name for efficiency
                final userName = _userNames[otherUserId]!;
                return _buildListTile(context, userName, otherUserId);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, String userName, String otherUserId) {
    final lastMessage = _lastMessages[otherUserId] ?? 'No hay mensajes';

    // Verificar si otherUserId ya se ha mostrado antes
    if (_displayedUserIds.contains(otherUserId)) {
      // Si ya se ha mostrado, retornar un widget vacío
      return const SizedBox.shrink();
    } else {
      // Si no se ha mostrado, agregarlo al conjunto de IDs mostrados
      _displayedUserIds.add(otherUserId);
      return InkWell(
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
        child: Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(userName),
            subtitle: Text(lastMessage),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeLastMessages();
  }

  Future<void> _initializeLastMessages() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('messages')
        .where('ids', arrayContains: widget.myUserId)
        .orderBy('timestamp', descending: true)
        .get();

    for (final doc in snapshot.docs) {
      final messageData = doc.data() as Map<String, dynamic>;
      final ids = List<String>.from(messageData['ids'] ?? []);

      final otherUserId = ids.firstWhere((id) => id != widget.myUserId);
      final message = messageData['message'] ?? '';

      if (!_lastMessages.containsKey(otherUserId)) {
        _lastMessages[otherUserId] = message;
      }
    }

    setState(() {});
  }
}
