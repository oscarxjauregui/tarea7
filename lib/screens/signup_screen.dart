import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  // final usersRef = FirebaseFirestore.instance.collection('users');
  final UsersFirebase _usersFirebase = UsersFirebase();
  String? _selectedMethod;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _rolController = TextEditingController();
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
        labelText: 'Rol',
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
        title: Text('Registrarse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 80),
                TextFormField(
                  controller: _nombreController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ingresa el nombre',
                    labelText: 'Nombre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el nombre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                dropdownRol,
                SizedBox(height: 10),
                // Text(
                //   'Seleccione el metodo de registro: ',
                //   style: TextStyle(fontSize: 18),
                // ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'Celular',
                      child: Text(' Celular'),
                    ),
                    DropdownMenuItem(
                      value: 'Correo institucional',
                      child: Text('Correo institucional'),
                    ),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selecciona el metodo',
                    labelText: 'Metodo de registro',
                  ),
                ),
                SizedBox(height: 10),
                if (_selectedMethod == 'Celular') ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ingresa el numero',
                      labelText: 'Numero de telefono',
                    ),
                  ),
                ],
                if (_selectedMethod == 'Correo institucional') ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un correo electronico';
                      } /*else if (!value.endsWith('@itcelaya.edu.mx')) {
                        return 'Ingresa un correo institucional';
                      }*/
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ingresa el correo',
                      labelText: 'Correo institucional',
                    ),
                  ),
                ],
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ingresa la contraseña',
                    labelText: 'Contraseña',
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedMethod == 'Correo institucional') {
                        await _usersFirebase.insertar(
                          {
                            'nombre': _nombreController.text,
                            'email': _emailController.text,
                            'telefono': _phoneController.text,
                            'rol': _selectedRol,
                          },
                        );

                        // final email = _emailController.text.trim();
                        // final password = _passwordController.text.trim();
                        // final success = await _emailAuthFirebase.signUpUser(
                        //   email: email,
                        //   password: password,
                        // );
                        _emailAuthFirebase.signUpUser(
                            email: _emailController.text,
                            password: _passwordController.text);
                        print('Registro exitoso');
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Text('Registrarse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
