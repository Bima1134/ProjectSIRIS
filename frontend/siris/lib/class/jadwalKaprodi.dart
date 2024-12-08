class JadwalKaprodiView {
  final String kodeMk;
  final String namaMatkul;
  final String semester;
  final int sks;
  final String sifat;
  final List<String> dosenPengampu;
  final String kelas;
  final String ruangan;
  final int? kapasitas; // Nullable
  final String hari;
  final DateTime jamMulai;
  final DateTime jamSelesai;

  JadwalKaprodiView({
    required this.kodeMk,
    required this.namaMatkul,
    required this.semester,
    required this.sks,
    required this.sifat,
    required this.dosenPengampu,
    required this.kelas,
    required this.ruangan,
    this.kapasitas,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  // Factory method untuk parsing dari JSON
  factory JadwalKaprodiView.fromJson(Map<String, dynamic> json) {
    return JadwalKaprodiView(
      kodeMk: json['kode_mk'],
      namaMatkul: json['namaMatkul'],
      semester: json['semester'],
      sks: json['sks'],
      sifat: json['sifat'],
      dosenPengampu: json['dosen_pengampu'] != null
          ? (json['dosen_pengampu'] as String)
              .split(RegExp(
                  r'\s*\|\s*')) // Memisahkan berdasarkan karakter "|" dengan spasi opsional
              .toList()
          : [],
      kelas: json['kelas'],
      ruangan: json['ruangan'],
      kapasitas: json['kapasitas'],
      hari: json['hari'],
      jamMulai: DateTime.parse(json['jam_mulai']),
      jamSelesai: DateTime.parse(json['jam_selesai']),
    );
  }

  // Method untuk mengonversi ke Map<String, dynamic> (opsional)
  Map<String, dynamic> toJson() {
    return {
      'kode_mk': kodeMk,
      'namaMatkul': namaMatkul,
      'semester': semester,
      'sks': sks,
      'sifat': sifat,
      'dosen_pengampu': dosenPengampu,
      'kelas': kelas,
      'ruangan': ruangan,
      'kapasitas': kapasitas,
      'hari': hari,
      'jam_mulai': jamMulai.toIso8601String(),
      'jam_selesai': jamSelesai.toIso8601String(),
    };
  }
}
