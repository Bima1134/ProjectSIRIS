import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:siris/class/JadwalIRS.dart';
import 'package:siris/navbar.dart';
import 'package:logging/logging.dart';

final loggerIRSDetail = Logger('IRSDetailPageState');

class IRSDetailPage extends StatefulWidget {
  final Map<String, dynamic> mahasiswa;

  const IRSDetailPage({super.key, required this.mahasiswa});

  @override
  IRSDetailPageState createState() => IRSDetailPageState();
}

class IRSDetailPageState extends State<IRSDetailPage> {
  List<JadwalIRS> jadwalIRS = [];
  Map<String, dynamic> irsInfo = {'status_irs': 'Tidak Ada Data'}; 
  late int selectedSemester; // Default semester
  get userData => widget.mahasiswa;


  String totalSks = '0';
  String ipk = '0.0';
  String ips ='0.0';
  String currentSKS = '0.0';
  
  @override
  void initState() {
    super.initState();
    // Fetch jadwal IRS untuk semester default
    selectedSemester = widget.mahasiswa["semester"] ?? 5;
    fetchIRSJadwal(selectedSemester);
    fetchData();
    fetchIRSInfo(widget.mahasiswa["semester"]);
  }
  // Fungsi untuk mem-fetch data dari API
   Future<void> fetchData() async {
   final nim = widget.mahasiswa['nim'];
    final semester = widget.mahasiswa['semester'];
    final String apiUrl = 'http://localhost:8080/mahasiswa/info-mahasiswa/$nim?semester=$semester';
    debugPrint("Semester : $semester");
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = json.decode(response.body);
        setState(() {
          totalSks = data['total_sks'].toString();
          ipk = data['ipk'].toString();
          ips = data['ips'].toString();
          currentSKS = data['current_sks'].toString();
        });
      } else {
        setState(() {
          totalSks = 'Error';
          ipk = 'Error';
          ips = 'Error';
          currentSKS = 'Error';
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        totalSks = 'Error';
        ipk = 'Error';
        ips = 'Error';
        currentSKS = 'Error';
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchIRSJadwal(int semester) async {
    final nim = widget.mahasiswa["nim"];
    final url = 'http://localhost:8080/mahasiswa/$nim/jadwal-irs?semester=$semester';
    loggerIRSDetail.info('Fetching jadwal for semester: $semester at URL: $url');

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        jadwalIRS = data.map((item) => JadwalIRS.fromJson(item)).toList();
      });
    } else {
      // Handle error
      loggerIRSDetail.severe('Error fetching data: ${response.statusCode}, body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil data jadwal IRS')),
      );
    }
  }

  Future<void> unapproveIRS(String nim, int semester) async {
  final url = 'http://localhost:8080/mahasiswa/$nim/unapprove-irs?semester=$semester';
   // Endpoint untuk unapprove
   debugPrint("Nim : $nim, semester : $semester");
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'semester': semester}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status IRS berhasil diubah menjadi Pending')),
        );
        // Perbarui data IRS
        fetchIRSInfo(semester);
        fetchIRSJadwal(semester);
      } else {
        throw Exception('Unexpected status: ${result['status']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error unapproving IRS: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan, coba lagi')),
    );
  }
}

  Future<void> approveIRS(String nim, int semester) async {
  final url = 'http://localhost:8080/mahasiswa/$nim/approve-irs?semester=$semester'; // Semester sebagai query parameter
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'semester': semester}),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'already_approved') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('IRS sudah disetujui sebelumnya')),
        );
      } else if (result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('IRS berhasil disetujui')),
        );
        // Reload jadwal IRS
        fetchIRSJadwal(selectedSemester);
      } else {
        throw Exception('Unexpected status: ${result['status']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error approving IRS: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan, coba lagi')),
    );
  }
}

Future<void> fetchIRSInfo(int semester) async {
  final nim = widget.mahasiswa['nim'];
  final url = 'http://localhost:8080/mahasiswa/$nim/irs-info?semester=$semester';
  
  try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          // Update status IRS berdasarkan data pertama yang ditemukan
          irsInfo['status_irs'] = data[0]['status'];
        });
      } else {
        setState(() {
          irsInfo['status_irs'] = 'Tidak Ada Data';
        });
      }
    } else {
      print('Failed to fetch IRS info: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching IRS info: $e');
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: Navbar(userData: userData),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detail Mahasiswa
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Detail Mahasiswa", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nama: ${widget.mahasiswa['nama']}"),
                            Text("NIM: ${widget.mahasiswa['nim']}"),
                            Text("Semester: $selectedSemester"),
                            Text("IPK: $ipk"),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("IPS: $ips"),
                            Text("Maks Beban SKS: 24"),
                            Text("Status IRS: ${irsInfo['status_irs']}"),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Isian Rencana Studi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Isian Rencana Studi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<int>(
                  value: selectedSemester,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSemester = value;
                        fetchIRSJadwal(value);
                        fetchIRSInfo(value);
                      });
                    }
                  },
                  items: List.generate(
                    widget.mahasiswa['semester'], // Hanya sampai semester mahasiswa saat ini
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text("Semester ${index + 1}"),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabel
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Kode')),
                  DataColumn(label: Text('Mata Kuliah')),
                  DataColumn(label: Text('Kelas')),
                  DataColumn(label: Text('SKS')),
                  DataColumn(label: Text('Dosen')),
                  DataColumn(label: Text('Status')),
                ],
                rows: jadwalIRS.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final jadwal = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(index.toString())),
                    DataCell(Text(jadwal.KodeMK)),
                    DataCell(Text(jadwal.NamaMK)),
                    DataCell(Text(jadwal.Kelas)),
                    DataCell(Text(jadwal.SKS.toString())),
                    DataCell(Text(jadwal.DosenPengampu.join(', '))),
                    const DataCell(Text('Baru')),
                  ]);
                }).toList(),
              ),
            ),
          ),

          // Tombol Setuju
          // Tombol Setuju dan Unapprove
         Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Menjalankan fungsi approveIRS
                  await approveIRS(widget.mahasiswa['nim'], selectedSemester);
                  
                  // Memanggil fungsi untuk mendapatkan data terbaru dan merefresh halaman
                  setState(() {
                    fetchData();
                    fetchIRSInfo(widget.mahasiswa["semester"]);
                  });
                },
                child: const Text('Setuju'),
              ),
              const SizedBox(width: 16), // Jarak antar tombol
              ElevatedButton(
                onPressed: irsInfo['status_irs'] == 'Disetujui' // Hanya aktif jika IRS disetujui
                    ? () async {
                        // Menjalankan fungsi unapproveIRS
                        await unapproveIRS(widget.mahasiswa['nim'], selectedSemester);
                        
                        // Memanggil fungsi untuk mendapatkan data terbaru dan merefresh halaman
                        setState(() {
                          fetchData();
                          fetchIRSInfo(widget.mahasiswa["semester"]);
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Warna tombol Unapprove
                ),
                child: const Text('Unapprove'),
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

