import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:siris/BA/BA_list_ruang_page.dart';
import 'package:siris/BA/BA_list_alokasi_page.dart';
import 'package:siris/Kaprodi/Kaprodi_ListJadwal.dart';
import 'package:siris/Kaprodi/Kaprodi_list_matkul_page.dart';
import 'package:siris/dashboard.dart';
import 'package:siris/dashboard/dosen.dart';
import 'package:siris/dosen/daftar_mahasiswa_perwalian_page.dart';
import 'package:siris/mahasiswa/indexMahasiswa.dart';
import 'package:siris/login_page.dart';
import 'package:siris/dekan/indexDekan.dart';

final logger = Logger('Routers');

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    logger.info('Redirect to ${settings.name}');

    final data = settings.arguments;
    
    // Check if data exists and is a Map
    if (data != null && data is Map<String, dynamic>) {
      switch (settings.name) {
        case '/dashboard':
          return MaterialPageRoute(builder: (context) => Dashboard(userData: data));
        case '/irs':
          return MaterialPageRoute(builder: (context) => IRSPage(userData: data));
        case '/Jadwal':
          return MaterialPageRoute(builder: (context) => AmbilIRS(userData: data));
        case '/Perwalian':
          return MaterialPageRoute(builder: (context) => DaftarMahasiswaPerwalianPage(userData: data));
        case '/test':
          return MaterialPageRoute(builder: (context) => DashboardPageDosen(userData: data));
        case '/kaprodi/jadwal/':
          return MaterialPageRoute(builder: (context) => ListJadwalKaprodiPage(userData: data));
        case '/dekan/jadwal/':
          return MaterialPageRoute(builder: (context) => JadwalPage(userData: data));
        case '/dekan/jadwal/detail/':
          return MaterialPageRoute(builder: (context) => DetailJadwalPage(userData: data, idJadwalProdi: data['idJadwal']));
        case '/dekan/ruang/':
          return MaterialPageRoute(builder: (context) => RuangPage(userData: data));
        case '/dekan/ruang/detail/':
          return MaterialPageRoute(builder: (context) => DetailRuangPage(userData: data, idAlokasiRuang: data['idAlokasi']));
        case '/BA/ruang':
          return MaterialPageRoute(builder: (context) => ListRuangPage(userData: data));
        case '/BA/alokasi-ruang':
          return MaterialPageRoute(builder: (context) => ListAlokasiPage(userData: data));
        case '/kaprodi/matkul':
          return MaterialPageRoute(builder: (context) => ListMatkulPage(userData: data));
        default:
          logger.warning('No route defined for ${settings.name}');
          return _noRoutePage();
      }
    } else {
      if (settings.name == '/login'){
          return MaterialPageRoute(builder: (context) => LoginScreen());
      }
      // Handle case where data is null or not a valid map
      logger.warning('Invalid or missing arguments for route ${settings.name}');
      return _noRoutePage();
    }
  }

  // This is the fallback page when no route is matched or arguments are invalid
  static MaterialPageRoute _noRoutePage() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text("No Route defined or Invalid Arguments"),
        ),
      ),
    );
  }
}
