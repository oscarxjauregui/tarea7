import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
bool value = false;

Future<String> uploadProfileImage(File image, String file, String name) async {
  final Reference ref =
      storage.ref().child(file).child(auth.currentUser!.uid).child(name);
  try {
    await ref.delete();
  } on FirebaseException catch (e) {
    print(e);
  }

  try {
    await ref.putFile(image);
    value = true;
  } on FirebaseException catch (e) {
    print(e);
  }

  final String url = await ref.getDownloadURL();

  return url;
}

Future<String> uploadChatImage(
    File image, String file, String chatId, String name) async {
  final Reference ref =
      storage.ref().child(file).child(chatId).child('image').child(name);
  try {
    await ref.putFile(image);
    value = true;
  } on FirebaseException catch (e) {
    print(e);
  }

  final String url = await ref.getDownloadURL();

  return url;
}

Future<String> uploadChatVideo(
    File image, String file, String chatId, String name) async {
  final Reference ref =
      storage.ref().child(file).child(chatId).child('video').child(name);
  try {
    await ref.putFile(image);
    value = true;
  } on FirebaseException catch (e) {
    print(e);
  }

  final String url = await ref.getDownloadURL();

  return url;
}

Future<String> uploadGroupImage(
    File image, String file, String groupId, String name) async {
  final Reference ref = storage.ref().child(file).child(groupId).child(name);
  try {
    await ref.delete();
  } on FirebaseException catch (e) {
    print(e);
  }

  try {
    await ref.putFile(image);
    value = true;
  } on FirebaseException catch (e) {
    print(e);
  }

  final String url = await ref.getDownloadURL();

  return url;
}
