import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:siris/navbar.dart';
import '../class/indexClass.dart';
import 'package:siris/dekan/detail_ruang_page.dart';

final loggerRuang = Logger('RuangPage');

class RuangPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const RuangPage({super.key, required this.userData});

  @override
  RuangPageState createState() => RuangPageState();
}

class RuangPageState extends State<RuangPage> {
  String? selectedSemester;
  List<String> idsemPosisiList = [];
  List<AlokasiRuang> ruangProdi = [];
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
            fetchRuangProdi(idsem); // Trigger the fetch immediately after setting selectedSemester
          }
        }
      });
    } else {
      throw Exception('Failed to load idsem and posisi');
    }
  }

  Future<void> fetchRuangProdi(String idsem) async {
    final url = 'http://localhost:8080/dekan/ruang/$idsem';
    loggerRuang.info("Fetching ruang prodi for semester: $idsem, URL: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        loggerDetailRuang.info(data);
        // Iterate over all prodi keys dynamically
        setState(() {
          ruangProdi.clear();  // Clear previous data
          data.forEach((prodi, ruangList) {
            if (ruangList is List) {
              // Assuming the list contains the ruang data, map it
              ruangProdi.addAll(
                ruangList.map((item) => AlokasiRuang.fromJson(item)).toList(),
              );
            }
          });
        });

        loggerRuang.info("Status Code: ${response.statusCode}, ruang fetched successfully.");
      } else {
        loggerRuang.warning(
          "Failed to fetch ruang. Status Code: ${response.statusCode}, Response: ${response.body}"
        );
      }
    } on FormatException catch (e) {
      loggerRuang.severe("Invalid JSON format: $e");
    } on SocketException catch (e) {
      loggerRuang.severe("Network error: $e");
    } catch (e) {
      loggerRuang.severe("Unexpected error: $e");
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
                            'Daftar Ruang Prodi',
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
                              loggerRuang.info(idsem);
                              if(idsem != null){
                                fetchRuangProdi(idsem);
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
                    child: PaginatedDataTable(
                      columnSpacing: 16.0,
                      headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => Color(0xFF162953),
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Id Ruang',
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
                        source: RuangDataSource(
                                  ruangProdi,
                                  (idAlokasi, idsem) => approveRuang(context, idAlokasi, idsem),
                                  (idAlokasi) => Navigator.push(context, MaterialPageRoute(
                                    builder:  (context) => DetailRuangPage(
                                                            userData: userData, idAlokasiRuang: idAlokasi)))
                                )
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

  Future<void> approveRuang(BuildContext context, String idAlokasi, String idsem) async {
    final url = "http://localhost:8080/dekan/ruang/approve/$idAlokasi";
    loggerRuang.info("Sending request to URL: $url");

    try {
      final response = await http.put(Uri.parse(url));
      if (response.statusCode == 200) {
        loggerRuang.info("Ruang with ID $idAlokasi approved successfully.");
        fetchRuangProdi(idsem);
        // Tampilkan dialog keberhasilan
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Berhasil'),
            content: const Text('Ruang berhasil disetujui.'),
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
        loggerRuang.warning(
            "Failed to approve ruang. Status Code: ${response.statusCode}, Response: ${response.body}");

        // Tampilkan dialog error
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Gagal'),
            content: Text(
                'Gagal menyetujui ruang. Status Code: ${response.statusCode}'),
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
      loggerRuang.severe("Invalid JSON format: $e");
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
      loggerRuang.severe("Network error: $e");
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
      loggerRuang.severe("Unexpected error: $e");
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

  Future<Object> detailRuang(BuildContext context, String idAlokasi) async {
    return Navigator.push(context, MaterialPageRoute(
                                    builder:  (context) => DetailRuangPage(
                                                            userData: userData, idAlokasiRuang: idAlokasi)));
  }
}

class RuangDataSource extends DataTableSource {
  final List<AlokasiRuang> ruangProdi;
  final void Function(String idAlokasi, String idsem) onApproveRuang; // Callback untuk persetujuan
  final Function(String idAlokasi) detailRuang;

  RuangDataSource(this.ruangProdi, this.onApproveRuang, this.detailRuang);

  @override
  DataRow? getRow(int index) {
    if (index >= ruangProdi.length) return null;

    final ruang = ruangProdi[index];
    final isDisetujui = ruang.status.toLowerCase() == "sudah disetujui";
        final isDiisi = ruang.status.toLowerCase() == "belum diisi";
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return Colors.white; // Apply row color
        },
      ),
      cells: [
      DataCell(Text(ruang.idAlokasi)),
      DataCell(Text(ruang.namaProdi)),
      DataCell(Text(ruang.status)),
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
                detailRuang(ruang.idAlokasi);
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
                        onApproveRuang(ruang.idAlokasi, ruang.idSem); // Memanggil callback saat tombol ditekan
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
                        detailRuang(ruang.idAlokasi);
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
                      detailRuang(ruang.idAlokasi);
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
  int get rowCount => ruangProdi.length;

  @override
  int get selectedRowCount => 0;
}
