import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DaftarMahasiswaPerwalianPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  DaftarMahasiswaPerwalianPage({required this.userData});

  @override
  _DaftarMahasiswaPerwalianPageState createState() => _DaftarMahasiswaPerwalianPageState();
}

class _DaftarMahasiswaPerwalianPageState extends State<DaftarMahasiswaPerwalianPage> {
  List<dynamic> mahasiswaList = [];

  @override
  void initState() {
    super.initState();
    fetchMahasiswaPerwalian();
  }

  Future<void> fetchMahasiswaPerwalian() async {
    final nip = widget.userData['identifier']; // Ambil nip dari userData
    print("NIP dari userData: $nip"); // Tambahkan log untuk memeriksa NIP
    final url = 'http://localhost:8080/dosen/$nip/mahasiswa';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        mahasiswaList = json.decode(response.body);
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data mahasiswa dan nip =$nip')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Mahasiswa Perwalian'),
      ),
      body: ListView.builder(
        itemCount: mahasiswaList.length,
        itemBuilder: (context, index) {
          final mahasiswa = mahasiswaList[index];
          return ListTile(
            title: Text(mahasiswa['nama']),
            subtitle: Text('NIM: ${mahasiswa['nim']} - Angkatan: ${mahasiswa['angkatan']}'),
          );
        },
      ),
    );
  }
}
