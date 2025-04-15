// Updated version with admin support
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'index_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum Availability { can, cant, swap }

class UrnikPage extends StatefulWidget {
  final bool isAdmin;
  final String email;
  final String role;

  const UrnikPage({
    super.key,
    this.isAdmin = false,
    required this.email,
    required this.role,
  });



  @override
  State<UrnikPage> createState() => _UrnikPageState();
}

class _UrnikPageState extends State<UrnikPage> {
  DateTime _startOfWeek = DateTime.now();
  Availability? _selectedOption = Availability.can;

  final Map<String, Availability?> _cellStatus = {};
  final Map<String, List<String>> _availableUsers = {}; // admin: list of users who selected 'can'
  final List<SwapRequest> _swapRequests = [];
  final Map<String, String> _swapComments = {};
  final TextEditingController _commentController = TextEditingController();
  String? _selectedSwapKey;

  final String currentUser = "Me"; // this should come from auth system
Future<void> fetchAvailability() async {
  final week = _startOfWeek.toIso8601String().split('T').first;
  final url = Uri.parse("http://10.0.2.2:8080/api/availability?email=${widget.email}&weekStart=$week");

  try {
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = Map<String, String>.from(json.decode(res.body));
      setState(() {
        _cellStatus.clear();
        data.forEach((key, value) {
          switch (value) {
            case 'can':
              _cellStatus[key] = Availability.can;
              break;
            case 'cant':
              _cellStatus[key] = Availability.cant;
              break;
            case 'swap':
              _cellStatus[key] = Availability.swap;
              break;
          }
        });
      });
    } else {
      print("❌ Error fetching availability: ${res.statusCode}");
    }
  } catch (e) {
    print("❌ Network error: $e");
  }
}

  @override
  void initState() {
    super.initState();
    _startOfWeek = _getStartOfWeek(_startOfWeek);
    fetchAvailability();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _nextWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.add(const Duration(days: 7));
      _cellStatus.clear();
      _availableUsers.clear();
      _swapRequests.clear();
      _swapComments.clear();
    });
    fetchAvailability();
  }

  void _previousWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
      _cellStatus.clear();
      _availableUsers.clear();
      _swapRequests.clear();
      _swapComments.clear();
    });
    fetchAvailability();
  }

  List<String> _getShifts() {
    return ['7:00 – 15:00', '11:00 – 18:00', '15:00 – 22:00'];
  }

  List<DateTime> _getWeekDays() {
    return List.generate(7, (i) => _startOfWeek.add(Duration(days: i)));
  }

  Color? _getCellColor(String key) {
    final value = _cellStatus[key];
    if (value == Availability.can) return Colors.green[300];
    if (value == Availability.cant) return Colors.red[300];
    if (value == Availability.swap) return Colors.yellow[300];
    return Colors.grey[100];
  }

  void _handleSave() {
  _swapRequests.clear();

  _cellStatus.forEach((key, value) {
    if (value == Availability.swap && _swapComments.containsKey(key)) {
      final parts = key.split('_');
      final shiftIndex = int.parse(parts[0]);
      final dayIndex = int.parse(parts[1]);
      final date = _startOfWeek.add(Duration(days: dayIndex));
      _swapRequests.add(SwapRequest(
        key: key,
        date: date,
        shiftLabel: _getShifts()[shiftIndex],
        comment: _swapComments[key]!,
      ));
    }
  });

  sendAvailabilityToBackend(); // ✅ Send to backend

  setState(() {});
}
Future<void> sendAvailabilityToBackend() async {
  final url = Uri.parse("http://10.0.2.2:8080/api/availability/save");

  final Map<String, String> formattedAvailability = {};
  _cellStatus.forEach((key, value) {
    if (value != null) {
      formattedAvailability[key] = value.toString().split('.').last;
    }
  });

  final body = {
    "email": widget.email,
    "weekStart": _startOfWeek.toIso8601String().split('T').first,
    "availability": formattedAvailability,
  };

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      print("✅ Availability saved.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Availability saved successfully!")),
      );
    } else {
      print("❌ Failed to save availability: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${response.body}")),
      );
    }
  } catch (e) {
    print("❌ Network error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Network error while saving.")),
    );
  }
}


  void _toggleAvailability(String key) {
    if (_selectedOption == Availability.can) {
      _availableUsers.putIfAbsent(key, () => []);
      if (!_availableUsers[key]!.contains(currentUser)) {
        _availableUsers[key]!.add(currentUser);
      }
    } else if (_selectedOption == Availability.cant) {
      _availableUsers[key]?.remove(currentUser);
    }

    setState(() {
      _cellStatus[key] = _selectedOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getWeekDays();
    final shifts = _getShifts();

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
    builder: (context) => IndexPage(
      email: widget.email,
      role: widget.role,
    ),
  ),
);


              },
            ),
            const Text('Schedulizer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: _previousWeek, child: const Text("<", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  Text('Teden: ${DateFormat('dd.MM.').format(_startOfWeek)} - ${DateFormat('dd.MM.yyyy').format(_startOfWeek.add(const Duration(days: 6)))}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  TextButton(onPressed: _nextWeek, child: const Text(">", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 10, offset: const Offset(0, 4))],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 100),
                        ...days.map((day) => Expanded(
                          child: Text(
                            DateFormat('EEE\ndd.MM.').format(day),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        )),
                      ],
                    ),
                    const Divider(height: 1),
                    Column(
                      children: List.generate(shifts.length, (shiftIndex) {
                        return SizedBox(
                          height: widget.isAdmin ? 100 : 48,
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(shifts[shiftIndex], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                              ...List.generate(7, (dayIndex) {
                                final key = '${shiftIndex}_$dayIndex';
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: widget.isAdmin ? null : () {
                                      if (_selectedOption == Availability.swap) {
                                        setState(() {
                                          _selectedSwapKey = key;
                                          _commentController.text = _swapComments[key] ?? '';
                                        });
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Enter reason for swap"),
                                              content: TextField(
                                                controller: _commentController,
                                                decoration: const InputDecoration(hintText: "Why can't you work this shift?"),
                                                maxLines: 3,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    if (_commentController.text.trim().isEmpty) return;
                                                    setState(() {
                                                      _cellStatus[key] = Availability.swap;
                                                      _swapComments[key] = _commentController.text.trim();
                                                      _selectedSwapKey = null;
                                                    });
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Save"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        _toggleAvailability(key);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: _getCellColor(key),
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: widget.isAdmin && _availableUsers[key] != null
                                          ? ListView(
                                              padding: const EdgeInsets.all(4),
                                              children: _availableUsers[key]!.map((user) => Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(user, style: const TextStyle(fontSize: 12)),
                                                      IconButton(
                                                        icon: const Icon(Icons.close, size: 16),
                                                        onPressed: () {
                                                          setState(() {
                                                            _availableUsers[key]!.remove(user);
                                                          });
                                                        },
                                                      )
                                                    ],
                                                  )).toList(),
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (!widget.isAdmin) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<Availability>(value: Availability.can, groupValue: _selectedOption, onChanged: (v) => setState(() => _selectedOption = v)),
                          const Text('I can'),
                          const SizedBox(width: 20),
                          Radio<Availability>(value: Availability.cant, groupValue: _selectedOption, onChanged: (v) => setState(() => _selectedOption = v)),
                          const Text("I can't"),
                          const SizedBox(width: 20),
                          Radio<Availability>(value: Availability.swap, groupValue: _selectedOption, onChanged: (v) => setState(() => _selectedOption = v)),
                          const Text("Swap"),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7494EC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_swapRequests.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _swapRequests.map((req) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${DateFormat('EEEE, dd.MM.yyyy').format(req.date)} - ${req.shiftLabel}', style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('Reason: ${req.comment}', style: const TextStyle(fontStyle: FontStyle.italic)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => setState(() {
                                  _cellStatus[req.key] = Availability.can;
                                  _swapRequests.remove(req);
                                }),
                                child: const Text("Accept", style: TextStyle(color: Colors.green)),
                              ),
                              TextButton(
                                onPressed: () => setState(() {
                                  _cellStatus[req.key] = Availability.cant;
                                  _swapRequests.remove(req);
                                }),
                                child: const Text("Decline", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SwapRequest {
  final String key;
  final DateTime date;
  final String shiftLabel;
  final String comment;

  SwapRequest({
    required this.key,
    required this.date,
    required this.shiftLabel,
    required this.comment,
  });
}