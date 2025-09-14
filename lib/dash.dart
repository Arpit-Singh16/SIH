import 'package:flutter/material.dart';

class ClinicDashboard extends StatefulWidget {
  const ClinicDashboard({super.key});

  @override
  State<ClinicDashboard> createState() => _ClinicDashboardState();
}

class _ClinicDashboardState extends State<ClinicDashboard> {
  // Dummy data
  final List<Map<String, dynamic>> villages = [
    {
      "name": "Village A",
      "cases": 25,
      "breakoutChance": 0.7, // 70%
      "alert": "High risk",
    },
    {
      "name": "Village B",
      "cases": 10,
      "breakoutChance": 0.3,
      "alert": "Low risk",
    },
    {
      "name": "Village C",
      "cases": 50,
      "breakoutChance": 0.9,
      "alert": "Critical",
    },
  ];

  final int totalCases = 85;
  final int recovered = 60;
  final int deaths = 5;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("🏥 Clinic Dashboard"),
          backgroundColor: Colors.teal.shade700,
          actions: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Colors.white)),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Stats
                Text(
                  "📊 Overall Stats",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard("Total Cases", totalCases, Colors.orange),
                    _buildStatCard("Recovered", recovered, Colors.green),
                    _buildStatCard("Deaths", deaths, Colors.red),
                  ],
                ),
                const SizedBox(height: 20),
      
                // Villages List
                Text(
                  "🏘️ Villages Overview",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: villages.length,
                  itemBuilder: (context, index) {
                    final village = villages[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Village Name and Cases
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  village["name"],
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${village["cases"]} cases",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
      
                            // Breakout chance
                            Text("Breakout Chance: ${(village["breakoutChance"] * 100).toStringAsFixed(0)}%"),
                            const SizedBox(height: 5),
                            LinearProgressIndicator(
                              value: village["breakoutChance"],
                              backgroundColor: Colors.grey.shade300,
                              color: village["breakoutChance"] > 0.7
                                  ? Colors.red
                                  : Colors.orange,
                              minHeight: 8,
                            ),
      
                            const SizedBox(height: 10),
      
                            // Alert message
                            Text(
                              "Alert: ${village["alert"]}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: village["alert"] == "Critical"
                                      ? Colors.red
                                      : village["alert"] == "High risk"
                                      ? Colors.orange
                                      : Colors.green),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Stat Card
  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
