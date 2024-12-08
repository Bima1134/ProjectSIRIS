import 'dart:convert';
// import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:siris/Kaprodi/Kaprodi_add_matkul.dart';
// import 'package:siris/BA/BA_add_ruang.dart';
import 'package:siris/Kaprodi/Kaprodi_add_matkul_single.dart';
import 'package:siris/Kaprodi/Kaprodi_edit_matkul.dart';
// import 'package:siris/BA/BA_edit_ruang_page.dart';
// import 'package:siris/class/Ruang.dart';

class MataKuliah {
  final String KodeMK;
  final String NamaMK;
  final int SKS;
  final String Status;
  final int Semester;
  final String NamaProdi;



  MataKuliah({
    required this.KodeMK,
    required this.NamaMK,
    required this.SKS,
    required this.Status,
    required this.Semester,
    required this.NamaProdi,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      KodeMK: json['kode_mk'],
      NamaMK: json['nama_mk'],
      SKS: json['sks'],
      Status: json['status'],
      Semester: json['semester'],
      NamaProdi: json['prodi'],
    );
  }
}

class ListMatkulPage extends StatefulWidget {
  @override
  _ListMatkulPageState createState() => _ListMatkulPageState();
  
}

class _ListMatkulPageState extends State<ListMatkulPage> {
  bool selectAll = false;
  List<MataKuliah> matkulList = [];
  Set<String> selectedMatkul = {}; // Store selected room names

  int currentPage = 1;  // Track the current page
  int rowsPerPage = 10; // Number of rows per page
  List<MataKuliah> paginatedList = []; // To hold the current page data

  @override
  void initState() {
    super.initState();
    fetchMatkulData();
  }

  // Fetch ruang data from the backend
  Future<void> fetchMatkulData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/kaprodi/get-matkul'));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            if (data is List) {
              setState(() {
                matkulList = data.map((item) => MataKuliah.fromJson(item)).toList();
                updatePaginatedData(); // Update paginated data after fetching
              });
            } else {
              setState(() {
                matkulList = []; // Default to empty list if data is not a list
              });
              print('Unexpected data format');
            }
          } catch (e) {
            debugPrint('Error decoding JSON: $e');
            setState(() {
              matkulList = []; // Default to empty list if decoding fails
            });
          }
        } else {
          setState(() {
            matkulList = []; // Default to empty list if body is empty
          });
          debugPrint('Response body is empty');
        }
      } else {
        debugPrint('Failed to fetch data. Status code: ${response.statusCode}');
        setState(() {
          matkulList = []; // Default to empty list on error
        });
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      setState(() {
        matkulList = []; // Default to empty list on exception
      });
    }
  }

  // void _showDeleteConfirmationDialog({required List<MataKuliah> courses}) {
  //   String message = courses.length == 1
  //       ? 'Apakah Anda yakin ingin menghapus mata kuliah ini?'
  //       : 'Apakah Anda yakin ingin menghapus ${courses.length} mata kuliah yang dipilih?';

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Konfirmasi Hapus'),
  //       content: Text(message),
  //       actions: <Widget>[
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(context).pop(); // Close the dialog
  //           },
  //           child: const Text('Batal'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             if (courses.length == 1) {
  //               _deleteMatkul(courses.first); // Delete a single room
  //             } else {
  //               _deleteSelectedMatkul(courses); // Delete multiple rooms
  //             }
  //             Navigator.of(context).pop(); // Close the dialog
  //           },
  //           child: const Text('Hapus'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

Future<void> _deleteMatkul(MataKuliah course) async {
  // Log the KodeMK value
  debugPrint('Attempting to delete Ruang with KodeMK: ${course.KodeMK}');

  try {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/kaprodi/delete-matkul/${course.KodeMK}'),
    );

    // Log the response status code and body for debugging
    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      fetchMatkulData();
      updatePaginatedData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruang berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus ruang')),
      );
    }
  } catch (error) {
    // Log any exception caught
    debugPrint('Error during HTTP request: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan')),
    );
  }
}


void _showDeleteConfirmationDialog({required List<MataKuliah> courses}) {
  String message = courses.length == 1
      ? 'Apakah Anda yakin ingin menghapus mata kuliah ini?'
      : 'Apakah Anda yakin ingin menghapus ${courses.length} mata kuliah yang dipilih?';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi Hapus'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (courses.length == 1) {
              _deleteMatkul(courses.first);
            } else {
              _deleteSelectedMatkul(courses);
            }
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
}

Future<void> _deleteSelectedMatkul(List<MataKuliah> courses) async {
  final selectedCodes = courses.map((course) => course.KodeMK).toList();

  debugPrint('Selected codes to delete: $selectedCodes'); // Debugging: Cetak data sebelum dikirim ke server

  try {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/kaprodi/delete-matkul-multiple'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"kode_mk": selectedCodes}),
    );

    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        matkulList.removeWhere((course) => selectedCodes.contains(course.KodeMK));
        selectedMatkul.clear();
      });
      await fetchMatkulData();
      updatePaginatedData();

      if (currentPage > 1 && matkulList.length <= (currentPage - 1) * rowsPerPage) {
        setState(() {
          currentPage = 1; // Reset to first page if current page is out of range
        });
        updatePaginatedData();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected courses deleted successfully'))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete selected courses: ${response.body}'))
      );
    }
  } catch (e) {
    print('Error while deleting courses: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e'))
    );
  }
}



//   // Unified method to handle the confirmation dialog for both single and multiple rooms
//   void _showDeleteConfirmationDialog({required List<Ruang> rooms}) {
//     String message = rooms.length == 1
//         ? 'Apakah Anda yakin ingin menghapus ruang ini?'
//         : 'Apakah Anda yakin ingin menghapus ${rooms.length} ruang yang dipilih?';

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Konfirmasi Hapus'),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: const Text('Batal'),
//           ),
//           TextButton(
//             onPressed: () {
//               if (rooms.length < 1) {
//                 _deleteRuang(rooms.first); // Delete a single room
//               } else {
//                 _deleteSelectedRuang(rooms); // Delete multiple rooms
//               }
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: const Text('Hapus'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Method to handle deleting a single room
//   Future<void> _deleteRuang(Ruang ruang) async {
//     final response = await http.delete(
//       Uri.parse('http://localhost:8080/ruang/${ruang.kodeRuang}'),
//     );

//     if (response.statusCode == 200) {
//       fetchRuangData();
//       updatePaginatedData();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Ruang berhasil dihapus')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Gagal menghapus ruang')),
//       );
//     }
//   }

//   // Method to handle deleting all selected rooms
//   Future<void> _deleteSelectedRuang(List<Ruang> rooms) async {
//     final selectedCodes = rooms.map((ruang) => ruang.kodeRuang).toList();

//     final response = await http.delete(
//       Uri.parse('http://localhost:8080/ruang/deleteMultiple'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({"kodeRuang": selectedCodes}),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         ruangList.removeWhere((ruang) => selectedCodes.contains(ruang.kodeRuang));
//         selectedRuang.clear();
        
//       });
//       await fetchRuangData();
//       updatePaginatedData();

//       if (currentPage > 1 && ruangList.length <= (currentPage - 1) * rowsPerPage) {
//       setState(() {
//         currentPage = 1; // Reset to first page if current page is out of range
//       });
//       updatePaginatedData();
//     }
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected Ruang deleted successfully')));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete selected rooms')));
//     }
//   }
  
  void updatePaginatedData() {
  final startIndex = (currentPage - 1) * rowsPerPage;
  final endIndex = startIndex + rowsPerPage;
  setState(() {
    paginatedList = matkulList.sublist(startIndex, endIndex < matkulList.length ? endIndex : matkulList.length);
  });
}

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
                          child: _buildMenuItem(Icons.book, 'IRS'),
                        ),
                  
                  const SizedBox(width: 16),
                    GestureDetector(
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        color: Colors.grey[200],
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          margin: EdgeInsets.symmetric(vertical: 40),
          color: Colors.white,
          child:Column(
              children: [
                      Container(
                        margin: EdgeInsets.only(top: 32, bottom: 40),
                        child: Text(
                                'Daftar Mata Kuliah',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children:[
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, // Button background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Rounded edges
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () {
                                  // Add the navigation logic here
                                  Navigator.push(
                                    context, // context should be available if used within StatefulWidget
                                    MaterialPageRoute(
                                      builder: (context) => MyAddMatkulBatchPage( onCsvUploaded: fetchMatkulData), // Navigate to ListRuangPage
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Keeps the button compact
                                  children: const [
                                    Icon(
                                      Icons.folder, // Edit icon
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8), // Space between icon and text
                                    Text(
                                      'Tambah Batch',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, // Button background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Rounded edges
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () {
                                  // // Add the navigation logic here
                                  // Navigator.push(
                                  //   context, // context should be available if used within StatefulWidget
                                  //   MaterialPageRoute(
                                  //     builder: (context) => AddRuangPage(onRoomAdded: fetchRuangData), // Navigate to ListRuangPage
                                  //   ),
                                  // );
                                  Navigator.push(
                                    context, // context should be available if used within StatefulWidget
                                    MaterialPageRoute(
                                      builder: (context) => AddMatkulPage(onMatkulAdded: fetchMatkulData), // Navigate to ListRuangPage
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Keeps the button compact
                                  children: const [
                                    Icon(
                                      Icons.add, // Edit icon
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8), // Space between icon and text
                                    Text(
                                      'Tambah Mata Kuliah',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green, // Button background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Rounded edges
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () {
                                    setState(() {
                                      if (selectAll) {
                                        selectedMatkul.clear();  // Deselect all rooms
                                      } else {
                                        selectedMatkul.addAll(matkulList.map((matkul) => matkul.KodeMK));  // Select all rooms
                                      }
                                      selectAll = !selectAll;
                                    });
                                          print('selectedMatkul after Select All action: $selectedMatkul');
                                          print('matkulList: $matkulList');
                                  },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Keeps the button compact
                                  children: const [
                                    Icon(
                                      Icons.select_all, // Edit icon
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8), // Space between icon and text
                                    Text(
                                      'Select All',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // Button background color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Rounded edges
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () {
                                if (selectedMatkul.isNotEmpty) {
                                  // Inside onPressed for the "Delete Selected" button
                                  _showDeleteConfirmationDialog(courses: selectedMatkul.map((kode) => matkulList.firstWhere((course) => course.KodeMK == kode)).toList());
                                  
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Pilih ruang terlebih dahulu!')),
                                  );
                                }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Keeps the button compact
                                  children: const [
                                    Icon(
                                      Icons.folder_delete, // Edit icon
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8), // Space between icon and text
                                    Text(
                                      'Delete Selected',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ),
                  Container(
                // padding: EdgeInsets.symmetric(horizontal: 100),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                        child: DataTable(
                          columnSpacing: 16.0,
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => const Color(0xFF162953),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                ' ',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Kode MK',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Mata Kuliah',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'SKS',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Semester',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            // DataColumn(
                            //   label: Text(
                            //     'Pengampu',
                            //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            //   ),
                            // ),
                            DataColumn(
                              label: Text(
                                'Action',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: 
                          // []
                          paginatedList
                            .map(
                              (matkul) => DataRow(
                                // selected: selectedMatkul.contains(matkul.KodeMK),
                                cells: [
                                  DataCell( 
                                    Checkbox(
                                      value: selectedMatkul.contains(matkul.KodeMK),
                                      onChanged: (bool? selected) {
                                        setState(() {
                                          if (selected == true) {
                                            selectedMatkul.add(matkul.KodeMK); // Add to selection
                                          } else {
                                            selectedMatkul.remove(matkul.KodeMK); // Remove from selection
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  DataCell(Text(matkul.KodeMK)),
                                  DataCell(Text(matkul.NamaMK)),
                                  DataCell(Text(matkul.SKS.toString())),
                                  DataCell(Text(matkul.Status)),
                                  DataCell(Text(matkul.Semester.toString())),
                                  // DataCell(Text(matkul.NamaProdi)),
                                  DataCell(
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          ),
                                          onPressed: () {
                                                                                        Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditMatkulPage(
                                                  KodeMK: matkul.KodeMK,
                                                  NamaMK: matkul.NamaMK,
                                                  SKS: matkul.SKS,
                                                  Status: matkul.Status,
                                                  Semester: matkul.Semester,
                                                  NamaProdi: matkul.NamaProdi,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                fetchMatkulData(); // Refresh the data after returning
                                              }
                                            });

                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) => EditRuangPage(
                                            //       kodeRuang: ruang.kodeRuang,
                                            //       namaRuang: ruang.namaRuang,
                                            //       gedung: ruang.gedung,
                                            //       lantai: ruang.lantai,
                                            //       fungsi: ruang.fungsi,
                                            //       kapasitas: ruang.kapasitas,
                                            //     ),
                                            //   ),
                                            // ).then((value) {
                                            //   if (value == true) {
                                            //     fetchRuangData(); // Refresh the data after returning
                                            //   }
                                            // });
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.edit, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                'Edit',
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          ),
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(courses: [matkul]);
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.delete, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                'Delete',
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: 
                        currentPage > 1
                            ? () {
                                setState(() {
                                  currentPage--;
                                  updatePaginatedData(); // Refresh the data
                                });
                              }
                            : null,
                      ),
                        Text('Page $currentPage'),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: currentPage * rowsPerPage < matkulList.length
                              ? () {
                                  setState(() {
                                    currentPage++;
                                    updatePaginatedData(); // Refresh the data
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
              ],
            ),
        ),
      )
    );
  }
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


