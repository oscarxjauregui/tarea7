import 'package:flutter/material.dart';
import 'package:tarea7/constant/callPage.dart';

class Llamada extends StatelessWidget {
  Llamada({super.key});

  final callIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Call ID', hintText: 'Enter call ID'),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CallPage(callID: '123450935',
                        // callID: callIdController.text,
                        userName: 'xd',
                      ),
                    ),
                  );
                },
                child: const Text('Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
