class Ruang {
  final String kodeRuang;
  final String namaRuang;
  final String gedung;
  final int lantai;
  final String fungsi;
  final int kapasitas;

  Ruang({
    required this.kodeRuang,
    required this.namaRuang,
    required this.gedung,
    required this.lantai,
    required this.fungsi,
    required this.kapasitas,
  });

  factory Ruang.fromJson(Map<String, dynamic> json) {
    return Ruang(
      kodeRuang: json['kode_ruang'],
      namaRuang: json['nama_ruang'],
      gedung: json['gedung'],
      lantai: json['lantai'],
      fungsi: json['fungsi'],
      kapasitas: json['kapasitas'],
    );
  }
}
