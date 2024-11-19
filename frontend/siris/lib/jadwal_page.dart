// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class Jadwal {
//   final String kode;
//   final String nama;
//   final int sks;
//   final String jadwalId;
//   final String nipPengajar;
//   final String kodeRuangan;
//   final String hari;
//   final String jamMulai;
//   final String jamSelesai;
//   final String status;

//   Jadwal({
//     required this.kode,
//     required this.nama,
//     required this.sks,
//     required this.jadwalId,
//     required this.nipPengajar,
//     required this.kodeRuangan,
//     required this.hari,
//     required this.jamMulai,
//     required this.jamSelesai,
//     required this.status,
//   });

//   factory Jadwal.fromJson(Map<String, dynamic> json) {
//     return Jadwal(
//       kode: json['kode_mk'],
//       nama: json['nama_mk'],
//       sks: json['sks'],
//       jadwalId: json['jadwal_id'].toString(),
//       nipPengajar: json['nip_pengajar'],
//       kodeRuangan: json['kode_ruangan'],
//       hari: json['hari'],
//       jamMulai: json['jam_mulai'],
//       jamSelesai: json['jam_selesai'],
//       status: json['status'],
//     );
//   }
// }

// class JadwalPage extends StatefulWidget {
//   final Map<String, dynamic> userData;

//   JadwalPage({required this.userData});

//   @override
//   _JadwalPageState createState() => _JadwalPageState();
// }

// class _JadwalPageState extends State<JadwalPage> {
//   List<Jadwal> jadwalList = [];
//   List<Jadwal> irsList = [];
//   bool isLoading = false;
//   String? jwtToken;

//   @override
//   void initState() {
//     super.initState();
//     loadToken();
//   }

//   Future<void> loadToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       // Mengambil token JWT dari SharedPreferences
//       jwtToken = prefs.getString('jwtToken');
//     });
//     fetchJadwal();
//   }

//   Future<void> fetchJadwal() async {
//     setState(() {
//       isLoading = true;
//     });

//     final response = await http.get(
//       Uri.parse('https://localhost:8080/jadwal'), // Endpoint untuk semua jadwal
//       headers: {
//         'Content-Type': 'application/json',
//         // 'Authorization': 'Bearer $jwtToken', // Hapus atau komen jika tidak menggunakan JWT
//       },
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       setState(() {
//         jadwalList = data.map((item) => Jadwal.fromJson(item)).toList();
//       });
//     } else {
//       throw Exception('Gagal memuat jadwal');
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future<void> fetchIRS() async {
//     setState(() {
//       isLoading = true;
//     });

//     final response = await http.get(
//       Uri.parse('https://localhost:8080/mahasiswa/${widget.userData['identifier']}/jadwal'),
//       headers: {
//         'Content-Type': 'application/json',
//         // 'Authorization': 'Bearer $jwtToken', // Hapus atau komen jika tidak menggunakan JWT
//       },
//     );

//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       setState(() {
//         irsList = data.map((item) => Jadwal.fromJson(item)).toList();
//       });
//     } else {
//       throw Exception('Gagal memuat IRS');
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future<void> addToIRS(Jadwal jadwal) async {
//     final response = await http.post(
//       Uri.parse('https://localhost:8080/mahasiswa/irs'),
//       headers: {
//         'Content-Type': 'application/json',
//         // 'Authorization': 'Bearer $jwtToken', // Hapus atau komen jika tidak menggunakan JWT
//       },
//       body: json.encode({
//         'kode_mk': jadwal.kode,
//         'jadwal_id': jadwal.jadwalId,
//       }),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         irsList.add(jadwal);
//       });
//     } else {
//       throw Exception('Gagal menambahkan jadwal ke IRS');
//     }
//   }

//   Future<void> removeFromIRS(Jadwal jadwal) async {
//     final response = await http.delete(
//       Uri.parse('https://localhost:8080/mahasiswa/irs/${widget.userData['identifier']}'),
//       headers: {
//         'Content-Type': 'application/json',
//         // 'Authorization': 'Bearer $jwtToken', // Hapus atau komen jika tidak menggunakan JWT
//       },
//       body: json.encode({
//         'kode_mk': jadwal.kode,
//         'jadwal_id': jadwal.jadwalId,
//       }),
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         irsList.removeWhere((item) => item.kode == jadwal.kode);
//       });
//     } else {
//       throw Exception('Gagal menghapus jadwal dari IRS');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Pilih Jadwal Mata Kuliah"),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: jadwalList.length,
//                     itemBuilder: (context, index) {
//                       Jadwal jadwal = jadwalList[index];
//                       bool isAdded = irsList.contains(jadwal);

//                       return ListTile(
//                         title: Text(jadwal.nama),
//                         subtitle: Text(
//                             'SKS: ${jadwal.sks} | Kode: ${jadwal.kode} | Ruangan: ${jadwal.kodeRuangan} | Hari: ${jadwal.hari} | Jam: ${jadwal.jamMulai} - ${jadwal.jamSelesai}'),
//                         trailing: IconButton(
//                           icon: Icon(
//                             isAdded ? Icons.remove_circle : Icons.add_circle,
//                             color: isAdded ? Colors.red : Colors.green,
//                           ),
//                           onPressed: () {
//                             if (isAdded) {
//                               removeFromIRS(jadwal);
//                             } else {
//                               addToIRS(jadwal);
//                             }
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Divider(),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     "Mata Kuliah di IRS Anda:",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: irsList.length,
//                     itemBuilder: (context, index) {
//                       Jadwal jadwal = irsList[index];
//                       return ListTile(
//                         title: Text(jadwal.nama),
//                         subtitle: Text('SKS: ${jadwal.sks} | Kode: ${jadwal.kode}'),
//                         trailing: IconButton(
//                           icon: Icon(Icons.delete, color: Colors.red),
//                           onPressed: () {
//                             removeFromIRS(jadwal);
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JadwalPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  JadwalPage({required this.userData});

  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<dynamic> mataKuliahList = [];
  List<dynamic> jadwalList = [];
  List<dynamic> jadwalListIRS = [];
  dynamic selectedMataKuliah;
  dynamic selectedJadwal;

  @override
  void initState() {
    super.initState();
    fetchMataKuliah();
    fetchJadwalIRS();
  }

  Future<void> fetchMataKuliah() async {
    final nim = widget.userData['identifier'];
    final url = 'http://localhost:8080/mahasiswa/$nim/mata-kuliah';
    final response = await http.get(Uri.parse(url));
    print('Nim ID: $nim');
    if (response.statusCode == 200) {
      setState(() {
        mataKuliahList = json.decode(response.body);
      });
      print('Mata kuliah list: $mataKuliahList');
    } else {
      print('Error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data mata kuliah')),
      );
    }
  }

  Future<void> fetchJadwal(String kodeMK) async {
    print('Kode ID: $kodeMK');
    final url = 'http://localhost:8080/mahasiswa/$kodeMK/jadwal-mata-kuliah';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        final mataKuliahData = mataKuliahList.firstWhere((mataKuliah) => mataKuliah['kode_mk'] == kodeMK);
        jadwalList = json.decode(response.body).map((jadwal) {
          return {
            ...jadwal,
            'nama_mk': mataKuliahData['nama_mk'],
            'status': mataKuliahData['status'],
            'kode_mk': mataKuliahData['kode_mk'],
            'semester': mataKuliahData['semester'],
            'sks': mataKuliahData['sks'],
          };
        }).toList();
      });
      print('Jadwal list: $jadwalList');
    } else {
      print('Error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data jadwal')),
      );
    }
  }

  Future<void> addJadwalToIRS(String kodeMK, String jadwalID) async {
    final nim = widget.userData['identifier'];
    final url = 'http://localhost:8080/mahasiswa/$nim/add-irs?kode_mk=$kodeMK&jadwal_id=$jadwalID';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'nim': nim,
        'kode_mk': kodeMK,
        'jadwal_id': jadwalID,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jadwal berhasil ditambahkan ke IRS')),
      );
      fetchJadwalIRS(); // Refresh jadwal IRS list
    } else {
      print('Error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan jadwal ke IRS')),
      );
    }
  }

  Future<void> fetchJadwalIRS() async {
    final nim = widget.userData['identifier'];
    final url = 'http://localhost:8080/mahasiswa/$nim/jadwal';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        jadwalListIRS = json.decode(response.body);
      });
      print('Jadwal IRS list: $jadwalListIRS');
    } else {
      print('Error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data jadwal IRS')),
      );
    }
  }

  void showDeleteConfirmationDialog(dynamic jadwal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Penghapusan'),
          content: Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                // Placeholder for delete action
                Navigator.of(context).pop();
              },
              child: Text('Ya'),
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
        title: const Text('Daftar Mata Kuliah dan Jadwal'),
      ),
      body: Column(
        children: [
          DropdownButton<dynamic>(
            hint: const Text("Pilih Mata Kuliah"),
            value: selectedMataKuliah,
            onChanged: (newValue) {
              setState(() {
                selectedMataKuliah = newValue;
                jadwalList = []; // Reset jadwal saat mata kuliah diubah
                fetchJadwal(newValue['kode_mk']);
              });
            },
            items: mataKuliahList.map<DropdownMenuItem<dynamic>>((mataKuliah) {
              return DropdownMenuItem<dynamic>(
                value: mataKuliah,
                child: Text('${mataKuliah['kode_mk']} - ${mataKuliah['nama_mk']}'),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          DropdownButton<dynamic>(
            hint: const Text("Pilih Jadwal"),
            value: selectedJadwal,
            onChanged: (newValue) {
              setState(() {
                selectedJadwal = newValue;
              });
            },
            items: jadwalList.map<DropdownMenuItem<dynamic>>((jadwal) {
              return DropdownMenuItem<dynamic>(
                value: jadwal,
                child: Text(
                  '${jadwal['nama_mk']} - ${jadwal['status']} - ${jadwal['kode_mk']} - ${jadwal['semester']} - ${jadwal['sks']} | '
                  'Hari: ${jadwal['hari']} - Ruangan: ${jadwal['kode_ruangan']}\n'
                  '${jadwal['jam_mulai']} - ${jadwal['jam_selesai']}',
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectedJadwal != null
                ? () {
                    addJadwalToIRS(
                      selectedMataKuliah['kode_mk'],
                      selectedJadwal['jadwal_id'].toString(),
                    );
                  }
                : null,
            child: const Text("Tambah ke IRS"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: jadwalListIRS.length,
              itemBuilder: (context, index) {
                final jadwal = jadwalListIRS[index];
                return ListTile(
                  title: Text('${jadwal['nama_mk']} - ${jadwal['status']} - ${jadwal['kode_mk']} - ${jadwal['semester']} - ${jadwal['sks']} | '
                  'Hari: ${jadwal['hari']} - Ruangan: ${jadwal['kode_ruangan']}\n'
                  '${jadwal['jam_mulai']} - ${jadwal['jam_selesai']}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDeleteConfirmationDialog(jadwal);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

