import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'index_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> registerUser(String username, String email, String password) async {
  final url = Uri.parse("http://10.0.2.2:8080/api/register");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "username": username,
      "email": email,
      "passwordHash": password,
    }),
  );

  print('Register response code: ${response.statusCode}');
  print('Register response body: ${response.body}');

  if (response.statusCode == 200) {
    return null; // No error
  } else {
    return response.body; // Return backend error message
  }
}
Future<Map<String, dynamic>?> loginUser(String email, String password)
 async {
  final url = Uri.parse("http://10.0.2.2:8080/api/login");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      "email": email,
      "password": password, // Send the raw password as-is
    }),
  );

  print('Login response code: ${response.statusCode}');
  print('Login response body: ${response.body}');

  if (response.statusCode == 200) {
  return json.decode(response.body); // returns a Map with username, email, role
}
 else {
    return null; // backend error message
  }
}



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login/Signup Form',
      debugShowCheckedModeBanner: false,
      home: LoginSignupScreen(),
    );
  }
}

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  /// Določa, ali naj bo aktiven Register obrazec (true) ali Login (false).
  bool isRegisterActive = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Manjši “container”, da ne zavzame celega zaslona
    final containerWidth = screenSize.width * 0.85;
    final containerHeight = screenSize.height * 0.7;

    /// Spremenimo razmerje tako, da je:
    /// - Obrazec: 70% širine
    /// - Panel: 30% širine
    final formWidthFactor = 0.6;
    final panelWidthFactor = 0.4;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE2E2E2), Color(0xFFC9D6FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 600),
            width: containerWidth,
            height: containerHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 30,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                /// Login ali Register form
                AnimatedPositioned(
                  duration: Duration(milliseconds: 600),
                   right: isRegisterActive ? 10 : 0,
                  top: 0,
                  bottom: 0,
                  child: Padding(
                  padding: isRegisterActive
                    ? EdgeInsets.only(left: 50)  // Povečali smo margin left za registracijo
                     : EdgeInsets.only(right: 130),
                  child: Container(
                    width: containerWidth * formWidthFactor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: isRegisterActive ? RegisterForm() : LoginForm(),
             ),
            ),
          ),


                /// Moder panel za preklop
                AnimatedPositioned(
                  duration: Duration(milliseconds: 600),
                  // Ko je aktivna registracija, je panel levo (left = 0),
                  // sicer ga postavimo na left = 70% (formWidthFactor).
                  left: isRegisterActive ? 0 : containerWidth * formWidthFactor,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: containerWidth * panelWidthFactor,
                    // Manjšamo radius na 70 ali 80 (namesto 150),
                    // da “oval” ne prekrije obrazca
                    decoration: BoxDecoration(
                      color: Color(0xFF7494EC),
                      borderRadius: BorderRadius.circular(70),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isRegisterActive ? "Welcome Back!" : "Hello, Welcome!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            isRegisterActive
                                ? "Already have an account?"
                                : "Don't have an account?",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 20),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white, width: 2),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isRegisterActive = !isRegisterActive;
                              });
                            },
                            child: Text(
                              isRegisterActive ? "Login" : "Register",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.black),
      filled: true,
      fillColor: Colors.grey[200],
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _handleLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  final userData = await loginUser(email, password); // now returns Map or null

  if (userData != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => IndexPage(
          email: userData['email'],
          role: userData['role'],
        ),
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Failed"),
        content: const Text("Invalid email or password."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Form(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Text("Login", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            // Email
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: _emailController,
                decoration: inputDecoration("Email", Icons.email),
              ),
            ),

            // Password
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: inputDecoration("Password", Icons.lock),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text("Forgot Password?", style: TextStyle(fontSize: 14.5, color: Colors.black)),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7494EC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),

            SizedBox(height: 20),
            Text("or login with social platforms"),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: FaIcon(FontAwesomeIcons.google), onPressed: () {}),
                IconButton(icon: FaIcon(FontAwesomeIcons.facebook), onPressed: () {}),
                IconButton(icon: FaIcon(FontAwesomeIcons.github), onPressed: () {}),
                IconButton(icon: FaIcon(FontAwesomeIcons.linkedin), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ---------------- REGISTER FORM ----------------
class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.black),
      filled: true,
      fillColor: Colors.grey[200],
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _handleRegister() async {
  final username = _usernameController.text.trim();
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  final errorMessage = await registerUser(username, email, password); // <-- String? now

  if (errorMessage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registration successful. Please log in.")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginSignupScreen()),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registration Failed"),
        content: Text(errorMessage), // Show actual message!
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Form(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Text("Registration", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            // Username
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: _usernameController,
                decoration: inputDecoration("Username", Icons.person),
              ),
            ),

            // Email
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: _emailController,
                decoration: inputDecoration("Email", Icons.email),
              ),
            ),

            // Password
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: inputDecoration("Password", Icons.lock),
              ),
            ),

            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7494EC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Register", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),

            SizedBox(height: 20),
            Text("or register with social platforms"),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: FaIcon(FontAwesomeIcons.google), onPressed: () {}),
                IconButton(icon: FaIcon(FontAwesomeIcons.facebook), onPressed: () {}),
                IconButton(icon: FaIcon(FontAwesomeIcons.github), onPressed: () {}),
                IconButton(icon: FaIcon(FontAwesomeIcons.linkedin), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

