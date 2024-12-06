import 'dart:convert';  
import 'package:flutter/material.dart';
import 'package:siris/navbar.dart';
import 'package:logging/logging.dart';

final loggerDashboard = Logger('DashboardState');

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const Dashboard({super.key, required this.userData});

  @override
  DashboardState createState() => DashboardState();

}

class DashboardState extends State<Dashboard> {
  get userData => widget.userData;

  Widget _getDashboard(BuildContext context, String role){
    switch (role){
      case "Mahasiswa":
        return _dashboardMahasiswa(context);
      case "Dosen":
        return _dashboardDosen(context);
      case "Dekan":
        return _dashboardDekan(context);
      case "Kaprodi":
        return _dashboardKaprodi(context);
      case "Baka":
        return _dashboardBaka(context);
      default:
        loggerDashboard.warning("Role hasn't been set");
        return Column(
          children: [
            Text('This account has no role'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
    }
  }

  Widget _dashboardMahasiswa(BuildContext context){
    return Transform.translate(
      offset: Offset(0, -30),
      child: Column(
        children: [
          //Status Akademik
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 160, vertical: 0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal:16, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
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
              ],
            ),
          ),
          // Other Information or button here
        ],
      )
    );
  }

  Widget _dashboardDosen(BuildContext context){
    return Container();
  }

  Widget _dashboardDekan(BuildContext context){
    return Container();
  }

  Widget _dashboardKaprodi(BuildContext context){
    return Container();
  }

  Widget _dashboardBaka(BuildContext context){
    return Container();
  }

  Widget _getProfile(BuildContext context){
    return 
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
                  // Profile Image
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
                          base64Decode(userData['profile_image_base64']),
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),

                  // Profile Information
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
                              '${userData['identifier']}',
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
                              '${userData['jurusan'] ?? userData['departemen']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  // Sudah registrasi here
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal:64),
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
                  _buildStatusWidget('Status Mahasiswa:', '${userData['status']}', Colors.green, Colors.white),
                  _buildStatusWidget('IPK:', '2.3',Colors.transparent, Colors.black),
                  _buildStatusWidget('SKS:', '80',Colors.transparent, Colors.black),
                ],
              ),
            ),
          ],
        ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color:Color(0xFF162953),
              ),
            ),
            _getProfile(context),
            _getDashboard(context, userData['currentLoginAs']),
          ]
        )
      )
    );
  }
 
  
}

