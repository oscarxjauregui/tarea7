import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ImageController extends ChangeNotifier {
  File? _imageFile;
  File? get imageFile => _imageFile;

  void setImageFile(File? imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }
}

class MessageScreen extends StatefulWidget {
  final String userId;
  final String myUserId;

  const MessageScreen({Key? key, required this.userId, required this.myUserId})
      : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late ImageController imageController;
  late String _userName = 'Cargando...';
  late String _userEmail = 'Cargando...';
  late String _myUserName = 'Cargando...';
  late String _myUserEmail = 'Cargando...';
  final TextEditingController _messageController = TextEditingController();

  Future<void> _selectImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageController.setImageFile(File(pickedFile.path));
          // Subir la imagen al almacenamiento de Firebase
          _uploadImage(File(pickedFile.path));
        });
      }
    } catch (e) {
      print("Error al seleccionar la imagen: $e");
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      // Subir la imagen al almacenamiento de Firebase
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('${DateTime.now()}.jpg');
      await storageRef.putFile(imageFile);

      // Obtener el enlace de descarga de la imagen
      final imageUrl = await storageRef.getDownloadURL();

      // Actualizar el documento en la colección 'messages' con el enlace de descarga
      await FirebaseFirestore.instance.collection('messages').add({
        'ids': [widget.myUserId, widget.userId],
        'message': imageUrl, // Almacenar el enlace de descarga como un string
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      print("Error al subir la imagen: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    _getMyUserData();
    imageController = ImageController();
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
        'ids': [widget.myUserId, widget.userId], // Almacenar IDs en una lista
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('ids',
                      arrayContainsAny: [widget.myUserId, widget.userId])
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('${snapshot.error}');
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
                    final message = messageData['message'];
                    final ids = List<String>.from(messageData['ids'] ?? []);

                    final isMyMessage = ids.indexOf(widget.myUserId) == 0;

                    final timestamp =
                        '${messageData['timestamp']?.toDate().day}-${messageData['timestamp']?.toDate().month}-${messageData['timestamp']?.toDate().year} ${messageData['timestamp']?.toDate().hour}:${messageData['timestamp']?.toDate().minute}';

                    return Align(
                      alignment: isMyMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(12),
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
                            Text(
                              message,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text('Enviado: $timestamp'),
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
                    // Mostrar el BottomSheet para seleccionar la imagen
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
