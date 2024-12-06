import 'dart:convert';
// import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:siris/BA/BA_list_alokasi_page.dart';

class Ruang {
  final String kodeRuang;
  final String namaRuang;
  final String gedung;
  final int lantai;
  final String fungsi;
  final int kapasitas;

  Ruang({
    required this.kodeRuang,
    required this.namaRuang,
    required this.gedung,
    required this.lantai,
    required this.fungsi,
    required this.kapasitas,
  });

  factory Ruang.fromJson(Map<String, dynamic> json) {
    return Ruang(
      kodeRuang: json['kode_ruang'],
      namaRuang: json['nama_ruang'],
      gedung: json['gedung'],
      lantai: json['lantai'],
      fungsi: json['fungsi'],
      kapasitas: json['kapasitas'],
    );
  }
}

class AlokasiPage extends StatefulWidget {


    final AlokasiRuang alokasi;

  AlokasiPage({required this.alokasi});
  @override
  _AlokasiPageState createState() => _AlokasiPageState();
  
  
}

class _AlokasiPageState extends State<AlokasiPage> {
    // Define a list of options for the dropdown
  // List<String> _dropdownItems = ['Pilih Ruang', 'Option 2', 'Option 3'];

  
  // Initialize the selected value
  Ruang? _selectedItem;
  AlokasiRuang? dataDokumen; 
  List<Ruang> ruangList = [];
  List<Ruang> ruangListAlokasi =[];
  // List<Ruang> selectedRuangList = [];

    @override
  void initState() {
    super.initState();
    // Set default value if you want to have one pre-selected
    _selectedItem = null; 
    fetchDocumentAlokasi();
    fetchRuangData(); 
    fetchRuangDataById(widget.alokasi.idAlokasi);
  }

// Variable to hold the fetched data (example: you can store it as a list or single object)


// Fetching the document allocation data from the API
Future<void> fetchDocumentAlokasi() async {
  final idAlokasi = widget.alokasi.idAlokasi;
  final response = await http.get(Uri.parse('http://localhost:8080/dokumen-alokasi/$idAlokasi'));
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

Future<void> fetchRuangData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/ruang'));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            if (data is List) {
              setState(() {
                ruangList = data.map((item) => Ruang.fromJson(item)).toList();
                // updatePaginatedData(); // Update paginated data after fetching
              });
            } else {
              setState(() {
                ruangList = []; // Default to empty list if data is not a list
              });
              print('Unexpected data format');
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            setState(() {
              ruangList = []; // Default to empty list if decoding fails
            });
          }
        } else {
          setState(() {
            ruangList = []; // Default to empty list if body is empty
          });
          print('Response body is empty');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        setState(() {
          ruangList = []; // Default to empty list on error
        });
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      setState(() {
        ruangList = []; // Default to empty list on exception
      });
    }
  }

  Future<void> addRuangToAlokasi(String idAlokasi, String kodeRuang) async {
    // Membuat URL untuk API
    final String url = 'http://localhost:8080/add-ruang-alokasi/$idAlokasi?kodeRuang=$kodeRuang';
    debugPrint("idalokasi $idAlokasi, koderuang : $kodeRuang");
    try {
      // Mengirimkan request POST
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // Memeriksa status code dari response
      if (response.statusCode == 200) {
        // Jika sukses, parse respons JSON
        Map<String, dynamic> data = json.decode(response.body);
        print('Success: ${data['message']}');
      } else {
        // Jika terjadi error, tampilkan pesan error
        Map<String, dynamic> data = json.decode(response.body);
        print('Error: ${data['message']}');
      }
    } catch (e) {
      // Menangani error jika request gagal
      print('Error: Gagal menghubungi server. $e');
    }
  }



Future<void> fetchRuangDataById(String idAlokasi) async {
    try {
        final response = await http.get(Uri.parse('http://localhost:8080/get-ruang-alokasi/$idAlokasi'));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            if (data is List) {
              setState(() {
                ruangListAlokasi = data.map((item) => Ruang.fromJson(item)).toList();
                // updatePaginatedData(); // Update paginated data after fetching
              });
            } else {
              setState(() {
                ruangListAlokasi = []; // Default to empty list if data is not a list
              });
              print('Unexpected data format');
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            setState(() {
              ruangListAlokasi = []; // Default to empty list if decoding fails
            });
          }
        } else {
          setState(() {
            ruangListAlokasi = []; // Default to empty list if body is empty
          });
          print('Response body is empty');
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        setState(() {
          ruangListAlokasi = []; // Default to empty list on error
        });
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      setState(() {
        ruangListAlokasi = []; // Default to empty list on exception
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, 
        backgroundColor: const Color(0xFF162953), // Set the AppBar background color
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
          child: Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'SIRIS',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    'Sistem Informasi Isian Rencana Studi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              
              // Actions Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                          child: _buildMenuItem(Icons.book, 'IRS'),
                        ),
                  
                  const SizedBox(width: 16),
                    GestureDetector(
                          child: _buildMenuItem(Icons.schedule, 'Jadwal'),
                        ),
                  const SizedBox(width: 16),
                  _buildMenuItem(Icons.settings, 'Setting'),
                  const SizedBox(width: 16),
                  _buildLogoutButton(),
                ],
              ),
            ],
          ),
        )
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        color: Colors.grey[200],
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          margin: EdgeInsets.symmetric(vertical: 40),
          color: Colors.white,
          child:Column(
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
                                        Text('ID Alokasi', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(dataDokumen?.idAlokasi ?? 'Belum tersedia', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                        Text('Program Studi', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(dataDokumen?.namaProdi ?? 'Belum tersedia', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                        Text('Id Semester', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(dataDokumen?.idSem ?? 'Belum tersedia', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                        Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(dataDokumen?.status ?? 'Belum tersedia', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),

                      Divider(),
                          Center(
                            child: ruangList.isEmpty
    ? const Text("Tidak ada data ruang")
    : DropdownButton<Ruang>(
      hint: Text('Pilih Ruang'),
        value: _selectedItem,
        onChanged: (Ruang? newValue) {
          setState(() {
            _selectedItem = newValue;
          });
        },
        items: ruangList.map<DropdownMenuItem<Ruang>>((Ruang ruang) {
          return DropdownMenuItem<Ruang>(
            value: ruang,
            child: Text('${ruang.namaRuang} - ${ruang.fungsi}'),
          );
        }).toList(),
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
                                      onPressed: () async {
    // Ensure that a valid room is selected before calling the function
    if (_selectedItem != null) {
      // Calling the function to add the selected room to the allocation
      await addRuangToAlokasi(widget.alokasi.idAlokasi, _selectedItem!.kodeRuang);
      
      // Fetch the updated list of allocated rooms after adding the new room
      await fetchRuangDataById(widget.alokasi.idAlokasi);

      // Trigger a rebuild to update the UI with the new list of rooms
      setState(() {
        // You can also update other state variables here if needed
      });
    } else {
      // Show a message if no room is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a room first')),
      );
    }
  },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.add, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Add Ruang',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                  Container(
                    margin: EdgeInsets.only(top: 32),
                child:
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                          child: DataTable(
                            columnSpacing: 16.0,
                            headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => const Color(0xFF162953),
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
                                  'Kelas',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          rows: ruangListAlokasi.map<DataRow>((Ruang ruang) {
                          return DataRow(cells: [
                            DataCell(Text(ruang.kodeRuang)),
                            DataCell(Text(ruang.namaRuang)),
                            DataCell(Text(ruang.gedung)),
                            DataCell(Text(ruang.lantai.toString())),
                            DataCell(Text(ruang.fungsi)),
                            DataCell(Text(ruang.kapasitas.toString())),
                          ]);
                        }).toList(),
                          ),
                        ),
                      ),),
              ],
            ),
        ),
      )
    );
  }
}

Widget _buildMenuItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:18)),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle logout
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text('Logout', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }



