import 'dart:convert';
// import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:siris/BA/BA_alokasi_page.dart';
import 'package:siris/class/indexClass.dart';
import 'package:siris/navbar.dart';

class ListAlokasiPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  ListAlokasiPage({super.key, required this.userData});
  @override
  ListAlokasiPageState createState() => ListAlokasiPageState();
}

class ListAlokasiPageState extends State<ListAlokasiPage> {
  get userData => widget.userData;
  String? selectedValue;
  List<String> idsemPosisiList = []; // List to store the dropdown options
  List<AlokasiRuang> DataAlokasi = [];  // Holds the data to be displayed in the table

  @override
  void initState() {
    super.initState();  // Default selection
    fetchIdsemPosisi(); // Fetch the list when the page is loaded
  }

  // Function to fetch idsem and posisi data from the backend
  Future<void> fetchIdsemPosisi() async {
    final response = await http.get(Uri.parse('http://localhost:8080/semester')); // Replace with your actual API URL

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        idsemPosisiList = data.map((item) => '${item['idsem']} - ${item['posisi']}').toList();
        if (idsemPosisiList.isNotEmpty) {
          selectedValue = idsemPosisiList.last;  // Set default selection after data is loaded
          String? idsem = selectedValue?.split(' - ')[0];  // Extract idsem
          if (idsem != null) {
            fetchAlokasiData(idsem); // Trigger the fetch immediately after setting selectedValue
          }
        }
      });
    } else {
      throw Exception('Failed to load idsem and posisi');
    }
  }

Future<void> fetchAlokasiData(String idsem) async {

  try {
    final response = await http.get(Uri.parse('http://localhost:8080/data-alokasi/$idsem'));

    print('Request sent to: http://localhost:8080/data-alokasi/$idsem'); // Log URL

    if (response.statusCode == 200) {
      List<dynamic> fetchedData = json.decode(response.body);
      print('Response data: $fetchedData'); // Log response

      setState(() {
        DataAlokasi = fetchedData.map((item) {
          return AlokasiRuang.fromJson(item);
        }).toList();
      });
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      setState(() {
      });
    }
  } catch (error) {
    print('Error fetching data: $error');  // Catch any network errors
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false, 
      //   backgroundColor: const Color(0xFF162953), // Set the AppBar background color
      //   title: Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
      //     child: Row (
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         // Title Section
      //         Row(
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             const Text(
      //               'SIRIS',
      //               style: TextStyle(
      //                 fontSize: 36,
      //                 fontWeight: FontWeight.bold,
      //                 color: Colors.white,
      //               ),
      //             ),

      //             const SizedBox(width: 8),

      //             const Text(
      //               'Sistem Informasi Isian Rencana Studi',
      //               style: TextStyle(
      //                 fontSize: 20,
      //                 fontWeight: FontWeight.bold,
      //                 color: Colors.white,
      //               ),
      //             ),
      //           ],
      //         ),
              
      //         // Actions Section
      //         Row(
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             GestureDetector(
      //                     child: _buildMenuItem(Icons.book, 'IRS'),
      //                   ),
                  
      //             const SizedBox(width: 16),
      //               GestureDetector(
      //                     child: _buildMenuItem(Icons.schedule, 'Jadwal'),
      //                   ),
      //             const SizedBox(width: 16),
      //             _buildMenuItem(Icons.settings, 'Setting'),
      //             const SizedBox(width: 16),
      //             _buildLogoutButton(),
      //           ],
      //         ),
      //       ],
      //     ),
      //   )
      // ),
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
                        margin: EdgeInsets.only(top: 32, bottom: 40),
                        child: Text(
                                'Daftar Alokasi Ruang',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold
                                ),
                              )
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            idsemPosisiList.isEmpty
                                ? const CircularProgressIndicator() // Show loading while fetching data
                                : DropdownButton<String>(
                                    value: selectedValue,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedValue = newValue;
                                        String? idsem = selectedValue?.split(' - ')[0]; // Safe access
                                        if (idsem != null) {
                                          print('Selected idsem: $idsem'); // Log the extracted idsem
                                          fetchAlokasiData(idsem); // Pass the idsem to the fetch function
                                        } else {
                                          print('Selected value is null'); // Handle the case where selectedValue is null
                                        }
                                      });
                                    },
                                    items: idsemPosisiList
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value.split(" - ")[1]),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                  Container(
                child:
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                          child: DataTable(
                            columnSpacing: 16.0,
                            headingRowColor: WidgetStateProperty.resolveWith(
                              (states) => const Color(0xFF162953),
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Id Alokasi',
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
                            rows: DataAlokasi.map((alokasi) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(alokasi.idAlokasi)),
                                  DataCell(Text(alokasi.namaProdi)),
                                  DataCell(Text(alokasi.status)),
                                  DataCell(
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      onPressed: () {
                                        // Handle button press
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AlokasiPage(alokasi : alokasi, userData: userData),
                                          )
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          // Icon(Icons.details, color: Colors.white),
                                          // SizedBox(width: 8),
                                          Text(
                                            'Detail',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
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



