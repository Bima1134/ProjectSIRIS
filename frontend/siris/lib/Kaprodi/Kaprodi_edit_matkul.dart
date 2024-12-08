import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditMatkulPage extends StatefulWidget {
  final String KodeMK;
  final String NamaMK;
  final int SKS;
  final String Status;
  final int Semester;
  final String NamaProdi;

  EditMatkulPage({
    required this.KodeMK,
    required this.NamaMK,
    required this.SKS,
    required this.Status,
    required this.Semester,
    required this.NamaProdi,
  });

  @override
  _EditMatkulPageState createState() => _EditMatkulPageState();
}

class _EditMatkulPageState extends State<EditMatkulPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController KodeMKController;
  late TextEditingController NamaMKController;
  late TextEditingController SKSController;
  late TextEditingController SemesterController;
  late TextEditingController NamaProdiController;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    KodeMKController = TextEditingController(text: widget.KodeMK);
    NamaMKController = TextEditingController(text: widget.NamaMK);
    SKSController = TextEditingController(text: widget.SKS.toString());
    SemesterController = TextEditingController(text: widget.Semester.toString());
    NamaProdiController = TextEditingController(text: widget.NamaProdi);
    selectedStatus = widget.Status;
  }

  Future<void> saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final requestBody = json.encode({
        'kode_mk': KodeMKController.text,
        'nama_mk': NamaMKController.text,
        'sks': int.tryParse(SKSController.text) ?? 0,
        'status': selectedStatus,
        'semester': int.tryParse(SemesterController.text) ?? 0,
        'prodi': NamaProdiController.text,
      });

      debugPrint('Request Body: $requestBody');

      try {
        final response = await http.put(
          Uri.parse('http://localhost:8080/kaprodi/update-matkul/${widget.KodeMK}'),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        debugPrint('Response Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data updated successfully')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update data')),
          );
        }
      } catch (error) {
        debugPrint('Error occurred: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Mata Kuliah'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Center(
                      child: Text(
                        "Form Edit Mata Kuliah",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: KodeMKController,
                      decoration: InputDecoration(labelText: 'Kode Mata Kuliah'),
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: NamaMKController,
                      decoration: InputDecoration(labelText: 'Nama Mata Kuliah'),
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: SKSController,
                      decoration: InputDecoration(labelText: 'SKS'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(labelText: 'Status'),
                      items: ['Wajib', 'Pilihan']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                      validator: (value) => value == null ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: SemesterController,
                      decoration: InputDecoration(labelText: 'Semester'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: NamaProdiController,
                      decoration: InputDecoration(labelText: 'Nama Program Studi'),
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: saveChanges,
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
