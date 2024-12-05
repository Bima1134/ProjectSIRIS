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
  late int selectedSemester; // Default semester
  get userData => widget.mahasiswa;

  @override
  void initState() {
    super.initState();
    // Fetch jadwal IRS untuk semester default
    selectedSemester = widget.mahasiswa["semester"] ?? 5;
    fetchIRSJadwal(selectedSemester);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Kode MK')),
                  DataColumn(label: Text('Nama MK')),
                  DataColumn(label: Text('Ruangan')),
                  DataColumn(label: Text('Hari')),
                  DataColumn(label: Text('Jam Mulai')),
                  DataColumn(label: Text('Jam Selesai')),
                  DataColumn(label: Text('Kelas')),
                  DataColumn(label: Text('SKS')),
                  DataColumn(label: Text('Dosen Pengampu')),
                ],
                rows: jadwalIRS.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final jadwal = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(index.toString())),
                    DataCell(Text(jadwal.KodeMK)),
                    DataCell(Text(jadwal.NamaMK)),
                    DataCell(Text(jadwal.Ruangan)),
                    DataCell(Text(jadwal.Hari)),
                    DataCell(Text(jadwal.JamMulai)),
                    DataCell(Text(jadwal.JamSelesai)),
                    DataCell(Text(jadwal.Kelas)),
                    DataCell(Text(jadwal.SKS.toString())),
                    DataCell(Text(jadwal.DosenPengampu.join(', '))),
                  ]);
                }).toList(),
              ),
            ),
          ),
          Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => approveIRS(widget.mahasiswa['nim'], selectedSemester),
            child: const Text('Setuju'),
          ),
        ),
        ],
      ),
    );
  }
}

