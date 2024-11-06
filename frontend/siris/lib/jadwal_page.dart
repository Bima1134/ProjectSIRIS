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
  @override
  _JadwalPageState createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  List<dynamic> jadwalList = [];

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    final url = 'http://localhost:8080/jadwal'; // Endpoint untuk mendapatkan daftar jadwal
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        jadwalList = json.decode(response.body);
      });
    } else {
      // Menampilkan error jika gagal mengambil data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data jadwal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Jadwal Mata Kuliah'),
      ),
      body: ListView.builder(
        itemCount: jadwalList.length,
        itemBuilder: (context, index) {
          final jadwal = jadwalList[index];
          return ListTile(
            title: Text(jadwal['kode_mk'] ?? 'Kode MK tidak tersedia'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pengajar: ${jadwal['nip_pengajar'] ?? 'Tidak tersedia'}'),
                Text('Ruangan: ${jadwal['kode_ruangan'] ?? 'Tidak tersedia'}'),
                Text('Hari: ${jadwal['hari'] ?? 'Tidak tersedia'}'),
                Text('Jam: ${jadwal['jam_mulai'] ?? 'Tidak tersedia'} - ${jadwal['jam_selesai'] ?? 'Tidak tersedia'}'),
              ],
            ),
            isThreeLine: true,
          );
        },
      ),
    );
  }
}
