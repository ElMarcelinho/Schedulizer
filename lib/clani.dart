import 'package:flutter/material.dart';
import 'index_page.dart';

class ClaniPage extends StatelessWidget {
  final List<Map<String, String>> users;
final String email;
final String role;

const ClaniPage({
  super.key,
  required this.users,
  required this.email,
  required this.role,
});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7494EC),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => IndexPage(email: email, role: role)


    ),
  );
},

            ),
            const Text(
              'Schedulizer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade400, blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Člani ekipe",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Color(0xFFE7ECFF)),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Ime", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Priimek", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...users.map(
                    (user) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(user['ime'] ?? ''),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(user['priimek'] ?? ''),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
