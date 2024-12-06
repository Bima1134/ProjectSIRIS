class Jadwal {
  final String KodeMK;
  final String NamaMK;
  final String Ruangan;
  final String Hari;
  final String JamMulai;
  final String JamSelesai;
  final String Kelas;
  final int SKS;
  final List<String> DosenPengampu;

  Jadwal({
    required this.KodeMK,
    required this.NamaMK,
    required this.Ruangan,
    required this.Hari,
    required this.JamMulai,
    required this.JamSelesai,
    required this.Kelas,
    required this.SKS,
    required this.DosenPengampu
  });
}