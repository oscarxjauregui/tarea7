import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tarea7/screens/message_screen.dart';
import 'group_chat_screen.dart'; // Importar el archivo de la pantalla de chat de grupo

class MessageListScreen extends StatefulWidget {
  final String myUserId;

  const MessageListScreen({Key? key, required this.myUserId}) : super(key: key);

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final Map<String, String> _userNames =
      {}; // Mapa para almacenar nombres de usuario eficientemente
  final Map<String, Map<String, dynamic>> _lastMessages =
      {}; // Mapa para almacenar los últimos mensajes y fecha para cada usuario
  final Set<String> _displayedUserIds =
      {}; // Conjunto para almacenar IDs de usuario mostrados
  final Map<String, String> _groupNames =
      {}; // Mapa para almacenar nombres de grupos
  final Map<String, String> _lastGroupMessages =
      {}; // Mapa para almacenar el último mensaje de cada grupo
  final Map<String, String> _lastGroupMessageDates =
      {}; // Mapa para almacenar la fecha del último mensaje de cada grupo
  final List<String> _groupIds =
      []; // Lista para almacenar IDs de grupos del usuario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Sección de lista de mensajes de usuarios
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Chats',
              textAlign: TextAlign.left, // Alineación a la izquierda
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                    final otherUserId =
                        ids.firstWhere((id) => id != widget.myUserId);

                    if (!_userNames.containsKey(otherUserId)) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(otherUserId)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox.shrink(); // Esperar los datos
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final userData =
                              snapshot.data?.data() as Map<String, dynamic>;
                          final userName = userData['nombre'] ?? 'Usuario';
                          _userNames[otherUserId] = userName;

                          return _buildListTile(context, userName, otherUserId);
                        },
                      );
                    } else {
                      final userName = _userNames[otherUserId]!;
                      return _buildListTile(context, userName, otherUserId);
                    }
                  },
                );
              },
            ),
          ),
          // Sección de lista de grupos
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, String userName, String otherUserId) {
    final lastMessageData = _lastMessages[otherUserId];
    final lastMessage = lastMessageData != null
        ? lastMessageData['message'] ?? 'No hay mensajes'
        : 'No hay mensajes';
    final lastMessageDate =
        lastMessageData != null ? lastMessageData['date'] : null;

    if (_displayedUserIds.contains(otherUserId)) {
      return const SizedBox.shrink();
    } else {
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lastMessage),
                if (lastMessageDate != null)
                  Text(
                    DateFormat('dd-MM-yyyy HH:mm').format(lastMessageDate),
                  ),
              ],
            ),
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
      final date = messageData['timestamp'] != null
          ? (messageData['timestamp'] as Timestamp).toDate()
          : null;

      if (!_lastMessages.containsKey(otherUserId)) {
        _lastMessages[otherUserId] = {'message': message, 'date': date};
      }
    }

    setState(() {});
  }
}
