import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siris/navbar.dart';


class DashboardPageDosen extends StatelessWidget {
  final Map<String, dynamic> userData;

  DashboardPageDosen({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile section
            Container(
              margin: const EdgeInsets.only(top: 0),
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00549C),
                    const Color(0xFF003664),
                    const Color(0xFF001D36),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(width: 4, color: Colors.white),
                    ),
                    child: ClipOval(
                      child: Image.memory(
                        base64Decode(userData['profile_image_base64']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hi, ${userData['name']}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'NIP: ${userData['identifier']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Jurusan: ${userData['jurusan']}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
