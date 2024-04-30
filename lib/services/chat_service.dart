import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tarea7/models/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  String? userId;
  String? userEmail;
  String? userName;

  ChatService({this.userId});

  Future<void> sendMessage(String receiverId, String message) async {
    // Retrieve user data ensuring null-safety
    final userDoc = await _fireStore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      userEmail = userData['email'];
      userName = userData['nombre'];
      final String? senderId = userDoc.id;

      // Validate data before creating message
      if (userEmail != null && userName != null && senderId != null) {
        final Message newMessage = Message(
          senderId: senderId,
          senderEmail: userEmail!, // Use ! for non-nullable fields
          senderName: userName!,
          reciverId: receiverId,
          timestamp: Timestamp.now(),
          message: message,
        );

        // Store message in 'messages' collection
        await _fireStore.collection('messages').add(newMessage.toMap());
      } else {
        print('Error: Missing user data when sending message.');
      }
    } else {
      print('Error: User document not found.');
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    final List<String> senderReceiverIds = [userId, otherUserId];
    senderReceiverIds.sort();
    final String chatRoomId = senderReceiverIds.join("_");

    return _fireStore
        .collection('messages')
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
