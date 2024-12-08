class JadwalProdi {
  final String idJadwal;
  final String namaProdi;
  final String idSem;
  final String status; // Status persetujuan

  JadwalProdi({
    required this.idJadwal,
    required this.namaProdi,
    required this.idSem,
    required this.status,
  });

  factory JadwalProdi.fromJson(Map<String, dynamic> json) {
    return JadwalProdi(
      idJadwal: json['id_jadwal_prodi'],
      namaProdi: json['nama_prodi'],
      idSem: json['idsem'],
      status: json['status'],
    );
  }
}