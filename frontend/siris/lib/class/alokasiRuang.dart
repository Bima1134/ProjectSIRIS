class AlokasiRuang {
  final String idAlokasi;
  final String idSem;
  final String namaProdi;
  final String status;


  AlokasiRuang({
    required this.idAlokasi,
    required this.idSem,
    required this.namaProdi,
    required this.status,
  });

  factory AlokasiRuang.fromJson(Map<String, dynamic> json) {
    return AlokasiRuang(
      idAlokasi: json['id_alokasi'],
      idSem: json['idsem'],
      namaProdi: json['nama_prodi'],
      status: json['status'],
    );
  }
}
