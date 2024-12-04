import 'package:flutter/material.dart';
import 'package:siris/dashboard/dosen.dart';
import 'package:siris/dashboard/mahasiswa.dart';
import 'package:siris/dosen/daftar_mahasiswa_perwalian_page.dart';
import 'package:siris/login_page.dart';
import 'package:siris/mahasiswa/indexMahasiswa.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIRIS Login',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
          final Map<String, dynamic> userData = settings.arguments as Map<String, dynamic>;
          
          if (settings.name == '/mahasiswa/dashboard'){
            return MaterialPageRoute(builder: (context) => DashboardPageMahasiswa(userData: userData));
          }
          else if (settings.name == '/dosen/dashboard'){
            return MaterialPageRoute(builder: (context) => DashboardPageDosen(userData: userData));
          }
          else if(settings.name == '/irs'){
            return MaterialPageRoute(builder: (context) => IRSPage(userData: userData));
          }
          else if(settings.name == '/Jadwal'){
            return MaterialPageRoute(builder: (context) => JadwalPage(userData: userData));
          }
          else if(settings.name == '/Perwalian'){
            return MaterialPageRoute(builder: (context) => DaftarMahasiswaPerwalianPage(userData: userData));
          }
        return null;
      },
    );
  }
}
