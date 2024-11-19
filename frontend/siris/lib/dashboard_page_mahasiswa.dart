import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:siris/jadwal_page.dart';
import 'package:siris/mahasiswa_irs.dart';


class DashboardPageMahasiswa extends StatelessWidget {
  final Map<String, dynamic> userData;

  const DashboardPageMahasiswa({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: const Color(0xFF162953), // Set the AppBar background color
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
          child: Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'SIRIS',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    'Sistem Informasi Isian Rencana Studi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Actions Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                          onTap: () {
                            // Navigate to Jadwal page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IRSPage(),
                              )
                            );
                          },
                          child: _buildMenuItem(Icons.book, 'IRS'),
                        ),
                  
                  const SizedBox(width: 16),
                    GestureDetector(
                          onTap: () {
                            // Navigate to Jadwal page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JadwalPage(userData: userData),
                              )
                            );
                          },
                          child: _buildMenuItem(Icons.schedule, 'Jadwal'),
                        ),
                  const SizedBox(width: 16),
                  _buildMenuItem(Icons.settings, 'Setting'),
                  const SizedBox(width: 16),
                  _buildLogoutButton(),
                ],
              ),
            ],
          ),
        )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: const Color(0xFF162953),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -80),  // Translate 50 units up (negative y value)
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal:64),
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
                           offset: const Offset(0, -20), // Adjust the offset as needed
                            child: Container(
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(3), // Border thickness
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white, // Border color
                              ),
                              child: CircleAvatar(
                                radius: 50, // Adjust the size of the profile image
                                backgroundImage: MemoryImage(
                                  base64Decode(userData['profile_image_base64']),
                                ),
                                backgroundColor: Colors.transparent, // Set background color to transparent
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
                              Row(
                                children: [
                                  Text(
                                    'NIM : ${userData['identifier']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Vertical Divider to separate the text items
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),  // Adds spacing around the pipe
                                    child: Text(
                                      '|',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,  // Adjust the font size to make the pipe symbol visible
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ' ${userData['jurusan']} S1',
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
                    margin: const EdgeInsets.symmetric(horizontal:64),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
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
                        _buildStatusWidget('Status Mahasiswa:', '${userData['status']}', Colors.green, Colors.white),
                        _buildStatusWidget('IPK:', '2.3',Colors.transparent, Colors.black),
                        _buildStatusWidget('SKS:', '80',Colors.transparent, Colors.black),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 160, vertical: 32),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal:16, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF162953), // Bottom border color
                                  width: 6.0,               // Bottom border width
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.school, size: 30, color: Color(0xFF162953)),
                                    SizedBox(width: 8),
                                    Text(
                                      'Status Akademik',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Dosen Wali',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                Text('${userData['dosen_wali_name']}', style: const TextStyle(fontSize: 16)),
                                Text('${userData['dosen_wali_nip']}', style: const TextStyle(fontSize: 16)),
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00549C),
                                        Color(0xFF003664),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.headset, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Konsultasi', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),

                                const Divider(),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSemesterInfo('Semester Akademik Sekarang', '2024/2025 Ganjil', Colors.green, Colors.white),
                                    _buildSemesterInfo('Semester Studi', '${userData['semester']}', Colors.transparent, Colors.black),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // const SizedBox(width: 16),
                        // Expanded(
                        //   child: Column(
                        //     children: [
                        //       GestureDetector(
                        //         onTap: () {
                        //           // Navigate to IRS page
                        //         },
                        //         child: _buildDashboardButton('IRS', Icons.book),
                        //       ),
                        //       const SizedBox(height: 16, width: 16),
                        //       GestureDetector(
                        //         onTap: () {
                        //           // Navigate to Jadwal page
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //               builder: (context) => JadwalPage(),
                        //             )
                        //           );
                        //         },
                        //         child: _buildDashboardButton('Jadwal', Icons.schedule),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:18)),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle logout
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text('Logout', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

 
  Widget _buildStatusWidget(String title, String value, Color color, Color fontcolor ) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container( 
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: color, borderRadius:BorderRadius.circular(8),),  // Corrected here
          child: Text(value, style: TextStyle(fontSize: 16, color: fontcolor),
          )
        )
      ],
    );
  }

  Widget _buildSemesterInfo(String title, String value, Color color, Color fontcolor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: color, borderRadius:BorderRadius.circular(8),),  // Corrected here
          child: Text(value, style: TextStyle(fontSize: 16, color: fontcolor)),
        ),
      ],
    );
  }
}

