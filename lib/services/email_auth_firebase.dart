import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EmailAuthFirebase {
  final auth = FirebaseAuth.instance;
  final usersRef = FirebaseFirestore.instance.collection('users');

  Future<bool> signUpUser({
    required String password,
    required String email,
    //required String rol,
    //File? imageFile,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        userCredential.user!.sendEmailVerification();
        // await usersRef.doc(userCredential.user!.uid).set({
        //   'email': email,
        // });
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> signInUser(
      {required String password, required String email}) async {
    var band = false;
    final userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    if (userCredential.user != null) {
      if (userCredential.user!.emailVerified) {
        band = true;
      }
    }
    return band;
  }
}
  /*Future<void> uploadImage(String userId, File imageFile) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('avatar').child('$userId.jpg');
      await storageRef.putFile(imageFile);
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('avatar').doc(userId).set({
        'avatarUrl': imageUrl,
      });
    } catch (e) {
      print("Error al subir la imagen a firestore sotrage: $e");
    }
  }

  Future<bool> signInUser(
      {required String password, required String email}) async {
    var band = false;
    final userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);
    if (userCredential.user != null) {
      if (userCredential.user!.emailVerified) {
        band = true;
      }
    }
    return band;
  }*/