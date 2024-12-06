import 'package:siris/class/Jadwal.dart';

class JadwalProdi {
  final String namaProdi;
  final List<Jadwal> jadwals;
  final String status; // Status persetujuan

  JadwalProdi({
    required this.namaProdi,
    required this.jadwals,
    required this.status,
  });

  factory JadwalProdi.fromJson(Map<String, dynamic> json) {
    return JadwalProdi(
      namaProdi: json['kode_mk'],
      jadwals: json['nama_mk'],
      status: json['kode_ruangan'],
    );
  }
}