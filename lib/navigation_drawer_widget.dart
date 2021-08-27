import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:runner/user_page.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final name = 'Oğuzhan Tarhan';
    final email = 'oguzhantarhanankara\n@gmail.com';
    final urlImage =
        'https://images.unsplash.com/photo-1529665253569-6d01c0eaf7b6?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZXxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&w=1000&q=80';

    return Drawer(
      child: Material(
        color: Colors.blueAccent.shade200,
        child: ListView(
          children: [
            buildHeader(
                urlImage: urlImage,
                name: name,
                email: email,
                onClicked: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserPage(
                        name: name,
                        urlImage: urlImage,
                      ),
                    ))),
            const SizedBox(
              height: 16,
            ),
            buildMenuItem(text: 'Profil', icon: Icons.person),
            const SizedBox(
              height: 16,
            ),
            buildMenuItem(text: 'Sosyal', icon: Icons.person_pin_circle),
            const SizedBox(
              height: 16,
            ),
            Divider(
              color: Colors.white70,
              thickness: 3,
            ),
            buildMenuItem(text: 'Giriş', icon: Icons.login),
            const SizedBox(
              height: 16,
            ),
            buildMenuItem(text: 'Kayıt', icon: Icons.app_registration_outlined),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required String email,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(urlImage),
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(fontSize: 14, color: Colors.white))
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildMenuItem({
    required String text,
    required IconData icon,
  }) {
    final color = Colors.white;
    final hoverColor = Colors.white70;
    return ListTile(
      leading: Icon(icon, color: color),
      hoverColor: hoverColor,
      title: Text(
        text,
        style: TextStyle(color: color),
      ),
      onTap: () {},
    );
  }
}
