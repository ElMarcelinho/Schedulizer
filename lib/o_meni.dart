import 'package:flutter/material.dart';
import 'index_page.dart';


class OMeniPage extends StatelessWidget {
  final String username;
final String email;
final String role;

const OMeniPage({
  super.key,
  required this.username,
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
      builder: (context) => IndexPage(email: email, role: role),
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
          width: double.infinity,
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
                "O meni",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text("Username: $username", style: const TextStyle(fontSize: 16)),
const SizedBox(height: 10),
Text("Email: $email", style: const TextStyle(fontSize: 16)),

            ],
          ),
        ),
      ),
    );
  }
}
