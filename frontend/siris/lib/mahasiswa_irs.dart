import 'package:flutter/material.dart';

void main() {
  runApp(const IRSPage());
}


class IRSPage extends StatelessWidget {
  const IRSPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                          onTap: () {
                            // Navigate to Jadwal page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IRSPage(),
                              )
                            );
                          },
                          child: _buildMenuItem(Icons.book, 'IRS'),
                        ),
                  
                  const SizedBox(width: 16),
                    GestureDetector(
                          // onTap: () {
                          //   // Navigate to Jadwal page
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => JadwalPage(userData: userData),
                          //     )
                          //   );
                          // },
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Row Above the Table
                Container(
                  margin: EdgeInsets.only(top: 32),
                  child: Text(
                          'Isian Rencana Studi',
                           style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold
                          ),
                        )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 32), // Background color for the row
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                       DropdownSelection(),
                      _buildEditButton()
                    ],
                  ),
                ),
                // Horizontal Scrolling Table
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 100),
                  child: Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        columnSpacing: 16.0, // Adjust spacing between columns
                        headingRowColor: MaterialStateProperty.resolveWith(
                          (states) => const Color(0xFF162953),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Age',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Role',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: const [
                          DataRow(cells: [
                            DataCell(Text('Alice')),
                            DataCell(Text('23')),
                            DataCell(Text('Developer')),
                            DataCell(Text('Alice')),
                            DataCell(Text('23')),
                            DataCell(Text('Developer')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Bob')),
                            DataCell(Text('30')),
                            DataCell(Text('Designer')),
                            DataCell(Text('Alice')),
                            DataCell(Text('23')),
                            DataCell(Text('Developer')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Charlie')),
                            DataCell(Text('25')),
                            DataCell(Text('Manager')),
                            DataCell(Text('Alice')),
                            DataCell(Text('23')),
                            DataCell(Text('Developer')),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

  Widget _buildEditButton(){
    return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Button background color
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
                  Icons.edit, // Edit icon
                  color: Colors.white,
                ),
                SizedBox(width: 8), // Space between icon and text
                Text(
                  'Edit IRS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
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

class DropdownSelection extends StatefulWidget {
  const DropdownSelection({Key? key}) : super(key: key);

  @override
  _DropdownSelectionState createState() => _DropdownSelectionState();
}

class _DropdownSelectionState extends State<DropdownSelection> {
  // Define a list of options
  final List<String> items = ['Semester 1', 'Semester 2', 'Semester 3', 'Semester 4'];

  // Define the initial value
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedItem,
      hint: const Text('Pilih Semester'),
      isExpanded: false, 
      menuWidth: 240,
      icon: const Icon(Icons.arrow_drop_down),
      underline: Container(
        height: 2,
        color: Colors.blue,
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedItem = newValue; // Update the selected value
        });
      },
    );
  }
}