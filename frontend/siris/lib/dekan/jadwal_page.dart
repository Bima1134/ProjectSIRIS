import 'dart:convert';
import 'package:siris/class/Jadwal.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;


final loggerJadwal = Logger('jadwalPage');

class JadwalPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const JadwalPage({super.key, required this.userData});

  @override
  JadwalPageState createState() => JadwalPageState();
}

class JadwalPageState extends State<JadwalPage> {
  String? semester;
  List<Jadwal> jadwalProdi = [];
  get userData => widget.userData;

  @override
  void initState(){
    super.initState();
    semester = '20241';
    fetchJadwalProdi(semester!);
  }

  Future<void> fetchJadwalProdi(String semester) async {
    final url = 'http://localhost:8080/jadwalProdi/$semester';
    loggerJadwal.info("Fetching jadwal prodi: $semester");

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}