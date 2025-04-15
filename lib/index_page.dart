import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'urnik.dart';
import 'clani.dart';
import 'o_meni.dart';
import 'admin_panel.dart';

class IndexPage extends StatelessWidget {
  final String email;
final String role;

const IndexPage({
  super.key,
  required this.email,
  required this.role,
});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE2E2E2), Color(0xFFC9D6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Schedulizer",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFF7494EC),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  HomeCard(
  icon: FontAwesomeIcons.calendarDays,
  label: "Urnik",
  onTap: () {
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UrnikPage(
      email: email,
      role: role,
    ),
  ),
);

  },
),

                  HomeCard(
                    icon: FontAwesomeIcons.users,
                    label: "Člani ekipe",
                    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ClaniPage(
        users: [
          {'ime': 'Ana', 'priimek': 'Kovač'},
          {'ime': 'Luka', 'priimek': 'Novak'},
          {'ime': 'Sara', 'priimek': 'Potočnik'},
        ],
        email: email,
        role: role,
      ),
    ),
  );
},

                  ),
                  HomeCard(
                    icon: FontAwesomeIcons.gear,
                    label: "O meni",
                    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => OMeniPage(
        username: email.split('@').first, // get username from email
        email: email,
        role: role,
      ),
    ),
  );
},

                  ),
                  if (role == "admin")
  HomeCard(
    icon: FontAwesomeIcons.userShield,
    label: "Admin Panel",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPanelPage(
            email: email,
            role: role,
          ),
        ),
      );
    },
  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const HomeCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: 40,
                color: const Color(0xFF7494EC),
              ),
              const SizedBox(height: 15),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
