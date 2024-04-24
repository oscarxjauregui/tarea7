import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tarea7/screens/login_screen.dart';
import 'package:tarea7/services/email_auth_firebase.dart';

class SingUpScreen extends StatefulWidget {
  const SingUpScreen({super.key});

  @override
  State<SingUpScreen> createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SingUpScreen> {
  String? _selectedMethod;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final EmailAuthFirebase _emailAuthFirebase = EmailAuthFirebase();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrarse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Seleccione el metodo de registro: ',
                style: TextStyle(fontSize: 18),
              ),
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
                    } else if (!value.endsWith('@itcelaya.edu.mx')) {
                      return 'Ingresa un correo institucional';
                    }
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
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      final success = await _emailAuthFirebase.signUpUser(
                        email: email,
                        password: password,
                      );
                      print('Registro exitoso');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          //builder: (context) => RegistroScreen(),
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    }
                  }
                },
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
