import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tarea7/screens/home_screen.dart';

class ImageController extends ChangeNotifier {
  File? _imageFile;

  File? get imageFile => _imageFile;

  void setImageFile(File? imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }
}

class SelectAvatarScreen extends StatefulWidget {
  final String userId;

  const SelectAvatarScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SelectAvatarScreen> createState() => _SelectAvatarScreenState();
}

class _SelectAvatarScreenState extends State<SelectAvatarScreen> {
  late ImageController imageController = ImageController();

  @override
  void initState() {
    super.initState();
    imageController = ImageController();
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageController.setImageFile(File(pickedFile.path));
        });
      }
    } catch (e) {
      print("Error al seleccionar la imagen: $e");
    }
  }

  Future<void> _saveImageToStorage() async {
    final imageFile = imageController.imageFile;
    final userId = widget.userId;

    if (imageFile != null && userId != null) {
      try {
        // Mostrar un dialogo con el indicador de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text("Cargando..."),
                  ],
                ),
              ),
            );
          },
        );

        final firebase_storage.Reference oldAvatarRef = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('avatars/$userId.png');
        final oldAvatarExists = await oldAvatarRef
            .getMetadata()
            .then((value) => true)
            .catchError((_) => false);

        if (oldAvatarExists) {
          await oldAvatarRef.delete();
        }

        final firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('avatars/$userId.png');

        final firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
        await uploadTask.whenComplete(() async {
          final imageUrl = await ref.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('avatars')
              .doc(userId)
              .set({
            'userId': userId,
            'imageUrl': imageUrl,
          });
          print('Imagen subida a storage y URL guardada en Firestore');
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context); // Close the loading dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userId: userId),
            ),
          );
        });
      } catch (e) {
        Navigator.pop(context); // Close the loading dialog in case of error
        print(e);
      }
    }
  }

  Future<String?> _getUserEmail(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc['email'];
      }
    } catch (e) {
      print('Error al obtener el email del usuario: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar foto'),
      ),
      body: ChangeNotifierProvider<ImageController>.value(
        value: imageController,
        child: Container(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 50,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Consumer<ImageController>(
                    builder: (context, imageController, _) {
                      return CircleAvatar(
                        radius: 180,
                        backgroundColor: Colors.grey[200],
                        child: IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 50,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Container(
                                height: 150,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.camera),
                                      title: Text('Desde la cámara'),
                                      onTap: () {
                                        _selectImage(ImageSource.camera);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.image),
                                      title: Text('Desde la galería'),
                                      onTap: () {
                                        _selectImage(ImageSource.gallery);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        backgroundImage: imageController.imageFile != null
                            ? FileImage(imageController.imageFile!)
                            : null,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 450,
                child: Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width * .9,
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            final userId = widget.userId;
                            if (userId != null) {
                              final userEmail = await _getUserEmail(userId);
                              if (userEmail != null) {
                                _saveImageToStorage();
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Error'),
                                    content: Text(
                                      'No se pudo obtener el email del usuario.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Ingrese el ID del usuario'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Text('Guardar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 15, 182, 104),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
