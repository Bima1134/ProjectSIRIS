import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:siris/Kaprodi/Kaprodi_AddJadwal.dart';
import 'package:siris/Kaprodi/Kaprodi_EditJadwal.dart';

import 'package:siris/class/jadwalKaprodi.dart';

class JadwalKaprodiView {
  final int jadwalID;
  final String kodeMk;
  final String namaMatkul;
  final String semester;
  final int sks;
  final String sifat;
  final List<String> dosenPengampu;
  final String kelas;
  final String ruangan;
  final int? kapasitas; // Nullable
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  JadwalKaprodiView({
    required this.jadwalID,
    required this.kodeMk,
    required this.namaMatkul,
    required this.semester,
    required this.sks,
    required this.sifat,
    required this.dosenPengampu,
    required this.kelas,
    required this.ruangan,
    required this.kapasitas,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  // Factory method untuk parsing dari JSON
  factory JadwalKaprodiView.fromJson(Map<String, dynamic> json) {
    var dosenPengampuData = json['dosen_pengampu'];
    List<String> dosenPengampuList = [];

    // Jika dosen_pengampu berupa string yang dipisahkan oleh "|", pisahkan menjadi list
    if (dosenPengampuData is String) {
      dosenPengampuList =
          dosenPengampuData.split('|').map((e) => e.trim()).toList();
    } else if (dosenPengampuData is List) {
      dosenPengampuList = List<String>.from(dosenPengampuData);
    }

    return JadwalKaprodiView(
      jadwalID: json['jadwal_id'] ?? 0, // Jika null, set ke 0
      kodeMk: json['kode_mk'] ?? 'N/A', // Jika null, set ke 'N/A'
      namaMatkul: json['namaMatkul'] ?? 'N/A', // Jika null, set ke 'N/A'
      semester: json['semester'] ?? 'N/A', // Jika null, set ke 'N/A'
      sks: json['sks'] ?? 0, // Jika null, set ke 0
      sifat: json['sifat'] ?? 'N/A', // Jika null, set ke 'N/A'
      dosenPengampu: dosenPengampuList, // Menyimpan list dosen pengampu
      kelas: json['kelas'] ?? 'N/A', // Jika null, set ke 'N/A'
      ruangan: json['kode_ruang'] ?? 'N/A', // Jika null, set ke 'N/A'
      kapasitas: json['kapasitas'] ?? 0, // Jika null, set ke 0
      hari: json['hari'] ?? 'N/A', // Jika null, set ke 'N/A'
      jamMulai: json['Jam_mulai'] ?? 'N/A', // Jika null, set ke 'N/A'
      jamSelesai: json['Jam_selesai'] ?? 'N/A', // Jika null, set ke 'N/A'
    );
  }

  // Method untuk mengonversi ke Map<String, dynamic> (opsional)
  Map<String, dynamic> toJson() {
    return {
      'jadwal_id': jadwalID,
      'kode_mk': kodeMk,
      'namaMatkul': namaMatkul,
      'semester': semester,
      'sks': sks,
      'sifat': sifat,
      'dosen_pengampu': dosenPengampu,
      'kelas': kelas,
      'ruangan': ruangan,
      'kapasitas': kapasitas,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    };
  }
}

// import 'package:siris/BA/BA_add_ruang.dart';
// import 'package:siris/BA/BA_add_ruang_single.dart';
// import 'package:siris/BA/BA_edit_ruang_page.dart';
// import 'package:siris/class/Ruang.dart';

class ListJadwalKaprodiPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ListJadwalKaprodiPage({super.key, required this.userData});

  @override
  _ListJadwalKaprodiPageState createState() => _ListJadwalKaprodiPageState();
}

class _ListJadwalKaprodiPageState extends State<ListJadwalKaprodiPage> {
//   bool selectAll = false;
//   List<Ruang> ruangList = [];
//   Set<String> selectedRuang = {}; // Store selected room names
  List<JadwalKaprodiView> jadwalKaprodi = [];
  get userData => widget.userData;
//   int currentPage = 1;  // Track the current page
//   int rowsPerPage = 10; // Number of rows per page
//   List<Ruang> paginatedList = []; // To hold the current page data

  @override
  void initState() {
    super.initState();
    fetchJadwalData();
  }

  // Fetch ruang data from the backend
  Future<void> fetchJadwalData() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/mahasiswa/jadwal'));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            debugPrint("Data $data");
            if (data is List) {
              setState(() {
                jadwalKaprodi = data
                    .map((item) => JadwalKaprodiView.fromJson(item))
                    .toList();
                // updatePaginatedData(); // Update paginated data after fetching
              });
            } else {
              setState(() {
                jadwalKaprodi =
                    []; // Default to empty list if data is not a list
              });
              print(
                  'Unexpected data format: Expected List but got: ${data.runtimeType}');
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            setState(() {
              jadwalKaprodi = []; // Default to empty list if decoding fails
            });
          }
        } else {
          setState(() {
            jadwalKaprodi = []; // Default to empty list if body is empty
          });
          print('Response body is empty');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          jadwalKaprodi = []; // Default to empty list on error
        });
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      setState(() {
        jadwalKaprodi = []; // Default to empty list on exception
      });
    }
  }

  Future<void> removeJadwal(int jadwalID) async {
    // URL backend untuk menghapus jadwal
    final String url =
        'http://localhost:8080/kaprodi/remove-jadwal/$jadwalID'; // Sesuaikan URL backend Anda

    try {
      // Mengirim permintaan DELETE ke backend
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Cek respons dari server
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Error dari server
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal menghapus jadwal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Menangani error dari sisi jaringan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showDeleteConfirmationDialog(int jadwalId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Hapus',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Apakah yakin ingin menghapus jadwal?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog tanpa aksi
              },
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                // Panggil fungsi removeJadwal dan tunggu hasilnya
                await removeJadwal(jadwalId);

                // Refresh data jadwal
                setState(() {
                  fetchJadwalData();
                });
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor:
                const Color(0xFF162953), // Set the AppBar background color
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
              child: Row(
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
            )),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          color: Colors.grey[200],
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            margin: EdgeInsets.symmetric(vertical: 40),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.only(top: 32, bottom: 40),
                    child: Text(
                      'LIST JADWAL',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    )),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded edges
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          // Add the navigation logic here
                          // Navigator.push(
                          //   context, // context should be available if used within StatefulWidget
                          //   MaterialPageRoute(
                          //     builder: (context) => MyHomePage( onCsvUploaded: fetchRuangData), // Navigate to ListRuangPage
                          //   ),
                          // );
                        },
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Keeps the button compact
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
                          backgroundColor:
                              Colors.blue, // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded edges
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context, // context should be available if used within StatefulWidget
                            MaterialPageRoute(
                              builder: (context) => AddJadwalPage(
                                  userData:
                                      userData), // Navigate to ListRuangPage
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Keeps the button compact
                          children: const [
                            Icon(
                              Icons.add, // Edit icon
                              color: Colors.white,
                            ),
                            SizedBox(width: 8), // Space between icon and text
                            Text(
                              'Tambah Jadwal',
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
                          backgroundColor:
                              Colors.green, // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded edges
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Keeps the button compact
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
                          backgroundColor:
                              Colors.red, // Button background color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded edges
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Keeps the button compact
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
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width),
                      child: DataTable(
                        columnSpacing: 11.0,
                        headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => const Color(0xFF162953),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Kode MK',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Mata Kuliah',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Semester',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'SKS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Sifat',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Pengampu',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Kelas',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Ruangan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Kapasitas',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Hari',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Jam',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Action',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        // rows: []
                        rows: jadwalKaprodi
                            .map(
                              (jadwal) => DataRow(
                                // selected: selectedRuang.contains(ruang.namaRuang),
                                cells: [
                                  DataCell(Text(jadwal.kodeMk ?? 'N/A')),
                                  DataCell(Text(jadwal.namaMatkul ?? 'N/A')),
                                  DataCell(Text(jadwal.semester ?? 'N/A')),
                                  DataCell(Text(jadwal.sks.toString() ?? '0')),
                                  DataCell(Text(jadwal.sifat ?? 'N/A')),
                                  DataCell(
                                    SizedBox(
                                      height:
                                          50.0, // Menentukan tinggi yang diinginkan
                                      child: Container(
                                        width:
                                            250, // Lebar tetap untuk membatasi
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 3.0),
                                        child: Wrap(
                                          children: jadwal.dosenPengampu
                                              .map((dosen) => Text(
                                                    dosen,
                                                    softWrap: true,
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(jadwal.kelas ?? 'N/A')),
                                  DataCell(Text(jadwal.ruangan ?? 'N/A')),
                                  DataCell(Text(
                                      jadwal.kapasitas?.toString() ?? '0')),
                                  DataCell(Text(jadwal.hari ?? 'N/A')),
                                  DataCell(Text(
                                      '${jadwal.jamMulai ?? 'N/A'} - ${jadwal.jamSelesai ?? 'N/A'}')),
                                  DataCell(
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditJadwalPage(
                                                        userData: userData,
                                                        jadwalID: jadwal
                                                            .jadwalID
                                                            .toString(),
                                                        kodeMk: jadwal.kodeMk,
                                                        kelas: jadwal.kelas,
                                                        jamMulai:
                                                            jadwal.jamMulai,
                                                        jamSelesai:
                                                            jadwal.jamSelesai,
                                                        hari: jadwal.hari,
                                                        ruangan: jadwal.ruangan,
                                                        sks: jadwal.sks),
                                              ),
                                            ).then((value) {
                                              if (value == true) {
                                                fetchJadwalData(); // Refresh the data after returning
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.edit,
                                                  color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                'Edit',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                          ),
                                          onPressed: () {
                                            showDeleteConfirmationDialog(
                                                jadwal.jadwalID);
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.delete,
                                                  color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ) //map
                            .toList(),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [],
                ),
              ],
            ),
          ),
        ));
  }
}

Widget _buildMenuItem(IconData icon, String label) {
  return Row(
    children: [
      Icon(icon, color: Colors.white),
      const SizedBox(width: 4),
      Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
    child: const Text('Logout',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  );
}
