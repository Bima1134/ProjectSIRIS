class MataKuliah {
  final String kodeMk;
  final String namaMk;
  final int sks;
  final String status;
  final int semester;
  final String prodi;
  final List<String> dosenPengampu;

  MataKuliah({
    required this.kodeMk,
    required this.namaMk,
    required this.sks,
    required this.status,
    required this.semester,
    required this.prodi,
    required this.dosenPengampu,
  });

  // Factory method untuk parsing dari JSON
  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      kodeMk: json['kode_mk'] ?? '', // Jika null, beri string kosong
      namaMk: json['nama_mk'] ?? '', // Jika null, beri string kosong
      sks: json['sks'] ?? 0, // Jika null, beri nilai 0
      status: json['status'] ?? '', // Jika null, beri string kosong
      semester: json['semester'] ?? 1, // Jika null, beri nilai 0
      prodi: json['prodi'] ?? '', // Jika null, beri string kosong
      dosenPengampu: json['dosen_pengampu'] != null
          ? (json['dosen_pengampu'] as String)
              .split(RegExp(
                  r'\s*\|\s*')) // Memisahkan berdasarkan karakter "|" dengan spasi opsional
              .toList()
          : [],
    );
  }
  @override
  String toString() {
    return 'MataKuliah(kodeMk: $kodeMk, namaMk: $namaMk, sks: $sks, status: $status, semester: $semester, prodi: $prodi, dosenPengampu: $dosenPengampu)';
  }
}
