import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:siris/dekan/detail_jadwal_page.dart';
import 'package:siris/navbar.dart';
import '../class/indexClass.dart';

final loggerJadwal = Logger('JadwalPage');

class JadwalPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  JadwalPage({required this.userData});

  @override
  JadwalPageState createState() => JadwalPageState();
}

class JadwalPageState extends State<JadwalPage> {
  String? selectedSemester;
  List<String> idsemPosisiList = [];
  List<JadwalProdi> jadwalProdi = [];
  get userData => widget.userData;

  @override
  void initState() {
    super.initState();
    fetchIdsemPosisi();
  }

  // Function to fetch idsem and posisi data from the backend
  Future<void> fetchIdsemPosisi() async {
    final response = await http.get(Uri.parse('http://localhost:8080/semester')); // Replace with your actual API URL

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        idsemPosisiList = data.map((item) => '${item['idsem']} - ${item['posisi']}').toList();
        if (idsemPosisiList.isNotEmpty) {
          selectedSemester = idsemPosisiList.last;  // Set default selection after data is loaded
          String? idsem = selectedSemester?.split(' - ')[0];  // Extract idsem
          if (idsem != null) {
            fetchJadwalProdi(idsem); // Trigger the fetch immediately after setting selectedSemester
          }
        }
      });
    } else {
      throw Exception('Failed to load idsem and posisi');
    }
  }

  Future<void> fetchJadwalProdi(String idsem) async {
    final url = 'http://localhost:8080/dekan/jadwal/$idsem';
    loggerJadwal.info("Fetching jadwal prodi for semester: $idsem, URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Iterate over all prodi keys dynamically
        setState(() {
          jadwalProdi.clear();  // Clear previous data
          data.forEach((prodi, jadwalList) {
            if (jadwalList is List) {
              // Assuming the list contains the jadwal data, map it
              jadwalProdi.addAll(
                jadwalList.map((item) => JadwalProdi.fromJson(item)).toList(),
              );
            }
          });
        });

        loggerJadwal.info("Status Code: ${response.statusCode}, jadwal fetched successfully.");
      } else {
        loggerJadwal.warning(
          "Failed to fetch jadwal. Status Code: ${response.statusCode}, Response: ${response.body}"
        );
      }
    } on FormatException catch (e) {
      loggerJadwal.severe("Invalid JSON format: $e");
    } on SocketException catch (e) {
      loggerJadwal.severe("Network error: $e");
    } catch (e) {
      loggerJadwal.severe("Unexpected error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
      body: Scaffold(
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
                            'Daftar Jadwal Prodi',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold
                            ),
                          )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    idsemPosisiList.isEmpty
                      ? const CircularProgressIndicator()
                      : DropdownButton<String>(
                          value: selectedSemester,
                          onChanged: (String? newSemester) {
                            setState(() {
                              selectedSemester = newSemester;
                              String? idsem = selectedSemester?.split(' - ')[0];
                              loggerJadwal.info(idsem);
                              if(idsem != null){
                                fetchJadwalProdi(idsem);
                              }
                              else{
                                debugPrintStack();
                              }
                            });
                          },
                          items: idsemPosisiList.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.split(" - ")[1]),
                            );
                          }).toList(),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                    child: DataTable(
                      columnSpacing: 16.0,
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Color(0xFF162953),
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Id Jadwal',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Program Studi',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            ' ',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                        rows: jadwalProdi.map((jadwal) {
                          final isDisetujui = jadwal.status.toLowerCase() == "sudah disetujui";
                          final isDiisi = jadwal.status.toLowerCase() == "belum diisi";
                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                return Colors.white; // Apply row color
                              },
                            ),
                            cells: [
                            DataCell(Text(jadwal.idJadwal)),
                            DataCell(Text(jadwal.namaProdi)),
                            DataCell(isDisetujui ? Container( 
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(color: Colors.green, borderRadius:BorderRadius.circular(8),),  // Corrected here
                                child: Text(jadwal.status, style: TextStyle(fontSize: 16, color: Colors.white),
                                )
                              ): Text(jadwal.status)),
                            DataCell(
                              Row(
                                children: [
                                  isDiisi?
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    onPressed: () {
                                      detailJadwal(context, jadwal.idJadwal);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.info, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Detail',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )
                                  :Container(
                                    child:
                                      !isDisetujui ?
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
                                              detailJadwal(context, jadwal.idJadwal);
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.info, color: Colors.white),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Detail',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8,),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            ),
                                            onPressed: () {
                                              approveJadwal(context, jadwal.idJadwal, jadwal.idSem); // Memanggil callback saat tombol ditekan
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.check, color: Colors.white),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Setujui',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ) 
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          ),
                                          onPressed: () {
                                            detailJadwal(context, jadwal.idJadwal);
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.info, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                'Detail',
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                    )
                                  ],  
                                  ),
                            ),
                          ]);
                        }).toList()

                        // JadwalDataSource(
                        //           jadwalProdi,
                        //           (idJadwal, idsem) => approveJadwal(context, idJadwal, idsem),
                        //           (idJadwal) => Navigator.push(context, MaterialPageRoute(
                        //             builder:  (context) => DetailJadwalPage(
                        //                                     userData: userData, idJadwalProdi: idJadwal)))
                        //         )
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
      )
    );
  }

  Future<void> approveJadwal(BuildContext context, String idJadwal, String idsem) async {
    final url = "http://localhost:8080/dekan/jadwal/approve/$idJadwal";
    loggerJadwal.info("Sending request to URL: $url");

    try {
      final response = await http.put(Uri.parse(url));
      if (response.statusCode == 200) {
        loggerJadwal.info("Jadwal with ID $idJadwal approved successfully.");
        fetchJadwalProdi(idsem);
        // Tampilkan dialog keberhasilan
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Jadwal berhasil disetujui.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } 
      else {
        loggerJadwal.warning(
            "Failed to approve jadwal. Status Code: ${response.statusCode}, Response: ${response.body}");

        // Tampilkan dialog error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Gagal'),
            content: Text(
                'Gagal menyetujui jadwal. Status Code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on FormatException catch (e) {
      loggerJadwal.severe("Invalid JSON format: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Format data tidak valid.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on SocketException catch (e) {
      loggerJadwal.severe("Network error: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Koneksi Bermasalah'),
          content: const Text('Tidak dapat terhubung ke server.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      loggerJadwal.severe("Unexpected error: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Terjadi kesalahan tak terduga.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<Object> detailJadwal(BuildContext context, String idJadwal) async {
    return Navigator.push(context, MaterialPageRoute(
                                    builder:  (context) => DetailJadwalPage(
                                                            userData: userData, idJadwalProdi: idJadwal)));
  }
}

class JadwalDataSource extends DataTableSource {
  final List<JadwalProdi> jadwalProdi;
  final void Function(String idJadwal, String idsem) onApproveJadwal; // Callback untuk persetujuan
  final Function(String idJadwal) detailJadwal;

  JadwalDataSource(this.jadwalProdi, this.onApproveJadwal, this.detailJadwal);

  @override
  DataRow? getRow(int index) {
    if (index >= jadwalProdi.length) return null;

    final jadwal = jadwalProdi[index];
    final isDisetujui = jadwal.status.toLowerCase() == "sudah disetujui";
    final isDiisi = jadwal.status.toLowerCase() == "belum diisi";
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return Colors.white; // Apply row color
        },
      ),
      cells: [
      DataCell(Text(jadwal.idJadwal)),
      DataCell(Text(jadwal.namaProdi)),
      DataCell(isDisetujui ? Container( 
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: Colors.green, borderRadius:BorderRadius.circular(8),),  // Corrected here
          child: Text(jadwal.status, style: TextStyle(fontSize: 16, color: Colors.white),
          )
        ): Text(jadwal.status)),
      DataCell(
        Row(
          children: [
            isDiisi?
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                detailJadwal(jadwal.idJadwal);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Detail',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
            :Container(
              child:
                !isDisetujui ?
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
                        onApproveJadwal(jadwal.idJadwal, jadwal.idSem); // Memanggil callback saat tombol ditekan
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Setujui',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        detailJadwal(jadwal.idJadwal);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.info, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Detail',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ) 
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      detailJadwal(jadwal.idJadwal);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.info, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Detail',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              )
            ],  
            ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => jadwalProdi.length;

  @override
  int get selectedRowCount => 0;
}
