import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageScreen extends StatefulWidget {
  final String userId;
  final String myUserId;

  const MessageScreen({Key? key, required this.userId, required this.myUserId})
      : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late String _userName = 'Cargando...';
  late String _userEmail = 'Cargando...';
  late String _myUserName = 'Cargando...';
  late String _myUserEmail = 'Cargando...';
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getMyUserData();
  }

  Future<void> _getMyUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.myUserId)
          .get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _myUserName = userData['nombre'] ?? 'Usuario';
          _myUserEmail = userData['email'] ?? 'No proporcionado';
        });
      }
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
    }
  }

  Future<void> _getUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _userName = userData['nombre'] ?? 'Usuario';
          _userEmail = userData['email'] ?? 'No proporcionado';
        });
      }
    } catch (e) {
      print('Error obteniendo datos del usuario: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'senderId': widget.myUserId,
        'receiverId': widget.userId,
        'message': message,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userName),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nombre: $_userName',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Email: $_userEmail',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Nombre: $_myUserName',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Email: $_myUserEmail',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('senderId', isEqualTo: widget.myUserId)
                  .where('receiverId', isEqualTo: widget.userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data?.docs ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final message = messageData['message'];
                    final senderId = messageData['senderId'];
                    final receiverId = messageData['receiverId'];
                    final timestamp = messageData['timestamp']?.toDate();
                    return ListTile(
                      title: Text(message),
                      subtitle: Text('Sent: ${timestamp.toString()}'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    // Aquí puedes implementar la lógica para enviar una imagen
                    print('Enviar imagen');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text;
                    _sendMessage(message);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
