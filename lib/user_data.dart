import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;



void saveUserData(String textInput, Uint8List imageData) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref().child('user_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await storageRef.putData(imageData); // Upload image data directly

    final downloadUrl = await storageRef.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('history').add({
      'textInput': textInput,
      'imageUrl': downloadUrl, // Store the download URL
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class UserHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('User History'),
        ),
        body: Center(
          child: Text('Please sign in to view your history.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('User History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: retrieveUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No history found.'),
            );
          }

          final userData = snapshot.data!;
          return ListView.builder(
            itemCount: userData.length,
            itemBuilder: (context, index) {
              final data = userData[index];
              return ListTile(
                title: Text(data['textInput']),
                subtitle: data['imageUrl'] != null
                    ? Image.network(data['imageUrl'])
                    : Container(),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> retrieveUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('history').get();
      return userData.docs.map((doc) => doc.data()).toList();
    } else {
      return [];
    }
  }
}