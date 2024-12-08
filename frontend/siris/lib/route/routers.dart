import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:siris/Kaprodi/Kaprodi_ListJadwal.dart';
import 'package:siris/dashboard.dart';
import 'package:siris/dosen/daftar_mahasiswa_perwalian_page.dart';
import 'package:siris/mahasiswa/indexMahasiswa.dart';
import 'package:siris/login_page.dart';

final logger = Logger('Routers');

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    logger.info('Redirect to ${settings.name}');

    final userData = settings.arguments as Map<String, dynamic>;
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (context) => LoginScreen());
      case '/dashboard':
        return MaterialPageRoute(
            builder: (context) => Dashboard(userData: userData));
      case '/irs':
        return MaterialPageRoute(
            builder: (context) => IRSPage(userData: userData));
      case '/Jadwal':
        return MaterialPageRoute(
            builder: (context) => AmbilIRS(userData: userData));
      case '/Perwalian':
        return MaterialPageRoute(builder: (context) => DaftarMahasiswaPerwalianPage(userData: userData));
      default:
        logger.warning('No route defined for ${settings.name}');
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text("No Route defined"),
                  ),
                ));
    }
  }
}
