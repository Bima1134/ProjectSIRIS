import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siris/Kaprodi/Kaprodi_AddJadwal.dart';
import 'package:siris/class/MataKuliah.dart';
import 'package:siris/class/Ruang.dart';

class EditJadwalPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String jadwalID;
  final String kodeMk;
  final String hari;
  final String jamMulai;
  final String jamSelesai;
  final String kelas;
  final String ruangan;
  final int sks;

  EditJadwalPage(
      {required this.userData,
      required this.jadwalID,
      required this.kodeMk,
      required this.hari,
      required this.jamMulai,
      required this.jamSelesai,
      required this.kelas,
      required this.ruangan,
      required this.sks});

  @override
  _EditJadwalPageState createState() => _EditJadwalPageState();
}

class _EditJadwalPageState extends State<EditJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  get userData => widget.userData;

  // Controllers
  late TextEditingController kelasController;
  late TextEditingController jamMulaiController;
  late TextEditingController jamSelesaiController;

  // Dropdown selections
  String? selectedKodeMK;
  String? selectedKodeRuangan;
  String? selectedHari;

  // Dropdown lists
  List<MataKuliah> mataKuliahList = [];
  List<Ruang> ruangList = [];

  @override
  void initState() {
    super.initState();
    selectedKodeMK = widget.kodeMk;
    selectedKodeRuangan = widget.ruangan;
    selectedHari = widget.hari;

    // Initialize controllers
    kelasController = TextEditingController(text: widget.kelas);
    jamMulaiController = TextEditingController(text: widget.jamMulai);
    jamSelesaiController = TextEditingController(text: widget.jamSelesai);

    // Fetch dropdown data
    fetchMatakuliah();
    fetchRuangData();
    final sks = widget.sks;
    debugPrint("Sks $sks");
  }

  Future<void> fetchMatakuliah() async {
    final url =
        'http://localhost:8080/kaprodi/mata-kuliah/${widget.userData['nama_prodi']}';
    final response = await http.get(Uri.parse(url));
    loggerAddJadwal.info("Fetching Mata Kuliah URL: $url");
    if (response.statusCode == 200) {
      try {
        // Mengambil data JSON dari response
        List<dynamic> data = json.decode(response.body);

        // Konversi List<dynamic> menjadi List<MataKuliah>
        setState(() {
          mataKuliahList =
              data.map((item) => MataKuliah.fromJson(item)).toList();
        });
      } catch (e) {
        throw Exception('Error fetching mata kuliah: $e');
      }
    } else {
      throw Exception(
          'Failed to load mata kuliah. Status code: ${response.statusCode}');
    }
  }

  Future<void> saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final requestBody = json.encode({
        'jadwal_id': widget.jadwalID,
        'kode_mk': selectedKodeMK,
        'kode_ruang': selectedKodeRuangan,
        'hari': selectedHari,
        'jam_mulai': jamMulaiController.text,
        'jam_selesai': jamSelesaiController.text,
        'kelas': kelasController.text,
      });

      try {
        final jadwal_id = widget.jadwalID;
        debugPrint("jadwalid : $jadwal_id");
        final response = await http.put(
          Uri.parse('http://localhost:8080/kaprodi/edit-jadwal/$jadwal_id'),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jadwal updated successfully')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update jadwal')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  Future<void> fetchRuangData() async {
    try {
      final prodi = widget.userData['nama_prodi'];
      final response = await http.get(
          Uri.parse('http://localhost:8080/kaprodi/get-ruang-by-prodi/$prodi'));
      debugPrint(
          'Fetching data from: http://localhost:8080/kaprodi/get-ruang-by-prodi/${userData['nama_prodi']}');

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            final data = json.decode(response.body);
            debugPrint("Data : $data");
            if (data is List) {
              setState(() {
                ruangList = data.map((item) => Ruang.fromJson(item)).toList();
              });
            } else {
              setState(() {
                ruangList = []; // Default to empty list if data is not a list
              });
              debugPrint('Unexpected data format');
            }
          } catch (e) {
            debugPrint('Error decoding JSON: $e');
            setState(() {
              ruangList = []; // Default to empty list if decoding fails
            });
          }
        } else {
          setState(() {
            ruangList = []; // Default to empty list if body is empty
          });
          debugPrint('Response body is empty');
        }
      } else {
        debugPrint('Failed to fetch data. Status code: ${response.statusCode}');
        setState(() {
          ruangList = []; // Default to empty list on error
        });
      }
    } catch (e) {
      debugPrint('Error during HTTP request: $e');
      setState(() {
        ruangList = []; // Default to empty list on exception
      });
    }
  }

  // Fungsi memilih waktu
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);

        // Jika memilih jam mulai, otomatis hitung jam selesai
        if (controller == jamMulaiController) {
          final int totalMinutes =
              widget.sks * 50; // Total menit berdasarkan SKS
          final sks = widget.sks;
          debugPrint("Sks $sks");
          final TimeOfDay jamMulai = picked;

          // Hitung waktu selesai
          final TimeOfDay jamSelesai = TimeOfDay(
            hour: (jamMulai.hour + (totalMinutes ~/ 60)) % 24,
            minute: (jamMulai.minute + totalMinutes % 60) % 60,
          );

          // Set teks pada controller jam selesai
          jamSelesaiController.text = jamSelesai.format(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Jadwal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Dropdown for kode_mk
            DropdownButtonFormField<String>(
              value: selectedKodeMK,
              items: mataKuliahList.map((kodeMK) {
                return DropdownMenuItem<String>(
                  value: kodeMK.kodeMk,
                  child: Text(kodeMK.kodeMk),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Kode Mata Kuliah'),
              onChanged: (value) {
                setState(() {
                  selectedKodeMK = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Pilih kode mata kuliah' : null,
            ),

            SizedBox(height: 8),

            // Dropdown for kode_ruang
            DropdownButtonFormField<String>(
              value: selectedKodeRuangan,
              items: ruangList.map((kodeRuangan) {
                return DropdownMenuItem<String>(
                  value: kodeRuangan.kodeRuang,
                  child: Text(kodeRuangan.kodeRuang),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Kode Ruangan'),
              onChanged: (value) {
                setState(() {
                  selectedKodeRuangan = value;
                });
                debugPrint("value $value");
                debugPrint("seleckoderuang $selectedKodeRuangan");
              },
              validator: (value) => value == null ? 'Pilih kode ruangan' : null,
            ),

            SizedBox(height: 8),
            // hari
            DropdownButtonFormField<String>(
              value: selectedHari,
              hint: Text('Pilih Hari'),
              items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat']
                  .map((hari) => DropdownMenuItem(
                        value: hari,
                        child: Text(hari),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedHari = value!;
                });
              },
              validator: (value) => value == null ? 'Pilih Hari' : null,
            ),

            // Jam Mulai
            TextFormField(
              controller: jamMulaiController,
              decoration: const InputDecoration(labelText: 'Jam Mulai'),
              readOnly: true,
              onTap: () => _selectTime(context, jamMulaiController),
              validator: (value) => value!.isEmpty ? 'Pilih jam mulai' : null,
            ),

            const SizedBox(height: 8),

            // Jam Selesai
            TextFormField(
              controller: jamSelesaiController,
              decoration: const InputDecoration(labelText: 'Jam Selesai'),
              readOnly: true,
              validator: (value) => value!.isEmpty ? 'Pilih jam selesai' : null,
            ),

            SizedBox(height: 8),

            // Input for kelas
            TextFormField(
              controller: kelasController,
              decoration: InputDecoration(labelText: 'Kelas'),
              validator: (value) =>
                  value!.isEmpty ? 'Field tidak boleh kosong' : null,
            ),

            SizedBox(height: 20),

            // Save button
            ElevatedButton(
              onPressed: saveChanges,
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
