import 'package:flutter/material.dart';
import 'HealthMonitor.dart';
import 'Homepage.dart';
import 'Profilepage.dart';
import 'Requetsform.dart';
import 'Waterreport.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int currentindex = 0;

  final List<Widget> pages = [
    Homepage(),
    Healthmonitor(),
    Container(), // placeholder for center button
    Waterreport(),
    Profile(),
  ];

  void _ontapped(int index) {
    if (index == 2) return; // skip center button
    setState(() {
      currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentindex,
        onTap: _ontapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F2E05),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home, size: 28), label: "Home"),
          BottomNavigationBarItem(
              icon: const Icon(Icons.health_and_safety, size: 28), label: "Health"),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CampRequestForm(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10), // circular background size
                child: const Icon(
                  Icons.add,
                  size: 32, // bigger icon
                  color: Colors.white,
                ),
              ),
            ),
            label: "", // no label for center
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.file_copy_rounded, size: 28), label: "Water"),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person, size: 28), label: "Profile"),
        ],
      ),
    );
  }
}
