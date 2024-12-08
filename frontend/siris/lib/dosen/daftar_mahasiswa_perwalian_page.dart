import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:siris/mahasiswa/detail_irs_mahasiswa.dart';
import 'package:siris/navbar.dart';

class DaftarMahasiswaPerwalianPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DaftarMahasiswaPerwalianPage({super.key, required this.userData});

  @override
  DaftarMahasiswaPerwalianPageState createState() => DaftarMahasiswaPerwalianPageState();
}

class DaftarMahasiswaPerwalianPageState extends State<DaftarMahasiswaPerwalianPage> {
  List<dynamic> mahasiswaList = [];
   List<int> angkatanList = [];
  int? selectedAngkatan;
  bool isLoading = false;
  get userData => widget.userData;

  @override
  void initState() {
    super.initState();
    fetchMahasiswaPerwalian();
    fetchAngkatan();
  }

  Future<void> fetchAngkatan() async {
    final nip = widget.userData['identifier'];
    final url = 'http://localhost:8080/dosen/$nip/angkatan';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        angkatanList = List<int>.from(json.decode(response.body));
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data angkatan')),
        );
      }
    }
  }

  Future<void> fetchMahasiswaPerwalian() async {
    if (selectedAngkatan == null) return;

    setState(() {
      isLoading = true;
    });

    final nip = widget.userData['identifier'];
    final url =
        'http://localhost:8080/dosen/$nip/mahasiswa?angkatan=$selectedAngkatan';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        mahasiswaList = json.decode(response.body);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data mahasiswa')),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
      body: LayoutBuilder(builder: (context, constraints) {
        return Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 32),
                child: const Text(
                  'Daftar Mahasiswa Perwalian',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Dropdown untuk memilih angkatan
                    DropdownButton<int>(
                      hint: const Text("Pilih Angkatan"),
                      value: selectedAngkatan,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedAngkatan = newValue;
                        });
                        fetchMahasiswaPerwalian(); // Mem-fetch data mahasiswa sesuai angkatan
                      },
                      items: angkatanList.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('Angkatan $value'),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Menampilkan data mahasiswa jika ada
                    isLoading
                        ? const CircularProgressIndicator()
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('No')),
                                DataColumn(label: Text('Nama')),
                                DataColumn(label: Text('NIM')),
                                DataColumn(label: Text('Angkatan')),
                                DataColumn(label: Text('Aksi')),
                              ],
                              rows: mahasiswaList.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final mahasiswa = entry.value;
                                return DataRow(cells: [
                                  DataCell(Text(index.toString())),
                                  DataCell(Text(mahasiswa['nama'])),
                                  DataCell(Text(mahasiswa['nim'])),
                                  DataCell(Text(mahasiswa['angkatan'].toString())),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => IRSDetailPage(
                                              mahasiswa: mahasiswa,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('IRS Detail'),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}