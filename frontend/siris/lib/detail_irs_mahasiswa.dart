import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JadwalIRS {
  final String KodeMK;
  final String NamaMK;
  final String Ruangan;
  final String Hari;
  final String JamMulai;
  final String JamSelesai;
  final String Kelas;
  final int SKS;
  final List<String> DosenPengampu;
  final String status;

  JadwalIRS({
    required this.KodeMK,
    required this.NamaMK,
    required this.Ruangan,
    required this.Hari,
    required this.JamMulai,
    required this.JamSelesai,
    required this.Kelas,
    required this.SKS,
    required this.DosenPengampu,
    required this.status,
  });

  factory JadwalIRS.fromJson(Map<String, dynamic> json) {
    return JadwalIRS(
      KodeMK: json['kode_mk'],
      NamaMK: json['nama_mk'],
      Ruangan: json['kode_ruangan'],
      Hari: json['hari'],
      JamMulai: json['jam_mulai'],
      JamSelesai: json['jam_selesai'],
      Kelas: json['kelas'],
      SKS: json['sks'],
      DosenPengampu: List<String>.from(json['dosen_pengampu']),
      status: json['status'],
    );
  }
}

class IRSDetailPage extends StatefulWidget {
  final Map<String, dynamic> mahasiswa;

  IRSDetailPage({required this.mahasiswa});

  @override
  _IRSDetailPageState createState() => _IRSDetailPageState();
}

class _IRSDetailPageState extends State<IRSDetailPage> {
  List<JadwalIRS> jadwalIRS = [];
  late int selectedSemester; // Default semester

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
    print('Fetching jadwal for semester: $semester at URL: $url');

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        jadwalIRS = data.map((item) => JadwalIRS.fromJson(item)).toList();
      });
    } else {
      // Handle error
      print('Error fetching data: ${response.statusCode}, body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data jadwal IRS')),
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
      appBar: AppBar(
        title: Text('IRS Detail - ${widget.mahasiswa['nama']}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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

