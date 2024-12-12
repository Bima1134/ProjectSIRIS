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
  List<dynamic> ListJadwalProdi = [];

  @override
  void initState(){
    super.initState();
    fetchListRuangProdi(idAlokasiRuang);
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
          ListJadwalProdi.clear();  // Clear previous data
          data.forEach((prodi, jadwalList) {
            if (jadwalList is List) {
              // Assuming the list contains the jadwal data, map it
              ListJadwalProdi.addAll(
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
                margin: EdgeInsets.only(top: 32, bottom: 40),
                child: Text(
                          'Daftar Ruang',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold
                          ),
                        )
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
                    source: DetailRuangPageDataSource(ListJadwalProdi)
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
