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
  JadwalProdi? dataDokumen;
  List<dynamic> ListJadwalProdi = [];

  @override
  void initState(){
    super.initState();
    fetchDocumentJadwal();
    fetchListJadwalProdi(idJadwalProdi);
  }

    Future<void> fetchDocumentJadwal() async {
    final idJadwal = widget.idJadwalProdi;
    final response = await http
        .get(Uri.parse('http://localhost:8080/dokumen-jadwal/$idJadwal'));
    debugPrint("Id Alokasi : $idJadwal");

    if (response.statusCode == 200) {
      // If the server returns a successful response, parse the JSON.
      // Assuming the response is a JSON object containing details for JadwalProdi.
      final Map<String, dynamic> json = jsonDecode(response.body);

      // Store the parsed JadwalProdi object in dataDokumen
      setState(() {
        dataDokumen = JadwalProdi.fromJson(json);
      });
    } else {
      // If the server does not return a 200 OK response, throw an error.
      throw Exception('Failed to load document allocation');
    }
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
                                dataDokumen?.idJadwal ?? 'Belum tersedia',
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
                child:
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
                      rows: ListJadwalProdi.map((jadwal) {
                        String dosenPengampu = jadwal.DosenPengampu.join(', '); // Gabungkan elemen List menjadi String
                        String Waktu = "${jadwal.Hari}, ${jadwal.JamMulai} - ${jadwal.JamSelesai}";
                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              return Colors.white; // Apply row color
                            },
                          ),
                          cells: [
                          DataCell(Text(jadwal.idJadwal.toString())),
                          DataCell(Text(jadwal.KodeMK)),
                          DataCell(Text(jadwal.NamaMK)),
                          DataCell(Text(jadwal.Ruangan)),
                          DataCell(Text(Waktu)),
                          DataCell(Text(jadwal.Kelas)),
                          DataCell(Text(jadwal.SKS.toString())),
                          DataCell(Text(dosenPengampu))
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

class DetailJadwalDataSource extends DataTableSource {
  final List<dynamic> jadwalProdi;

  DetailJadwalDataSource(this.jadwalProdi);

  @override
  DataRow? getRow(int index) {
    if (index >= jadwalProdi.length) return null;
    final jadwal = jadwalProdi[index];
    String dosenPengampu = jadwal.DosenPengampu.join(', '); // Gabungkan elemen List menjadi String
    String Waktu = "${jadwal.Hari}, ${jadwal.JamMulai} - ${jadwal.JamSelesai}";
    return DataRow.byIndex(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return Colors.white; // Apply row color
        },
      ),
      cells: [
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
