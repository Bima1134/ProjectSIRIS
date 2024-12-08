import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MataKuliah {
  final String KodeMK;
  final String NamaMK;
  final int SKS;
  final String Status;
  final int Semester;
  final String NamaProdi;

  MataKuliah({
    required this.KodeMK,
    required this.NamaMK,
    required this.SKS,
    required this.Status,
    required this.Semester,
    required this.NamaProdi,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      KodeMK: json['kode_mk'],
      NamaMK: json['nama_mk'],
      SKS: json['sks'],
      Status: json['status'],
      Semester: json['semester'],
      NamaProdi: json['prodi'],
    );
  }
}

class AddMatkulPage extends StatefulWidget {
  final VoidCallback onMatkulAdded;

  AddMatkulPage({required this.onMatkulAdded});

  @override
  _AddMatkulPageState createState() => _AddMatkulPageState();
}

class _AddMatkulPageState extends State<AddMatkulPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController KodeMKController;
  late TextEditingController NamaMKController;
  late TextEditingController SKSController;
  late TextEditingController SemesterController;
  late TextEditingController NamaProdiController;
  String? selectedStatus;

  bool isKodeMatkulDuplicate = false;

  @override
  void initState() {
    super.initState();
    KodeMKController = TextEditingController();
    NamaMKController = TextEditingController();
    SKSController = TextEditingController();
    SemesterController = TextEditingController();
    NamaProdiController = TextEditingController();
  }

  Future<void> fetchMatkulData() async {
    final response = await http.get(Uri.parse('http://localhost:8080/kaprodi/get-matkul'));

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        try {
          final data = json.decode(response.body);
          if (data is List) {
            setState(() {
              isKodeMatkulDuplicate = data.any((item) =>
                  MataKuliah.fromJson(item).KodeMK.toLowerCase() == KodeMKController.text.toLowerCase());
            });
          } else {
            setState(() {
              isKodeMatkulDuplicate = false; // Default if response is not a list
            });
            debugPrint('Unexpected data format');
          }
        } catch (e) {
          debugPrint('Error decoding JSON: $e');
          setState(() {
            isKodeMatkulDuplicate = false; // Default if decoding fails
          });
        }
      } else {
        setState(() {
          isKodeMatkulDuplicate = false; // Default if body is empty
        });
      }
    } else {
      debugPrint('Failed to fetch data. Status code: ${response.statusCode}');
      setState(() {
        isKodeMatkulDuplicate = false; // Default on failed fetch
      });
    }
  }

  Future<void> saveMatkul() async {
    if (_formKey.currentState!.validate()) {
      await fetchMatkulData();

      if (isKodeMatkulDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This course already exists!')),
        );
        return; // Don't proceed with saving
      }

      final payload = {
        'kode_mk': KodeMKController.text,
        'nama_mk': NamaMKController.text,
        'sks': int.parse(SKSController.text),
        'status': selectedStatus,
        'semester': int.parse(SemesterController.text),
        'prodi': NamaProdiController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('http://localhost:8080/kaprodi/upload-matkul-single'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Course added successfully')),
          );
          widget.onMatkulAdded();
          Navigator.pop(context, true); // Return to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add course: ${response.body}')),
          );
        }
      } catch (e) {
        print('Error occurred while adding matkul: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    KodeMKController.dispose();
    NamaMKController.dispose();
    SKSController.dispose();
    SemesterController.dispose();
    NamaProdiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Center(
                      child: Text(
                        "Form Tambah Mata Kuliah",
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
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: NamaMKController,
                      decoration: InputDecoration(labelText: 'Nama Mata Kuliah'),
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: SKSController,
                      decoration: InputDecoration(labelText: 'SKS'),
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Status'),
                      value: selectedStatus,
                      items: [
                        DropdownMenuItem(
                          value: 'Wajib',
                          child: Text('Wajib'),
                        ),
                        DropdownMenuItem(
                          value: 'Pilihan',
                          child: Text('Pilihan'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a status' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: SemesterController,
                      decoration: InputDecoration(labelText: 'Semester'),
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: NamaProdiController,
                      decoration: InputDecoration(labelText: 'Prodi'),
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
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
                      onPressed: saveMatkul,
                      child: const Text(
                        'Simpan',
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
