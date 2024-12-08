import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siris/class/Ruang.dart';

class AddRuangPage extends StatefulWidget {
  final VoidCallback onRoomAdded;
  AddRuangPage({required this.onRoomAdded});
  @override
  _AddRuangPageState createState() => _AddRuangPageState();
}

class _AddRuangPageState extends State<AddRuangPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController kodeRuangController;
  late TextEditingController namaRuangController;
  late TextEditingController gedungController;
  late TextEditingController lantaiController;
  late TextEditingController fungsiController;
  late TextEditingController kapasitasController;

  bool isKodeRuangDuplicate = false;

  @override
  void initState() {
    super.initState();
    kodeRuangController = TextEditingController();
    namaRuangController = TextEditingController();
    gedungController = TextEditingController();
    lantaiController = TextEditingController();
    fungsiController = TextEditingController();
    kapasitasController = TextEditingController();
  }
Future<void> fetchRuangData() async {
  final response = await http.get(Uri.parse('http://localhost:8080/ruang'));

  if (response.statusCode == 200) {
    if (response.body.isNotEmpty) {
      try {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            isKodeRuangDuplicate = data.any((item) =>
                Ruang.fromJson(item).kodeRuang.toLowerCase() == kodeRuangController.text.toLowerCase());
          });
        } else {
          setState(() {
            isKodeRuangDuplicate = false; // Default if response is not a list
          });
          print('Unexpected data format');
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        setState(() {
          isKodeRuangDuplicate = false; // Default if decoding fails
        });
      }
    } else {
      setState(() {
        isKodeRuangDuplicate = false; // Default if body is empty
      });
    }
  } else {
    print('Failed to fetch data. Status code: ${response.statusCode}');
    setState(() {
      isKodeRuangDuplicate = false; // Default on failed fetch
    });
  }
}


  Future<void> saveRoom() async {
    if (_formKey.currentState!.validate()) {
      await fetchRuangData(); 
      // Perform the API call to save changes

       if (isKodeRuangDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This room name already exists!')),
        );
        return; // Don't proceed with saving
      }
      final response = await http.post(
        Uri.parse('http://localhost:8080/upload-single'), // Assuming `id` is the unique identifier
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
          SnackBar(content: Text('Room added successfully')),
        );
        widget.onRoomAdded();
        Navigator.pop(context, true); // Return to the previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add room')),
        );
      }
    }
  }

  @override
  // free memory
  void dispose() {
    kodeRuangController.dispose();
    namaRuangController.dispose();
    gedungController.dispose();
    lantaiController.dispose();
    fungsiController.dispose();
    kapasitasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.grey[200], // Background color for the body
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Card background color
                borderRadius: BorderRadius.circular(16.0), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26, // Shadow color
                    blurRadius: 8.0, // Softness of the shadow
                    offset: Offset(0, 4), // Position of the shadow
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true, // Ensures the form is only as tall as its content
                  children: [
                    Center(
                      child: Text(
                        "Form Tambah Ruang",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w800, // Semi-bold
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    TextFormField(
                      controller: kodeRuangController,
                      decoration: InputDecoration(labelText: 'Kode Ruang'),
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: namaRuangController,
                      decoration: InputDecoration(labelText: 'Nama Ruang'),
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: gedungController,
                      decoration: InputDecoration(labelText: 'Gedung'),
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: lantaiController,
                      decoration: InputDecoration(labelText: 'Lantai'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: fungsiController,
                      decoration: InputDecoration(labelText: 'Fungsi'),
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: kapasitasController,
                      decoration: InputDecoration(labelText: 'Kapasitas'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Field cannot be empty' : null,
                    ),
                    SizedBox(height: 20),
                    // ElevatedButton(
                    //   onPressed: saveRoom,
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
                          onPressed: saveRoom,
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
