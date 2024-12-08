import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:siris/class/MataKuliah.dart';
import 'package:siris/class/Ruang.dart';
import 'package:siris/navbar.dart';

final loggerAddJadwal = Logger('AddJadwalPage');

class AddJadwalPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const AddJadwalPage({super.key, required this.userData});


  @override
  _AddJadwalPageState createState() => _AddJadwalPageState();
}

class _AddJadwalPageState extends State<AddJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  get userData => widget.userData;
  String? selectedKodeMK;
  String? selectedRuangan;
  String? selectedHari;

  MataKuliah? selectedMataKuliah;

  List<MataKuliah> mataKuliahList = [];
  List<Ruang> ruangList = [];

  late TextEditingController namaMKController = TextEditingController();
  late TextEditingController semesterController = TextEditingController();
  late TextEditingController sksController = TextEditingController();
  late TextEditingController statusController = TextEditingController();
  late TextEditingController kelasController = TextEditingController();
  late TextEditingController kapasitasController = TextEditingController();
  late TextEditingController jamMulaiController = TextEditingController();
  late TextEditingController jamSelesaiController = TextEditingController();

  List<TextEditingController> dosenPengampuControllers = [];

  bool isKodeRuangDuplicate = false;

  @override
  void initState() {
    super.initState();
    fetchMatakuliah();
    fetchRuangData();
    namaMKController = TextEditingController();
    semesterController = TextEditingController();
    sksController = TextEditingController();
    statusController = TextEditingController();
    kelasController = TextEditingController();
    kapasitasController = TextEditingController();
    jamMulaiController = TextEditingController();
    jamSelesaiController = TextEditingController();
  }

  Future<void> fetchMatakuliah() async {
    final url = 'http://localhost:8080/kaprodi/mata-kuliah/${userData['nama_prodi']}';
    final response = await http
        .get(Uri.parse(url));
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

  // Method untuk memilih waktu
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // Konversi TimeOfDay ke format HH:MM:SS
      final now = DateTime.now();
      final formattedTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      ).toIso8601String().substring(11, 19); // Ambil hanya HH:MM:SS

      // Set waktu ke controller
      controller.text = formattedTime;
    }
  }

  // Fetch ruang data from the backend
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

  Future<void> addJadwal() async {
    final url = 'http://localhost:8080/kaprodi/add-jadwal/20241/${userData['nama_prodi']}';
    loggerAddJadwal.info("Adding Jadwal URL: $url");
    // Data yang akan dikirimkan
    final data = {
      'kodeMK': selectedKodeMK,
      'kelas': kelasController.text,
      'kodeRuang': selectedRuangan,
      'hari': selectedHari,
      'jamMulai': jamMulaiController.text,
      'jamSelesai': jamSelesaiController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else {
        debugPrint(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan jadwal.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(userData: userData),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dropdown for Kode MK
              DropdownButtonFormField<String>(
                value: selectedKodeMK,
                hint: Text('Pilih Kode Mata Kuliah'),
                items: mataKuliahList.map((mk) {
                  return DropdownMenuItem(
                    value: mk.kodeMk,
                    child: Text(mk.kodeMk),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKodeMK = value!;
                    selectedMataKuliah =
                        mataKuliahList.firstWhere((mk) => mk.kodeMk == value);
                    // Populate fields based on selected Mata Kuliah
                    namaMKController.text = selectedMataKuliah!.namaMk;
                    semesterController.text =
                        selectedMataKuliah!.semester.toString();
                    sksController.text = selectedMataKuliah!.sks.toString();
                    statusController.text = selectedMataKuliah!.status;
                    dosenPengampuControllers = selectedMataKuliah!.dosenPengampu
                        .map((dosen) => TextEditingController(text: dosen))
                        .toList();
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih Mata Kuliah' : null,
              ),

              // Nama MK
              TextFormField(
                controller: namaMKController,
                decoration: InputDecoration(labelText: 'Nama Mata Kuliah'),
                readOnly: true,
              ),

              // Semester
              TextFormField(
                controller: semesterController,
                decoration: InputDecoration(labelText: 'Semester'),
                readOnly: true,
              ),

              // SKS
              TextFormField(
                controller: sksController,
                decoration: InputDecoration(labelText: 'SKS'),
                readOnly: true,
              ),

              // Status
              TextFormField(
                controller: statusController,
                decoration: InputDecoration(labelText: 'Sifat (Wajib/Pilihan)'),
                readOnly: true,
              ),

              // Dosen Pengampu
              ...dosenPengampuControllers.map((controller) {
                return TextFormField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Dosen Pengampu'),
                  readOnly: true,
                );
              }).toList(),

              // Kelas
              TextFormField(
                controller: kelasController,
                decoration: InputDecoration(labelText: 'Kelas'),
              ),

              // Ruangan
              // Dropdown untuk Ruangan
              DropdownButtonFormField<String>(
                value: selectedRuangan,
                hint: Text('Pilih Ruangan'),
                items: ruangList.map((ruangan) {
                  return DropdownMenuItem(
                    value: ruangan.kodeRuang,
                    child: Text(ruangan.kodeRuang),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRuangan = value!;

                    // Cari objek Ruang berdasarkan kodeRuang yang dipilih
                    final ruangTerpilih = ruangList.firstWhere(
                        (ruang) => ruang.kodeRuang == selectedRuangan);

                    // Set kapasitasController dengan kapasitas dari objek Ruang
                    kapasitasController.text =
                        ruangTerpilih.kapasitas.toString();
                  });
                },
                validator: (value) => value == null ? 'Pilih Ruangan' : null,
              ),

              // Kapasitas Kelas
              TextFormField(
                controller: kapasitasController,
                decoration: InputDecoration(labelText: 'Kuota Kelas'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Field tidak boleh kosong' : null,
              ),

              // Hari
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
                decoration: InputDecoration(labelText: 'Jam Mulai'),
                readOnly: true, // Agar hanya bisa diubah lewat Time Picker
                onTap: () => _selectTime(context, jamMulaiController),
                validator: (value) => value!.isEmpty ? 'Pilih jam mulai' : null,
              ),

              // Jam Selesai
              TextFormField(
                controller: jamSelesaiController,
                decoration: InputDecoration(labelText: 'Jam Selesai'),
                readOnly: true, // Agar hanya bisa diubah lewat Time Picker
                onTap: () => _selectTime(context, jamSelesaiController),
                validator: (value) =>
                    value!.isEmpty ? 'Pilih jam selesai' : null,
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addJadwal();
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
