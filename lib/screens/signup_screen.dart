import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tarea7/screens/login_screen.dart';
import 'package:tarea7/services/email_auth_firebase.dart';
import 'package:tarea7/services/user_firebase.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final UsersFirebase _usersFirebase = UsersFirebase();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final EmailAuthFirebase _emailAuthFirebase = EmailAuthFirebase();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> roles = [
    'Maestro',
    'Alumno',
  ];

  String? _selectedRol;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final dropdownRol = DropdownButtonFormField<String>(
      value: _selectedRol,
      onChanged: (String? newValue) {
        setState(() {
          _selectedRol = newValue;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: 'Seleccione un rol',
        labelText: 'Rol',
        prefixIcon: Icon(Icons.person),
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
        title: Text(
          'Registrarse',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 15, 182, 104),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 225, 225, 225)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nombreController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Ingresa el nombre',
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingrese el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  dropdownRol,
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un correo electrónico';
                      } else if (!value.endsWith('@itcelaya.edu.mx')) {
                        return 'Ingresa un correo institucional';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Ingresa el correo',
                      labelText: 'Correo institucional',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      } else if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres,\n una letra mayúscula y un numero';
                      } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                        return 'La contraseña debe tener al menos 8 caracteres,\n una letra mayúscula y un numero';
                      } else if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                        return 'La contraseña debe tener al menos 8 caracteres,\n una letra mayúscula y un numero';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Ingresa la contraseña',
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              await _usersFirebase.insertar({
                                'nombre': _nombreController.text,
                                'email': _emailController.text,
                                'telefono': _phoneController.text,
                                'rol': _selectedRol,
                              });
                              await _emailAuthFirebase.signUpUser(
                                  email: _emailController.text,
                                  password: _passwordController.text);
                              setState(() {
                                _isLoading = false;
                              });
                              print('Registro exitoso');
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Registrarse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 15, 182, 104),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
      ),
    );
  }
}
