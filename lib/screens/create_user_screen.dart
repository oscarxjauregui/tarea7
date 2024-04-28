import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tarea7/screens/home_screen.dart';

class ImageController extends ChangeNotifier {
  File? _imageFile;
  File? get imageFile => _imageFile;

  void setImageFile(File? imageFile) {
    _imageFile = imageFile;
    notifyListeners();
  }
}

final userRef = FirebaseFirestore.instance.collection('users');
final TextEditingController nombreController = TextEditingController();

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  late ImageController imageController;
  final _formKey = GlobalKey<FormState>();
  final List<String> roles = [
    'Maestro',
    'Alumno',
  ];

  String? _selectedRol;

  final txtNombre = TextFormField(
    keyboardType: TextInputType.text,
    controller: nombreController,
    decoration: const InputDecoration(border: OutlineInputBorder()),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Ingrese el nombre';
      }
      return null;
    },
  );

  Future<void> _selectImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          imageController.setImageFile(File(pickedFile.path));
          //print('nombre de la imagen ${pickedFile.name}');
        });
      }
    } catch (e) {
      print("Error al seleccionar la imagen: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    imageController = ImageController();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownRol = DropdownButtonFormField<String>(
      value: _selectedRol,
      onChanged: (String? newValue) {
        setState(() {
          _selectedRol = newValue;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Seleccione un rol',
      ),
      items: roles.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Seleccione un rol';
        }
        return null;
      },
    );
    return Scaffold(
        appBar: AppBar(
          title: Text('Crear Usuario'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ChangeNotifierProvider<ImageController>.value(
          value: imageController,
          child: Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 80,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Consumer<ImageController>(
                      builder: (context, imageController, _) {
                        return CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey[100],
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
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 180, // Ajuste vertical
                  child: Container(
                    height: 800,
                    width: MediaQuery.of(context).size.width * .9,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          SizedBox(
                            height: 30,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text('Nombre'),
                            ),
                          ),
                          txtNombre,
                          SizedBox(
                            height: 30,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text('Email'),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text('Rol'),
                            ),
                          ),
                          dropdownRol,
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_selectedRol == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Seleccione un rol'),
                                    ),
                                  );
                                  return;
                                }
                              //   authFirebase
                              //       .signUpUser(
                              //           name: nombreController.text,
                              //           password: passwordController.text,
                              //           email: emailController.text,
                              //           rol: _selectedRol!)
                              //       .then((value) {
                              //     if (value) {
                              //       if (imageController.imageFile == null) {
                              //         ScaffoldMessenger.of(context)
                              //             .showSnackBar(
                              //           SnackBar(
                              //             content:
                              //                 Text('Selecciona una imagen'),
                              //           ),
                              //         );
                              //       } else {
                              //         Future.delayed(
                              //           const Duration(milliseconds: 3000),
                              //           () {
                              //             Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                 builder: (context) =>
                              //                     HomeScreen(),
                              //               ),
                              //             );
                              //           },
                              //         );
                              //       }
                              //     }
                              //   });
                              }
                            },
                            child: Text('Registrarse'),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
