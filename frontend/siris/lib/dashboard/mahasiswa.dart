import 'dart:convert';  
import 'package:flutter/material.dart';
import 'package:siris/navbar.dart';
import 'package:http/http.dart' as http;


class DashboardPageMahasiswa extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DashboardPageMahasiswa({super.key, required this.userData});

  @override
  State<DashboardPageMahasiswa> createState() => _DashboardPageMahasiswaState();
}

class _DashboardPageMahasiswaState extends State<DashboardPageMahasiswa> {
  String totalSks = '0';
  String ipk = '0.0';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

 Future<void> fetchData() async {
   final nim = widget.userData['identifier'];
    final String apiUrl = 'http://localhost:8080/mahasiswa/sks-ipk/$nim'; // Ganti dengan endpoint API Anda

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = json.decode(response.body);
        setState(() {
          totalSks = data['total_sks'].toString();
          ipk = data['ipk'].toString();
        });
      } else {
        setState(() {
          totalSks = 'Error';
          ipk = 'Error';
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        totalSks = 'Error';
        ipk = 'Error';
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: widget.userData),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: Color(0xFF162953),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -80), 
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 64),
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00549C),
                          Color(0xFF003664),
                          Color(0xFF001D36),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: MemoryImage(
                                base64Decode(widget.userData['profile_image_base64']),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Hi, ${widget.userData['name']}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'NIM : ${widget.userData['identifier']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${widget.userData['jurusan']} S1',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Sudah Registrasi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 64),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusWidget('Status Mahasiswa:', '${widget.userData['status']}', Colors.green, Colors.white),
                        _buildStatusWidget('IPK:', ipk, Colors.transparent, Colors.black),
                        _buildStatusWidget('SKS:', totalSks, Colors.transparent, Colors.black),
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

  Widget _buildStatusWidget(String title, String value, Color color, Color fontcolor) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: TextStyle(fontSize: 16, color: fontcolor)),
        ),
      ],
    );
  }
}
