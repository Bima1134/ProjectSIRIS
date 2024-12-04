import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserProfileScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${userData['role']}'),
            Text('Identifier: ${userData['identifier']}'),
            Text('Name: ${userData['name']}'),
            if (userData['angkatan'] != null)
              Text('Angkatan: ${userData['angkatan']}'),
          ],
        ),
      ),
    );
  }
}
