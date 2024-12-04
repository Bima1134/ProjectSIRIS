import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:siris/class/JadwalIRS.dart';
import 'package:siris/navbar.dart';

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
  List<dynamic> SelectedMatKul = [];
  List<dynamic> SelectedMatKulFetchJadwal = [];
  Map<String, List<dynamic>> jadwalMap = {}; // Map to store kode_mk as key and list of jadwal as value
  get userData => widget.userData;

  @override
  void initState() {
    super.initState();
    fetchMataKuliah();
    fetchIRSJadwal();
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

  Future<List<JadwalIRS>> fetchIRSJadwal() async {
  final nim = widget.userData['identifier'];
  final semester = widget.userData['semester'];
  final String url = 'http://localhost:8080/mahasiswa/all-jadwal/$nim?semester=$semester';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("Data yang diterima dari API: $data");  // Log untuk melihat data yang diterima

      // Iterasi data dan masukkan ke dalam map
      for (var item in data) {
        print('Status: ${item['status']}');  // Log untuk memeriksa status tiap item
        final kodeMK = item['kode_mk'];
        if (jadwalMap.containsKey(kodeMK)) {
          jadwalMap[kodeMK]!.add(item);
        } else {
          jadwalMap[kodeMK] = [item];
        }
      }

      setState(() {});
      return data.map((item) => JadwalIRS.fromJson(item)).toList();
    } else {
      throw Exception('Gagal mengambil data jadwal.');
    }
  } catch (e) {
    print('Error: $e');
    return [];
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
        print("jadwal $jadwalList");
      });
      print('Jadwal list: $jadwalList');
    } else {
      print('Error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data jadwal xx')),
      );
    }
  }

  Future<void> addJadwalToIRS(String kodeMK, int jadwalID) async {
    final nim = widget.userData['identifier'];
    final url = 'http://localhost:8080/mahasiswa/$nim/add-irs?kode_mk=$kodeMK&jadwal_id=$jadwalID';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'nim': nim,
        'kode_mk': kodeMK,
        'jadwal_id': jadwalID.toString(),
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
  Future<void> removeJadwalFromIRS(String kodeMK, int jadwalID) async {
  final nim = widget.userData['identifier']; // NIM dari user data
  final url = 'http://localhost:8080/mahasiswa/$nim/remove-irs?kode_mk=$kodeMK&jadwal_id=$jadwalID';

  try {
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jadwal berhasil dihapus dari IRS')),
      );
      fetchJadwalIRS(); // Refresh jadwal IRS list
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data tidak ditemukan di IRS')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus jadwal dari IRS')),
      );
      print('Error: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan, coba lagi nanti')),
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

  void showDeleteConfirmationDialog(String kodeMK, int jadwalID) {
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
              onPressed: () async  {
                // Placeholder for delete action
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(child: CircularProgressIndicator());
                    },
                  );
                  await removeJadwalFromIRS(kodeMK, jadwalID);
                  Navigator.of(context).pop(); // Tutup loader
                  Navigator.of(context).pop(); // Tutup dialog
                  // Refresh data di halaman utama
              setState(() {
                // Panggil ulang fungsi yang mengambil data jadwal, misalnya:
                fetchIRSJadwal();
              });
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }


  int getDayIndex(String day) {
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  return days.indexOf(day);
  
}

int getTimeIndex(String time) {
  // Extract hour from time string (e.g., "10:00" -> 10)
  final hour = int.parse(time.split(':')[0]);
  return hour - 7; // Subtract 7 since rows start from 07:00
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],  // Set the background color to light gray
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container( 
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      // decoration: BoxDecoration(
                      //   border: Border.all(
                      //     color: Colors.blue, // Border color
                      //     width: 2.0, // Border width
                      //   ),
                      //   borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
                      // ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person, // Edit icon
                                color: Colors.black,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Detail Mahasiswa',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                            ],),
                          const SizedBox(height: 20),
                          Table(
                            columnWidths: {
                              0: FractionColumnWidth(0.4),
                              1: FractionColumnWidth(0.6),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Lorem Ipsum', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Lorem Ipsum', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Lorem Ipsum', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Lorem Ipsum', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Nama', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Lorem Ipsum', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          DropdownButton<dynamic>(
                            hint: const Text("Pilih Mata Kuliah"),
                            value: selectedMataKuliah,
                            isExpanded: true,
                            onChanged: (newValue) {
                              setState(() {
                                selectedMataKuliah = newValue;
                                // jadwalList = []; // Reset jadwal saat mata kuliah diubah
                                // fetchJadwal(newValue['kode_mk']);
                              });
                            },
                          items: mataKuliahList
                              .where((mataKuliah) => !SelectedMatKul.contains(mataKuliah))
                              .map<DropdownMenuItem<dynamic>>((mataKuliah) {
                              return DropdownMenuItem<dynamic>(
                                value: mataKuliah,
                                child: Text('${mataKuliah['kode_mk']} - ${mataKuliah['nama_mk']}'),
                              );
                            }).toList(),
                          ),

                          ElevatedButton(
                            onPressed: selectedMataKuliah != null
                                ? () async {
                                      await fetchJadwal(selectedMataKuliah['kode_mk']); // Fetch jadwal asynchronously

                                      setState(() {
                                      SelectedMatKul.add(selectedMataKuliah);
                                      jadwalMap[selectedMataKuliah['kode_mk']] = List.from(jadwalList);                             
                                      selectedMataKuliah = null; // Reset the selected value
                                      print("Jadwalmap: ");
                                      jadwalMap.forEach((kodeMk, jadwalList) {
                                        print('Kode MK: $kodeMk');
                                        print('Jadwal: $jadwalList');
                                      });
                                    });
                          
                                    print("Selecteed matkul $SelectedMatKul");
                                    print("SelectedMatKulJadwal $SelectedMatKulFetchJadwal");
                                  }

                                : null,
                            child: Row (
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add,
                                  ),
                                SizedBox(width: 8), 
                                Text("Tambah Mata Kuliah"),
                              ],),
                            
                          ),
                        ],
                      )
                    ),
                    
                    const SizedBox(height: 10),
                    // Container(
                    //   width: double.infinity,
                    //   child: DropdownButton<dynamic>(
                    //     hint: const Text("Pilih Jadwal"),
                    //     value: selectedJadwal,
                    //     onChanged: (newValue) {
                    //       setState(() {
                    //         selectedJadwal = newValue;
                    //       });
                    //     },
                    //     items: jadwalList.map<DropdownMenuItem<dynamic>>((jadwal) {
                    //       return DropdownMenuItem<dynamic>(
                    //         value: jadwal,
                    //         child: Text(
                    //           '${jadwal['nama_mk']} - ${jadwal['status']} - ${jadwal['kode_mk']} - ${jadwal['semester']} - ${jadwal['sks']} | '
                    //           'Hari: ${jadwal['hari']} - Ruangan: ${jadwal['kode_ruangan']}\n'
                    //           '${jadwal['jam_mulai']} - ${jadwal['jam_selesai']}',
                    //         ),
                    //       );
                    //     }).toList(),
                    //   ),
                    // ),


                    const SizedBox(height: 20),


                      

                    // Expanded(
                    //   child: ListView.builder(
                    //     itemCount: jadwalListIRS.length,
                    //     itemBuilder: (context, index) {
                    //       final jadwal = jadwalListIRS[index];
                    //       return ListTile(
                    //         title: Text('${jadwal['nama_mk']} - ${jadwal['status']} - ${jadwal['kode_mk']} - ${jadwal['semester']} - ${jadwal['sks']} | '
                    //             'Hari: ${jadwal['hari']} - Ruangan: ${jadwal['kode_ruangan']}\n'
                    //             '${jadwal['jam_mulai']} - ${jadwal['jam_selesai']}',
                    //         ),
                    //         trailing: IconButton(
                    //           icon: Icon(Icons.delete, color: Colors.red),
                    //           onPressed: () {
                    //             showDeleteConfirmationDialog(jadwal);
                    //           },
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container( 
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    top: BorderSide(color: Colors.grey, width: 4),
                                    bottom: BorderSide(color: Colors.grey, width: 4),
                                    right: BorderSide(color: Colors.grey, width: 4),
                                    left: BorderSide(color: Colors.grey, width: 16)
                                  )
                                ),
                                child: Text("MATEMATIKA 1 - PAIK6101"),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            flex : 3,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal:16),
              child :Column(
                children: [
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tabel Jadwal",
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text(
                            "Jumlah SKS Diambil :"
                          ),
                          const SizedBox(width: 20),
                          _buildSaveButton()
                        ],)
                  ],
                  ),
                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      border: TableBorder.all(), // Add borders for each cell
                      children: [
                        // Header row with days of the week
                        TableRow(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              color: Colors.blueGrey,
                              child: Text(
                                'Time\\Day',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'].map((day) {
                              return Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.blueGrey,
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        // Rows with time slots
                        ...List.generate(15, (index) {
                          final time = (7 + index).toString().padLeft(2, '0') + ":00";
                        
                          return TableRow(
                            
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                color: Colors.blueGrey[100],
                                child: Text(time, textAlign: TextAlign.center),
                              ),
                              ...List.generate(5, (dayIndex) {
                                // Find the event for the current time and day
                                List<Widget> events = [];
                                jadwalMap.forEach((kodeMk, jadwalList) {
                                  for (var jadwal in jadwalList) {
                                    final dayIndexMap = getDayIndex(jadwal['hari']);
                                    final timeIndexMap = getTimeIndex(jadwal['jam_mulai']);
                                    final status = jadwal['status']; // ambil status jadwal

                                    // print('Kode MK: $kodeMk');
                                    // print('Jadwal: $jadwal');

                                    // print('eventDayIndex: $dayIndexMap, eventTimeIndex: $timeIndexMap');
                                    // print('dayIndex: $dayIndex, timeIndex: $index');


                                    if (dayIndex == dayIndexMap && index == timeIndexMap) {
                                       String eventText = '${jadwal['nama_mk']} (${kodeMk})\n'
                                        '${jadwal['hari']} ${jadwal['jam_mulai']} - ${jadwal['jam_selesai']}\n'
                                        '${jadwal['kode_ruangan']} • ${jadwal['sks']} SKS'; // Tambahkan enter (\n) antar elemen
                                      events.add(
                                        ElevatedButton(
                                          onPressed: () {
                                            print('Status: $status');
                                            print('Kode MK: ${jadwal['kode_mk']}, Jadwal ID: ${jadwal['jadwal_id']}');
                                            if (status == 'diambil') {
                                              // Tampilkan dialog konfirmasi penghapusan
                                              showDeleteConfirmationDialog(jadwal['kode_mk'], jadwal['jadwal_id']);
                                            } else {
                                              // Tambahkan jadwal ke IRS
                                              addJadwalToIRS(jadwal['kode_mk'], jadwal['jadwal_id']);
        }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: status == 'diambil' ? Colors.blue : Colors.grey,
                                          ),
                                          child: Text(eventText, textAlign: TextAlign.center),
                                        ),
                                      );
                                    }
                                  }
                                });

                                return Container(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                  children: events, // Add all events in column to avoid overlap
                ),
 // Empty if no event
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),


                ],)
            )
            )
        ],
        )
    );
  }
}

  Widget _buildSaveButton(){
    return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent, // Button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // Rounded edges
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              // Add button action here
            },
            child: Row(
              mainAxisSize: MainAxisSize.min, // Keeps the button compact
              children: const [
                Icon(
                  Icons.save, // Edit icon
                  color: Colors.white,
                ),
                SizedBox(width: 8), // Space between icon and text
                Text(
                  'Simpan IRS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
          
  }

  Widget _buildCourseCard(String event){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(8),
      width: 40,
      decoration: BoxDecoration(
        color: Colors.green[300],
        border: Border(
          top:BorderSide(color: Colors.grey, width: 4),
          bottom:BorderSide(color: Colors.grey, width: 4),
          right:BorderSide(color: Colors.grey, width: 4),
          left: BorderSide(color: Colors.grey, width: 16)
        )
      ),
      child: Text(
        event,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Widget _buildCourseCard2(){
  //   return a;
  // }