import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget{
  final Map<String, dynamic> userData; // Tambahkan parameter untuk userData
  const Navbar({super.key, required this.userData}); // Konstruktor untuk menerima userData
  
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200){
      return _buildDesktopLayout(context);
    }
    else{
      return _buildMobileLayout(context);
    }
    // TODO: implement build
  }

  List<Widget> _buildButtons(BuildContext context){
    List<Widget> buttons = [];

    // Role based buttons
    if(userData['role'] == 'Mahasiswa'){
      // Button IRS
      buttons.add(_buildMenuItem(Icons.book, 'IRS', onTap: (){
        Navigator.pushNamed(context, '/irs', arguments: userData);
      }));

      // Button Jadwal
      buttons.add(_buildMenuItem(Icons.schedule, 'Jadwal', onTap: (){
        Navigator.pushNamed(context, '/Jadwal', arguments: userData);
      }));
    }
    else if(userData['role'] == 'Dosen'){
      //Button Mhs Wali
      buttons.add(_buildMenuItem(Icons.person, 'Daftar Mahasiswa Perwalian', onTap: (){
        Navigator.pushNamed(context, '/Perwalian', arguments: userData);
      }));
    }

    // Universal Buttons
    buttons.add(_buildMenuItem(Icons.settings, 'Settings', onTap: (){

    }));

    buttons.add(_buildLogoutButton());
    return buttons;
  }

  Widget _buildDesktopLayout(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF162953),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
          child: Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title Section
              const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'SIRIS',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sistem Informasi Isian Rencana Studi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Actions Section
              Row(
                children: _buildButtons(context),
              ),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context){
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.deepOrange[300],
      body: Center(
        child: Text(screenWidth.toString()),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize:18)),
          const SizedBox(width: 16),
        ],
      )
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle logout
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      child: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}