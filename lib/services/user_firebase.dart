import 'package:cloud_firestore/cloud_firestore.dart';

class UsersFirebase {
  final util = FirebaseFirestore.instance;
  CollectionReference? _usersCollection;
  UsersFirebase() {
    _usersCollection = util.collection('users');
  }

  Stream<QuerySnapshot> consultar() {
    return _usersCollection!.snapshots();
  }

  Future<void> insertar(Map<String, dynamic> data) async {
    return _usersCollection!.doc().set(data);
  }

  Future<void> actualizar(Map<String, dynamic> data, String id) async {
    return _usersCollection!.doc(id).update(data);
  }

  Future<void> eliminar(String id) async {
    return _usersCollection!.doc(id).delete();
  }

  Future<bool> consultarEmail(String email) async {
    final querySnapshot =
        await _usersCollection!.where('email', isEqualTo: email).limit(1).get();

    return querySnapshot.docs.isNotEmpty;
  }
}
