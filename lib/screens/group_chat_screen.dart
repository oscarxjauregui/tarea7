import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tarea7/constant/callGroup.dart';

class ImageController extends ChangeNotifier {
  File? _imageFile;
  File? get imageFile => _imageFile;

  void setImageFile(File? imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }
}

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String myUserId;

  const GroupChatScreen(
      {Key? key, required this.groupId, required this.myUserId})
      : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late String _groupName = 'Cargando...';
  late String _myUserName = 'Cargando...';
  final TextEditingController _messageController = TextEditingController();
  final ImageController imageController = ImageController();
  final TextEditingController _callIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getGroupName();
    _getMyUserName();
  }

  Future<void> _getGroupName() async {
    try {
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();
      if (groupSnapshot.exists) {
        final groupData = groupSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _groupName = groupData['nombre'] ?? 'Grupo';
          _callIdController.text = groupData['callID'] ?? '1000';
        });
      }
    } catch (e) {
      print('Error obteniendo nombre del grupo: $e');
    }
  }

  Future<void> _getMyUserName() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.myUserId)
          .get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _myUserName = userData['nombre'] ?? 'Usuario';
        });
      }
    } catch (e) {
      print('Error obteniendo nombre del usuario: $e');
    }
  }

  Future<void> _sendMessage(String message, {String? imageUrl}) async {
    try {
      await FirebaseFirestore.instance.collection('group-messages').add({
        'groupId': widget.groupId,
        'userId': widget.myUserId,
        'message': message,
        'imageUrl': imageUrl,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    } catch (e) {
      print('Error al enviar el mensaje: $e');
    }
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final imageUrl = await _uploadImage(imageFile);
        _sendMessage('', imageUrl: imageUrl);
      }
    } catch (e) {
      print("Error al seleccionar la imagen: $e");
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('images/$fileName.jpg');
      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error al subir la imagen al almacenamiento de Firebase: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupName),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CallGroup(
                    callID: _callIdController.text,
                    userName: _myUserName,
                  ),
                ),
              );
              // Implementa la acción de la llamada aquí
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('group-messages')
                  .where('groupId', isEqualTo: widget.groupId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final messages = snapshot.data?.docs ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final String userId = messageData['userId'];
                    final String message = messageData['message'] ?? '';
                    final String imageUrl = messageData['imageUrl'] ?? '';
                    final String timestamp =
                        '${messageData['timestamp']?.toDate().day}-${messageData['timestamp']?.toDate().month}-${messageData['timestamp']?.toDate().year} ${messageData['timestamp']?.toDate().hour}:${messageData['timestamp']?.toDate().minute}';

                    final bool isMyMessage = userId == widget.myUserId;

                    return Align(
                      alignment: isMyMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              isMyMessage ? Colors.blue[200] : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft:
                                isMyMessage ? Radius.circular(16) : Radius.zero,
                            bottomRight:
                                isMyMessage ? Radius.zero : Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMyMessage)
                              Text(
                                _myUserName,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            if (message.isNotEmpty)
                              Text(
                                message,
                                style: TextStyle(fontSize: 16),
                              ),
                            if (imageUrl.isNotEmpty) SizedBox(height: 4),
                            if (imageUrl.isNotEmpty) Image.network(imageUrl),
                            Text(
                              timestamp,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
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
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                leading: Icon(Icons.camera),
                                title: Text('Desde la cámara'),
                                onTap: () {
                                  _selectImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text('Desde la galería'),
                                onTap: () {
                                  _selectImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
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
