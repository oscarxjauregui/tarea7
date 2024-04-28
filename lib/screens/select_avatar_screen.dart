import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ImageController extends ChangeNotifier {
  File? _imageFile;

  File? get imageFile => _imageFile;

  void setImageFile(File? imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }
}

class SelectAvatarScreen extends StatefulWidget {
  const SelectAvatarScreen({Key? key}) : super(key: key);

  @override
  State<SelectAvatarScreen> createState() => _SelectAvatarScreenState();
}

class _SelectAvatarScreenState extends State<SelectAvatarScreen> {
  late ImageController imageController = ImageController();

  @override
  void initState() {
    super.initState();
    imageController = ImageController(); // Initialize the variable here
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
    if (imageFile != null) {
      try {
        final firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('avatar')
            .child('${DateTime.now().millisecondsSinceEpoch}.png');

        final firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
        await uploadTask.whenComplete(() => print('Imagen subida a storage'));
      } catch (e) {
        print(e);
      }
    }
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
                top: 80, // Ajuste vertical
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Consumer<ImageController>(
                        builder: (context, imageController, _) {
                      return CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.grey[200],
                        child: IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () {
                            final snackBar = SnackBar(
                              content: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _selectImage(ImageSource.camera);
                                    },
                                    child: Text('Desde la camara'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _selectImage(ImageSource.gallery);
                                    },
                                    child: Text('Desde la galeria'),
                                  ),
                                ],
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                        ),
                        backgroundImage: imageController.imageFile != null
                            ? FileImage(imageController.imageFile!)
                            : null,
                      );
                    })),
              ),
              Positioned(
                top: 280, // Ajuste vertical
                child: Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width * .9,
                  child: Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _saveImageToStorage();
                            Navigator.pop(context);
                          },
                          child: Text('Guardar'),
                        )
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
