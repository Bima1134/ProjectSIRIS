import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:siris/navbar.dart';
import '../class/indexClass.dart';
import 'dart:convert';
import 'dart:io';

final loggerDetailJadwal = Logger('DetailJadwalPage');

class DetailJadwalPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String idJadwalProdi;

  @override
  DetailJadwalPageState createState() => DetailJadwalPageState();

  const DetailJadwalPage({super.key, required this.userData, required this.idJadwalProdi});
}

class DetailJadwalPageState extends State<DetailJadwalPage>{
  get userData => widget.userData;
  get idJadwalProdi => widget.idJadwalProdi;
  List<dynamic> ListJadwalProdi = [];

  @override
  void initState(){
    super.initState();
    fetchListJadwalProdi(idJadwalProdi);
  }

  Future<void> fetchListJadwalProdi(String idJadwalProdi) async {
    final url = "http://localhost:8080/dekan/jadwal/detail/$idJadwalProdi";
    loggerDetailJadwal.info("Fetching List Jadwal $idJadwalProdi URL: $url");


    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        loggerDetailJadwal.info("Data fetched successfully");

        // Iterate over all prodi keys dynamically
        setState(() {
          ListJadwalProdi.clear();  // Clear previous data
          data.forEach((prodi, jadwalList) {
            if (jadwalList is List) {
              // Assuming the list contains the jadwal data, map it
              ListJadwalProdi.addAll(
                jadwalList.map((item) => Jadwal.fromJson(item)).toList(),
              );
            }
          });
        });
    
        loggerDetailJadwal.info("Status Code: ${response.statusCode}, jadwal fetched successfully.");
      } else {
        loggerDetailJadwal.warning(
          "Failed to fetch jadwal. Status Code: ${response.statusCode}, Response: ${response.body}"
        );
      }
    } on FormatException catch (e) {
      loggerDetailJadwal.severe("Invalid JSON format: $e");
    } on SocketException catch (e) {
      loggerDetailJadwal.severe("Network error: $e");
    } catch (e) {
      loggerDetailJadwal.severe("Unexpected error: $e");
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
                          'Daftar Jadwal',
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
                      (states) => const Color(0xFF162953),
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
                          'Kode Mata Kuliah',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nama Mata Kuliah',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Ruang',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Waktu',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Kelas',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'SKS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),

                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Pengampu',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    source: DetailJadwalDataSource(ListJadwalProdi)
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

class DetailJadwalDataSource extends DataTableSource {
  final List<dynamic> jadwalProdi;

  DetailJadwalDataSource(this.jadwalProdi);

  @override
  DataRow? getRow(int index) {
    if (index >= jadwalProdi.length) return null;
    final jadwal = jadwalProdi[index];
    String dosenPengampu = jadwal.DosenPengampu.join(', '); // Gabungkan elemen List menjadi String
    String Waktu = "${jadwal.Hari}, ${jadwal.JamMulai} - ${jadwal.JamSelesai}";
    return DataRow(cells: [
      DataCell(Text(jadwal.idJadwal)),
      DataCell(Text(jadwal.KodeMK)),
      DataCell(Text(jadwal.NamaMK)),
      DataCell(Text(jadwal.Ruangan)),
      DataCell(Text(Waktu)),
      DataCell(Text(jadwal.Kelas)),
      DataCell(Text(jadwal.SKS.toString())),
      DataCell(Text(dosenPengampu))
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => jadwalProdi.length;

  @override
  int get selectedRowCount => 0;
}
