import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tarea7/constant/callGroup.dart';
import 'package:video_player/video_player.dart';
import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';

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

  Future<void> _sendMessage(String message,
      {String? imageUrl, String? videoUrl, String? pdfUrl}) async {
    try {
      await FirebaseFirestore.instance.collection('group-messages').add({
        'groupId': widget.groupId,
        'userId': widget.myUserId,
        'message': message,
        'imageUrl': imageUrl,
        'videoUrl': videoUrl,
        'pdfUrl': pdfUrl,
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

  Future<void> _uploadVideo(File videoFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('videos/$fileName.mp4');
      UploadTask uploadTask = firebaseStorageRef.putFile(videoFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      print('Video subido correctamente. URL: $url');
      _sendMessage('', videoUrl: url);
    } catch (e) {
      print("Error al subir el video al almacenamiento de Firebase: $e");
    }
  }

  Future<void> _selectVideo() async {
    try {
      final pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        _uploadVideo(File(pickedFile.path));
      }
    } catch (e) {
      print("Error al seleccionar el video: $e");
    }
  }

  Future<void> _selectPdf() async {
    try {
      final pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (pickedFile != null && pickedFile.files.single.path != null) {
        File pdfFile = File(pickedFile.files.single.path!);
        _uploadPdf(pdfFile);
      }
    } catch (e) {
      print("Error al seleccionar el PDF: $e");
    }
  }

  Future<void> _uploadPdf(File pdfFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('pdfs/$fileName.pdf');
      UploadTask uploadTask = firebaseStorageRef.putFile(pdfFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String url = await taskSnapshot.ref.getDownloadURL();
      print('PDF subido correctamente. URL: $url');
      _sendMessage('', pdfUrl: url);
    } catch (e) {
      print("Error al subir el PDF al almacenamiento de Firebase: $e");
    }
  }

  Future<void> _showPdf(BuildContext context, String pdfUrl) async {
    try {
      PDFDocument document = await PDFDocument.fromURL(pdfUrl);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewer(document: document),
        ),
      );
    } catch (e) {
      print("Error al mostrar el PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupName),
        backgroundColor: Color.fromARGB(255, 15, 182, 104),
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
                    final String videoUrl = messageData['videoUrl'] ?? '';
                    final String pdfUrl = messageData['pdfUrl'] ?? '';
                    final timestamp = messageData['timestamp'].toDate();
                    final formattedTime =
                        '${timestamp.hour}:${timestamp.minute}';

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
                          color: isMyMessage
                              ? Color.fromARGB(255, 141, 209, 177)
                              : Colors.grey[200],
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
                            if (videoUrl.isNotEmpty) SizedBox(height: 4),
                            if (videoUrl.isNotEmpty)
                              VideoPlayerWidget(videoUrl: videoUrl),
                            if (pdfUrl.isNotEmpty) SizedBox(height: 4),
                            if (pdfUrl.isNotEmpty)
                              GestureDetector(
                                onTap: () => _showPdf(context, pdfUrl),
                                child: Text(
                                  'Ver archivo',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    // decoration: TextDecoration.underline,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            Text(
                              formattedTime,
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
                  icon: Icon(Icons.attach_file),
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
                              ListTile(
                                leading: Icon(Icons.video_library),
                                title: Text('Subir video'),
                                onTap: () {
                                  _selectVideo();
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.picture_as_pdf),
                                title: Text('Enviar PDF'),
                                onTap: () {
                                  _selectPdf();
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

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                VideoPlayer(_controller),
                ControlsOverlay(controller: _controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
              ],
            ),
          )
        : Center(child: CircularProgressIndicator());
  }
}

class ControlsOverlay extends StatelessWidget {
  const ControlsOverlay({Key? key, required this.controller}) : super(key: key);

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    // child: Icon(
                    //   Icons.play_arrow,
                    //   color: Colors.white,
                    //   size: 100.0,
                    //   semanticLabel: 'Play',
                    // ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in [0.5, 1.0, 1.5, 2.0])
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GroupChatScreen(groupId: 'group_id', myUserId: 'user_id'),
  ));
}
