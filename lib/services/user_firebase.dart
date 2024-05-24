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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> consultarPorEmail(String email) async {
    return await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
  }
}
