import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:tarea7/screens/create_user_screen.dart';
import 'package:tarea7/screens/home_screen.dart';
import 'package:tarea7/screens/signup_screen.dart';
import 'package:tarea7/services/email_auth_firebase.dart';
import 'package:tarea7/services/user_firebase.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final EmailAuthFirebase _authFirebase = EmailAuthFirebase();
  final authFirebase = EmailAuthFirebase();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedMethod;
  final UsersFirebase _usersFirebase = UsersFirebase();

  // Future<void> login() async {
  //   final email = _emailController.text.trim();
  //   final userExists = await _usersFirebase.consultarEmail(email);
  //   if (userExists) {
  //     final password = _passwordController.text.trim();
  //     final success = await _authFirebase.signInUser(
  //       email: email,
  //       password: password,
  //     );
  //     if (success) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => HomeScreen(),
  //         ),
  //       );
  //     } else {
  //       print('Error al iniciar sesión');
  //     }
  //   } else {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => CreateUserScreen(),
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final txtEmail = TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Ingresa el correo',
        labelText: 'Correo institucional',
      ),
    );
    final txtPassword = TextFormField(
      controller: _passwordController,
      keyboardType: TextInputType.text,
      obscureText: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Ingresa la contraseña',
        labelText: 'Contraseña',
      ),
    );
    final txtPhone = TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Ingresa el numero',
        labelText: 'Numero de telefono',
      ),
    );

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Container(
                padding: EdgeInsets.all(10),
                height: 500,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  shrinkWrap: true,
                  children: [
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
                          child: Text('Celular'),
                        ),
                        DropdownMenuItem(
                          value: 'Correo institucional',
                          child: Text('Correo institucional'),
                        ),
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Metodo de inicio de sesion',
                        labelText: 'Metodo de inicio de sesion',
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedMethod == 'Celular') ...[txtPhone],
                    if (_selectedMethod == 'Correo institucional') ...[
                      txtEmail
                    ],
                    const SizedBox(height: 10),
                    txtPassword,
                    const SizedBox(height: 10),
                    SignInButton(
                      Buttons.Email,
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        final success = await _authFirebase.signInUser(
                          email: email,
                          password: password,
                        );
                        if (success) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                userEmail: _emailController.text,
                              ),
                            ),
                          );
                        } else {
                          print('Error al iniciar sesion');
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: Text('Crear cuenta'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
