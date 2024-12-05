import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:siris/dashboard/dosen.dart';
import 'package:siris/dashboard/mahasiswa.dart';
import 'package:siris/dosen/daftar_mahasiswa_perwalian_page.dart';
import 'package:siris/mahasiswa/indexMahasiswa.dart';
final logger = Logger('Routers');

class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings){
    logger.info('Redirect to ${settings.name}');

    final userData = settings.arguments as Map<String, dynamic>;
          
    switch (settings.name) {
      case'/mahasiswa/dashboard':
        return MaterialPageRoute(builder: (context) => DashboardPageMahasiswa(userData: userData));
      case'/dosen/dashboard':
        return MaterialPageRoute(builder: (context) => DashboardPageDosen(userData: userData));
      case'/irs':
        return MaterialPageRoute(builder: (context) => IRSPage(userData: userData));
      case'/Jadwal':
        return MaterialPageRoute(builder: (context) => JadwalPage(userData: userData));
      case'/Perwalian':
        return MaterialPageRoute(builder: (context) => DaftarMahasiswaPerwalianPage(userData: userData));
      default:
        logger.warning('No route defined for ${settings.name}');
        return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text("No Route defined"),),));
    }
  }
}