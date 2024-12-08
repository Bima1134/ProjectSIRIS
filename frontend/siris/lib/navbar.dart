import 'package:flutter/material.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  final Map<String, dynamic> userData; // Tambahkan parameter untuk userData
  const Navbar({super.key, required this.userData}); // Konstruktor untuk menerima userData

  @override
  NavbarState createState() => NavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);  
}

class NavbarState extends State<Navbar> {
  get userData => widget.userData;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return _buildDesktopLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];

    if (userData['currentLoginAs'] == 'Mahasiswa') {
      buttons.add(_buildMenuItem(Icons.book, 'IRS', onTap: () {
        Navigator.pushNamed(context, '/irs', arguments: userData);
      }));

      buttons.add(_buildMenuItem(Icons.schedule, 'Jadwal', onTap: () {
        Navigator.pushNamed(context, '/Jadwal', arguments: userData);
      }));
    } 
    else if(userData['currentLoginAs'] == 'Bagian Akademik'){
     buttons.addAll([
    _buildMenuItem(
      Icons.room,
      'Ruang',
      onTap: () {
        Navigator.pushNamed(context, '/ruang', arguments: userData);
      },
    ),
    _buildMenuItem(
      Icons.edit,
      'Alokasi Ruang',
      onTap: () {
        Navigator.pushNamed(context, '/alokasi-ruang', arguments: userData);
      },
    ),
  ]);
      }
    else  {
      if (userData['currentLoginAs'] == 'Dosen') {
        buttons.add(_buildMenuItem(Icons.person, 'Daftar Mahasiswa Perwalian', onTap: () {
          Navigator.pushNamed(context, '/Perwalian', arguments: userData);
        }));
      }
      if (userData['role'] == 'Dekan' || userData['role'] == 'Kaprodi'){
          buttons.add(_buildSwitchRole(userData['currentLoginAs']));
          if(userData['currentLoginAs'] == 'Kaprodi'){
                _buildMenuItem(
      Icons.room,
      'Ruang',
      onTap: () {
        Navigator.pushNamed(context, '/ruang', arguments: userData);
      },
    );
          }
      }
    }

    buttons.add(_buildMenuItem(Icons.settings, 'Settings', onTap: () {}));
    buttons.add(_buildLogoutButton());
    return buttons;
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF162953),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Row(
                children: _buildButtons(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange[300],
      body: Center(
        child: Text('Mobile layout'),
      ),
    );
  }

  Widget _buildSwitchRole(String role) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Icon(Icons.switch_account, color: Colors.white),
          const SizedBox(width: 4),
          Text('Ganti Role', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: Text(
              role,
              style: const TextStyle(color: Colors.white, fontSize: 18)),
            onChanged: (String? newRole) {
              setState(() {
                if (newRole != role){
                  userData['currentLoginAs'] = newRole;
                }
                // Redirect sesuai role yang dipilih
                if (newRole == 'Dosen') {
                  Navigator.pushNamed(context, '/dosen/dashboard', arguments: userData);
                } else if (newRole == 'Dekan') {
                  Navigator.pushNamed(context, '/dekan/dashboard', arguments: userData);
                } else if (newRole == 'Kaprodi') {
                  Navigator.pushNamed(context, '/kaprodi/dashboard', arguments: userData);
                }
                else{
                  Navigator.pushNamed(context, '/404', arguments: userData);
                }
              });
            },
            items: <String>["Mahasiswa", 'Dosen', userData['role']].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
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
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(width: 16),
        ],
      ),
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
}
