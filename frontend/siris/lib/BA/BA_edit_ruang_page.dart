import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditRuangPage extends StatefulWidget {
  final String kodeRuang;
  final String namaRuang;
  final String gedung;
  final int lantai;
  final String fungsi;
  final int kapasitas;

  EditRuangPage({
    required this.kodeRuang,
    required this.namaRuang,
    required this.gedung,
    required this.lantai,
    required this.fungsi,
    required this.kapasitas,
  });

  @override
  _EditRuangPageState createState() => _EditRuangPageState();
}

class _EditRuangPageState extends State<EditRuangPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController kodeRuangController;
  late TextEditingController namaRuangController;
  late TextEditingController gedungController;
  late TextEditingController lantaiController;
  late TextEditingController fungsiController;
  late TextEditingController kapasitasController;

  @override
  void initState() {
    super.initState();
    kodeRuangController = TextEditingController(text: widget.kodeRuang);
    namaRuangController = TextEditingController(text: widget.namaRuang);
    gedungController = TextEditingController(text: widget.gedung);
    lantaiController = TextEditingController(text: widget.lantai.toString());
    fungsiController = TextEditingController(text: widget.fungsi);
    kapasitasController = TextEditingController(text: widget.kapasitas.toString());
  }

Future<void> saveChanges() async {
  if (_formKey.currentState!.validate()) {
    // Cetak data yang akan dikirim
    final requestBody = json.encode({
      'kode_ruang': kodeRuangController.text,
      'nama_ruang': namaRuangController.text,
      'gedung': gedungController.text,
      'lantai': int.tryParse(lantaiController.text) ?? 0, // Antisipasi error parsing
      'fungsi': fungsiController.text,
      'kapasitas': int.tryParse(kapasitasController.text) ?? 0, // Antisipasi error parsing
    });

    print('Request Body: $requestBody'); // Log request body

    try {
      // Melakukan panggilan API
      final response = await http.put(
        Uri.parse('http://localhost:8080/ruang/${widget.kodeRuang}'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      // Log respons server
      debugPrint('Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully')),
        );
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update data')),
        );
      }
    } catch (error) {
      // Tangkap dan log error
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
        // title: Text('Edit Ruang'),
      ),
      body: Container(
        color: Colors.grey[200], // Light gray background
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // White card background
                borderRadius: BorderRadius.circular(24.0), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // Shadow color
                    blurRadius: 8.0, // Shadow blur
                    offset: Offset(0, 4), // Shadow position
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true, // Adjust height to content
                  children: [
                    Center(
                      child: Text(
                        "Form Edit Ruang",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800, // Semi-bold font
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: kodeRuangController,
                      decoration: InputDecoration(labelText: 'Kode Ruang'),
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: namaRuangController,
                      decoration: InputDecoration(labelText: 'Nama Ruang'),
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: gedungController,
                      decoration: InputDecoration(labelText: 'Gedung'),
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: lantaiController,
                      decoration: InputDecoration(labelText: 'Lantai'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: fungsiController,
                      decoration: InputDecoration(labelText: 'Fungsi'),
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: kapasitasController,
                      decoration: InputDecoration(labelText: 'Kapasitas'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 20),
                    // ElevatedButton(
                    //   onPressed: saveChanges,
                    //   child: Text('Save Changes'),
                    // ),
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
