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
      // Perform the API call to save changes
      final response = await http.put(
        Uri.parse('http://localhost:8080/ruang/${widget.kodeRuang}'), // Assuming `id` is the unique identifier
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'kode_ruang': kodeRuangController.text,
          'nama_ruang': namaRuangController.text,
          'gedung': gedungController.text,
          'lantai': int.parse(lantaiController.text),
          'fungsi': fungsiController.text,
          'kapasitas': int.parse(kapasitasController.text),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully')),
        );
        Navigator.pop(context, true); // Return to the previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Ruang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: kodeRuangController,
                decoration: InputDecoration(labelText: 'Kode Ruang'),
                validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
              ),
              TextFormField(
                controller: namaRuangController,
                decoration: InputDecoration(labelText: 'Nama Ruang'),
                validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
              ),
              TextFormField(
                controller: gedungController,
                decoration: InputDecoration(labelText: 'Gedung'),
                validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
              ),
              TextFormField(
                controller: lantaiController,
                decoration: InputDecoration(labelText: 'Lantai'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
              ),
              TextFormField(
                controller: fungsiController,
                decoration: InputDecoration(labelText: 'Fungsi'),
                validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
              ),
              TextFormField(
                controller: kapasitasController,
                decoration: InputDecoration(labelText: 'Kapasitas'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
