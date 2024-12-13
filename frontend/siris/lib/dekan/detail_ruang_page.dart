import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:siris/navbar.dart';
import '../class/indexClass.dart';
import 'dart:convert';
import 'dart:io';

final loggerDetailRuang = Logger('DetailRuangPage');

class DetailRuangPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String idAlokasiRuang;

  @override
  DetailRuangPageState createState() => DetailRuangPageState();

  const DetailRuangPage({super.key, required this.userData, required this.idAlokasiRuang});
}

class DetailRuangPageState extends State<DetailRuangPage>{
  get userData => widget.userData;
  get idAlokasiRuang => widget.idAlokasiRuang;
  AlokasiRuang? dataDokumen;
  List<dynamic> ListRuangProdi = [];

  @override
  void initState(){
    super.initState();
    fetchDocumentAlokasi();
    fetchListRuangProdi(idAlokasiRuang);
  }

  Future<void> fetchDocumentAlokasi() async {
    final idAlokasi = widget.idAlokasiRuang;
    final response = await http
        .get(Uri.parse('http://localhost:8080/dokumen-alokasi/$idAlokasi'));
    debugPrint("Id Alokasi : $idAlokasi");

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON.
      // Assuming the response is a JSON object containing details for AlokasiRuang.
      final Map<String, dynamic> json = jsonDecode(response.body);

      // Store the parsed AlokasiRuang object in dataDokumen
      setState(() {
        dataDokumen = AlokasiRuang.fromJson(json);
      });
    } else {
      // If the server does not return a 200 OK response, throw an error.
      throw Exception('Failed to load document allocation');
    }
  }

  Future<void> fetchListRuangProdi(String idAlokasiRuang) async {
    final url = "http://localhost:8080/dekan/ruang/detail/$idAlokasiRuang";
    loggerDetailRuang.info("Fetching List Jadwal $idAlokasiRuang URL: $url");


    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        loggerDetailRuang.info("Data fetched successfully");

        // Iterate over all prodi keys dynamically
        setState(() {
          ListRuangProdi.clear();  // Clear previous data
          data.forEach((prodi, jadwalList) {
            if (jadwalList is List) {
              // Assuming the list contains the jadwal data, map it
              ListRuangProdi.addAll(
                jadwalList.map((item) => Ruang.fromJson(item)).toList(),
              );
            }
          });
        });
    
        loggerDetailRuang.info("Status Code: ${response.statusCode}, jadwal fetched successfully.");
      } else {
        loggerDetailRuang.warning(
          "Failed to fetch jadwal. Status Code: ${response.statusCode}, Response: ${response.body}"
        );
      }
    } on FormatException catch (e) {
      loggerDetailRuang.severe("Invalid JSON format: $e");
    } on SocketException catch (e) {
      loggerDetailRuang.severe("Network error: $e");
    } catch (e) {
      loggerDetailRuang.severe("Unexpected error: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
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
                  margin: EdgeInsets.symmetric(vertical: 32),
                  child: Table(
                    columnWidths: const {
                      0: FractionColumnWidth(0.2),
                      1: FractionColumnWidth(0.8),
                    },
                    children: [
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ID Alokasi',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(':',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                dataDokumen?.idAlokasi ?? 'Belum tersedia',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Program Studi',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(':',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                dataDokumen?.namaProdi ?? 'Belum tersedia',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Id Semester',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(':',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(dataDokumen?.idSem ?? 'Belum tersedia',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Status',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(':',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(dataDokumen?.status ?? 'Belum tersedia',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(),
              Container(
                margin: EdgeInsets.only(top: 32),
                child: SingleChildScrollView(
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
                            'Kode Ruang',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Nama Ruang',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Gedung',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Lantai',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Fungsi',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Kapasitas',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: ListRuangProdi.map((ruang) {
                        return
                        DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              return Colors.white; // Apply row color
                            },
                          ),
                          cells: [
                          DataCell(Text(ruang.kodeRuang)),
                          DataCell(Text(ruang.namaRuang)),
                          DataCell(Text(ruang.gedung)),
                          DataCell(Text(ruang.lantai.toString())),
                          DataCell(Text(ruang.fungsi)),
                          DataCell(Text(ruang.kapasitas.toString())),
                        ]);
                      }).toList()
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}

class DetailRuangPageDataSource extends DataTableSource {
  final List<dynamic> ruangProdi;

  DetailRuangPageDataSource(this.ruangProdi);

  @override
  DataRow? getRow(int index) {
    if (index >= ruangProdi.length) return null;
    final ruang = ruangProdi[index];
    return DataRow(cells: [
      DataCell(Text(ruang.kodeRuang)),
      DataCell(Text(ruang.namaRuang)),
      DataCell(Text(ruang.gedung)),
      DataCell(Text(ruang.lantai.toString())),
      DataCell(Text(ruang.fungsi)),
      DataCell(Text(ruang.kapasitas.toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => ruangProdi.length;

  @override
  int get selectedRowCount => 0;
}
