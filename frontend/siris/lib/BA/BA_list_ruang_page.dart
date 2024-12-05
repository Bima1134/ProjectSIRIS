import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:siris/BA/BA_add_ruang.dart';
import 'package:siris/BA/BA_add_ruang_single.dart';
import 'package:siris/BA/BA_edit_ruang_page.dart';


class Ruang {
  final String kodeRuang;
  final String namaRuang;
  final String gedung;
  final int lantai;
  final String fungsi;
  final int kapasitas;

  Ruang({
    required this.kodeRuang,
    required this.namaRuang,
    required this.gedung,
    required this.lantai,
    required this.fungsi,
    required this.kapasitas,
  });

  factory Ruang.fromJson(Map<String, dynamic> json) {
    return Ruang(
      kodeRuang: json['kode_ruang'],
      namaRuang: json['nama_ruang'],
      gedung: json['gedung'],
      lantai: json['lantai'],
      fungsi: json['fungsi'],
      kapasitas: json['kapasitas'],
    );
  }
}


class ListRuangPage extends StatefulWidget {
  @override
  _ListRuangPageState createState() => _ListRuangPageState();
  
}

class _ListRuangPageState extends State<ListRuangPage> {
  bool selectAll = false;
  List<Ruang> ruangList = [];
  Set<String> selectedRuang = {}; // Store selected room names

  int currentPage = 1;  // Track the current page
  int rowsPerPage = 10; // Number of rows per page
  List<Ruang> paginatedList = []; // To hold the current page data

  @override
  void initState() {
    super.initState();
    fetchRuangData();
  }

  // Fetch ruang data from the backend
  Future<void> fetchRuangData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/ruang'));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            if (data is List) {
              setState(() {
                ruangList = data.map((item) => Ruang.fromJson(item)).toList();
                updatePaginatedData(); // Update paginated data after fetching
              });
            } else {
              setState(() {
                ruangList = []; // Default to empty list if data is not a list
              });
              print('Unexpected data format');
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            setState(() {
              ruangList = []; // Default to empty list if decoding fails
            });
          }
        } else {
          setState(() {
            ruangList = []; // Default to empty list if body is empty
          });
          print('Response body is empty');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        setState(() {
          ruangList = []; // Default to empty list on error
        });
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      setState(() {
        ruangList = []; // Default to empty list on exception
      });
    }
  }


  // Unified method to handle the confirmation dialog for both single and multiple rooms
  void _showDeleteConfirmationDialog({required List<Ruang> rooms}) {
    String message = rooms.length == 1
        ? 'Apakah Anda yakin ingin menghapus ruang ini?'
        : 'Apakah Anda yakin ingin menghapus ${rooms.length} ruang yang dipilih?';

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
              if (rooms.length < 1) {
                _deleteRuang(rooms.first); // Delete a single room
              } else {
                _deleteSelectedRuang(rooms); // Delete multiple rooms
              }
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Method to handle deleting a single room
  Future<void> _deleteRuang(Ruang ruang) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/ruang/${ruang.kodeRuang}'),
    );

    if (response.statusCode == 200) {
      fetchRuangData();
      updatePaginatedData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruang berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus ruang')),
      );
    }
  }

  // Method to handle deleting all selected rooms
  Future<void> _deleteSelectedRuang(List<Ruang> rooms) async {
    final selectedCodes = rooms.map((ruang) => ruang.kodeRuang).toList();

    final response = await http.delete(
      Uri.parse('http://localhost:8080/ruang/deleteMultiple'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"kodeRuang": selectedCodes}),
    );

    if (response.statusCode == 200) {
      setState(() {
        ruangList.removeWhere((ruang) => selectedCodes.contains(ruang.kodeRuang));
        selectedRuang.clear();
        
      });
      await fetchRuangData();
      updatePaginatedData();

      if (currentPage > 1 && ruangList.length <= (currentPage - 1) * rowsPerPage) {
      setState(() {
        currentPage = 1; // Reset to first page if current page is out of range
      });
      updatePaginatedData();
    }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected Ruang deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete selected rooms')));
    }
  }
  
  void updatePaginatedData() {
  final startIndex = (currentPage - 1) * rowsPerPage;
  final endIndex = startIndex + rowsPerPage;
  setState(() {
    paginatedList = ruangList.sublist(startIndex, endIndex < ruangList.length ? endIndex : ruangList.length);
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
                                'Daftar Ruang',
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
                                      builder: (context) => MyHomePage( onCsvUploaded: fetchRuangData), // Navigate to ListRuangPage
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
                                  // Add the navigation logic here
                                  Navigator.push(
                                    context, // context should be available if used within StatefulWidget
                                    MaterialPageRoute(
                                      builder: (context) => AddRuangPage(onRoomAdded: fetchRuangData), // Navigate to ListRuangPage
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
                                      'Tambah Ruang',
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
                                        selectedRuang.clear();  // Deselect all rooms
                                      } else {
                                        selectedRuang.addAll(ruangList.map((ruang) => ruang.kodeRuang));  // Select all rooms
                                      }
                                      selectAll = !selectAll;
                                    });
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
                                if (selectedRuang.isNotEmpty) {
                                  // Inside onPressed for the "Delete Selected" button
                                  _showDeleteConfirmationDialog(rooms: selectedRuang.map((kode) => ruangList.firstWhere((ruang) => ruang.kodeRuang == kode)).toList());

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
                                'Kode Ruang',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Nama Ruang',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Gedung',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Lantai',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Fungsi',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Kapasitas',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Action',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: paginatedList
                            .map(
                              (ruang) => DataRow(
                                // selected: selectedRuang.contains(ruang.namaRuang),
                                cells: [
                                  DataCell(
                                    Checkbox(
                                      value: selectedRuang.contains(ruang.kodeRuang),
                                      onChanged: (bool? selected) {
                                        setState(() {
                                          if (selected == true) {
                                            selectedRuang.add(ruang.kodeRuang); // Add to selection
                                          } else {
                                            selectedRuang.remove(ruang.kodeRuang); // Remove from selection
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  DataCell(Text(ruang.kodeRuang)),
                                  DataCell(Text(ruang.namaRuang)),
                                  DataCell(Text(ruang.gedung)),
                                  DataCell(Text(ruang.lantai.toString())),
                                  DataCell(Text(ruang.fungsi)),
                                  DataCell(Text(ruang.kapasitas.toString())),
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
                                                builder: (context) => EditRuangPage(
                                                  kodeRuang: ruang.kodeRuang,
                                                  namaRuang: ruang.namaRuang,
                                                  gedung: ruang.gedung,
                                                  lantai: ruang.lantai,
                                                  fungsi: ruang.fungsi,
                                                  kapasitas: ruang.kapasitas,
                                                ),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                fetchRuangData(); // Refresh the data after returning
                                              }
                                            });
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
                                            _showDeleteConfirmationDialog(rooms: [ruang]);
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
                        onPressed: currentPage > 1
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
                          onPressed: currentPage * rowsPerPage < ruangList.length
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


