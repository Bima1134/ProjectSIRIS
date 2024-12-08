// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:siris/navbar.dart';

// class DashboardPageDosen extends StatelessWidget {
//   final Map<String, dynamic> userData;

//   const DashboardPageDosen({super.key, required this.userData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: Navbar(userData: userData),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Profile section
//             Container(
//               margin: const EdgeInsets.only(top: 0),
//               height: 160,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                      Color(0xFF00549C),
//                      Color(0xFF003664),
//                      Color(0xFF001D36),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 100,
//                     height: 100,
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.white,
//                       border: Border.all(width: 4, color: Colors.white),
//                     ),
//                     child: ClipOval(
//                       child: Image.memory(
//                         base64Decode(userData['profile_image_base64']),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Hi, ${userData['name']}',
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'NIP: ${userData['identifier']}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                         Text(
//                           'Jurusan: ${userData['jurusan']}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// }

// // // template dahsboard BA

// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:siris/BA/BA_list_ruang_page.dart';
// // // import 'package:siris/daftar_mahasiswa_perwalian_page.dart';
// // // import 'package:siris/BA_add_ruang.dart';

// // class DashboardPageDosen extends StatelessWidget {
// //   final Map<String, dynamic> userData;

// //   DashboardPageDosen({required this.userData});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             // Header
// //             Container(
// //               height: 240,
// //               color: const Color(0xFF162953),
// //               padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 crossAxisAlignment: CrossAxisAlignment.end,
// //                 children: [
// //                   Row(
// //                     crossAxisAlignment: CrossAxisAlignment.end,
// //                     children: [
// //                       const Text(
// //                         'SIRIS',
// //                         style: TextStyle(
// //                           fontSize: 40,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       const Text(
// //                         'Sistem Informasi Isian Rencana Studi',
// //                         style: TextStyle(
// //                           fontSize: 24,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   Row(
// //                     children: [
// //                       GestureDetector(
// //                           onTap: () {
// //                             // Navigate to Jadwal page
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) => ListRuangPage(),
// //                               )
// //                             );
// //                           },
// //                           child: _buildMenuItem(Icons.book, 'IRS'),
// //                         ),
// //                       const SizedBox(width: 16),
// //                       // ElevatedButton(
// //                       //   child: const Text('Daftar Mahasiswa Perwalian'),
// //                       //   onPressed: () {
// //                       //     Navigator.of(context).push(
// //                       //       MaterialPageRoute(
// //                       //         builder: (context) => DaftarMahasiswaPerwalianPage(userData: userData), // Kirimkan userData sebagai parameter
// //                       //       ),
// //                       //     );
// //                       //   },
// //                       // ),
// //                       _buildMenuItem(Icons.settings, 'Setting'),
// //                       const SizedBox(width: 16),
// //                       _buildLogoutButton(),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             // Profile section
// //             Container(
// //               margin: const EdgeInsets.only(top: 0),
// //               height: 160,
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [
// //                     const Color(0xFF00549C),
// //                     const Color(0xFF003664),
// //                     const Color(0xFF001D36),
// //                   ],
// //                 ),
// //                 borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Container(
// //                     width: 100,
// //                     height: 100,
// //                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //                     decoration: BoxDecoration(
// //                       shape: BoxShape.circle,
// //                       color: Colors.white,
// //                       border: Border.all(width: 4, color: Colors.white),
// //                     ),
// //                     child: ClipOval(
// //                       child: Image.memory(
// //                         base64Decode(userData['profile_image_base64']),
// //                         fit: BoxFit.cover,
// //                       ),
// //                     ),
// //                   ),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Text(
// //                           'Hi, ${userData['name']}',
// //                           style: const TextStyle(
// //                             fontSize: 24,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Text(
// //                           'Identifier: ${userData['identifier']}',
// //                           style: const TextStyle(
// //                             fontSize: 16,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                         Text(
// //                           'Jurusan: ${userData['jurusan']}',
// //                           style: const TextStyle(
// //                             fontSize: 16,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMenuItem(IconData icon, String label) {
// //     return Row(
// //       children: [
// //         Icon(icon, color: Colors.white),
// //         const SizedBox(width: 4),
// //         Text(label, style: const TextStyle(color: Colors.white)),
// //       ],
// //     );
// //   }

// //   Widget _buildLogoutButton() {
// //     return ElevatedButton(
// //       onPressed: () {
// //         // Handle logout
// //       },
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: Colors.red,
// //         foregroundColor: Colors.white,
// //       ),
// //       child: const Text('Logout'),
// //     );
// //   }

// // }

// template dahsboard BA

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:siris/Kaprodi/Kaprodi_ListJadwal.dart';
// import 'package:siris/BA/BA_list_alokasi_page.dart';
// import 'package:siris/daftar_mahasiswa_perwalian_page.dart';
// import 'package:siris/BA_add_ruang.dart';

class DashboardPageDosen extends StatelessWidget {
  final Map<String, dynamic> userData;

  DashboardPageDosen({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 240,
              color: const Color(0xFF162953),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'SIRIS',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sistem Informasi Isian Rencana Studi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to Jadwal page
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListJadwalKaprodiPage(userData: userData),
                              ));
                        },
                        child: _buildMenuItem(Icons.book, 'IRS'),
                      ),
                      const SizedBox(width: 16),
                      // ElevatedButton(
                      //   child: const Text('Daftar Mahasiswa Perwalian'),
                      //   onPressed: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (context) => DaftarMahasiswaPerwalianPage(userData: userData), // Kirimkan userData sebagai parameter
                      //       ),
                      //     );
                      //   },
                      // ),
                      //  GestureDetector(
                      //     onTap: () {
                      //       // Navigate to Jadwal page
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => ListAlokasiPage(),
                      //         )
                      //       );
                      //     },
                      //     child:  _buildMenuItem(Icons.settings, 'Setting'),
                      //   ),

                      const SizedBox(width: 16),
                      _buildLogoutButton(),
                    ],
                  ),
                ],
              ),
            ),
            // Profile section
            Container(
              margin: const EdgeInsets.only(top: 0),
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00549C),
                    const Color(0xFF003664),
                    const Color(0xFF001D36),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
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
                          'Identifier: ${userData['identifier']}',
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

  Widget _buildMenuItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
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
      child: const Text('Logout'),
    );
  }
}
