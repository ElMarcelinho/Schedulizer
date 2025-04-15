import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AdminPanelPage extends StatefulWidget {
  final String email;
  final String role;

  const AdminPanelPage({super.key, required this.email, required this.role});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  List<String> users = [];
  String? selectedUser;
  Map<String, String> fetchedAvailability = {};
  DateTime _startOfWeek = DateTime.now();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _startOfWeek = _getStartOfWeek(DateTime.now());
    fetchUsers();
  }

  // Get the start of the week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Fetch the users (admin's job)
  Future<void> fetchUsers() async {
    final url = Uri.parse("http://10.0.2.2:8080/api/users/all");

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(res.body);
        setState(() {
          users = jsonList.cast<String>();
        });
      } else {
        print("❌ Failed to fetch users: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      print("❌ Network error: $e");
    }
  }

  // Fetch the availability data of the selected user for the current week
  Future<void> fetchAvailability(String email) async {
    final week = _startOfWeek.toIso8601String().split('T').first; // Get the start of the current week
    final url = Uri.parse("http://10.0.2.2:8080/api/availability?email=$email&weekStart=$week");

final res = await http.get(
  url,
  headers: {
    'Accept': 'application/json', // <-- sometimes helps
    'Content-Type': 'application/json',
  },
);



    try {
      setState(() {
        isLoading = true;
      });
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = Map<String, String>.from(json.decode(res.body));
        setState(() {
          fetchedAvailability = data;
        });
      } else {
        print("❌ Error fetching availability: ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      print("❌ Network error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Navigate to the next week
  void _nextWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.add(const Duration(days: 7));
    });
    if (selectedUser != null) fetchAvailability(selectedUser!);
  }

  // Navigate to the previous week
  void _previousWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
    });
    if (selectedUser != null) fetchAvailability(selectedUser!);
  }

  @override
  Widget build(BuildContext context) {
    final shifts = ['7:00 – 15:00', '11:00 – 18:00', '15:00 – 22:00'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: const Color(0xFF7494EC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown to select the user
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Select a user"),
                  value: selectedUser,
                  onChanged: (value) {
                    setState(() => selectedUser = value);
                    if (value != null) {
                      fetchAvailability(value);
                    }
                  },
                  items: users
                      .map((email) => DropdownMenuItem(
                            value: email,
                            child: Text(email),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Week Navigation (Next / Previous Week)
            if (selectedUser != null)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed: _previousWeek, icon: const Icon(Icons.arrow_back)),
                      Text(
                        'Week of ${DateFormat('dd.MM.yyyy').format(_startOfWeek)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(onPressed: _nextWeek, icon: const Icon(Icons.arrow_forward)),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),

            // Availability Grid (Calendar)
            if (selectedUser != null)
              isLoading
                  ? const CircularProgressIndicator()
                  : Expanded(
                      child: Column(
                        children: [
                          // Days of the week header
                          Row(
                            children: [
                              const SizedBox(width: 100),
                              ...days.map((day) => Expanded(
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Shifts & Availability Data
                          ...List.generate(shifts.length, (shiftIndex) {
                            return Row(
                              children: [
                                // Shift name (e.g., 7:00 – 15:00)
                                Container(
                                  width: 100,
                                  padding: const EdgeInsets.only(right: 8),
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    shifts[shiftIndex],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Availability for each day of the week
                                ...List.generate(7, (dayIndex) {
                                  final key = '${shiftIndex}_$dayIndex';
                                  final status = fetchedAvailability[key];
                                  Color color = Colors.grey[100]!;

                                  if (status == "can") color = Colors.green[300]!;
                                  if (status == "cant") color = Colors.red[300]!;

                                  return Expanded(
                                    child: Container(
                                      height: 40,
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: color,
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
