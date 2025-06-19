import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<String, dynamic>? data;

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'http://tensorflowtitan.xyz/backends/fetch_latest_data.php'));

      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Widget buildSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    Color? textColor,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green.shade50,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2EA),
      appBar: AppBar(
        title: const Text("Sensor Dashboard"),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
            tooltip: 'About',
          ),
        ],
      ),
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildSensorCard(
                  icon: Icons.thermostat,
                  label: "Temperature",
                  value: "${data!['temperature']} °C",
                  iconColor: Colors.orange,
                  textColor:
                      (double.tryParse("${data!['temperature']}") ?? 0) > 30
                          ? Colors.red
                          : Colors.blue,
                ),
                buildSensorCard(
                  icon: Icons.water_drop,
                  label: "Humidity",
                  value: "${data!['humidity']} %",
                  iconColor: Colors.lightBlue,
                  textColor: (double.tryParse("${data!['humidity']}") ?? 0) > 85
                      ? Colors.orange
                      : Colors.green,
                ),
                buildSensorCard(
                  icon: Icons.straighten,
                  label: "Water Level",
                  value: "${data!['water_level']} cm",
                  iconColor: Colors.teal,
                ),
                buildSensorCard(
                  icon: Icons.report_gmailerrorred,
                  label: "Leak Status",
                  value: data!['leak_status'] == "1" ? "Detected" : "Safe",
                  iconColor: Colors.red,
                  textColor:
                      data!['leak_status'] == "1" ? Colors.red : Colors.green,
                ),
                buildSensorCard(
                  icon: Icons.power_settings_new,
                  label: "Relay",
                  value: data!['relay_state']?.toUpperCase() ?? "OFF",
                  iconColor: Colors.purple,
                ),
                const SizedBox(height: 20),
                if (data!['temperature'] != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            getWaterSuggestion(data!['temperature']),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  String getWaterSuggestion(dynamic temp) {
    double t = double.tryParse(temp.toString()) ?? 0;
    if (t > 30) return "\u2600\ufe0f It's hot! Cold water recommended.";
    if (t < 24) return "\u2744\ufe0f Cold day. Hot water recommended.";
    return "\u2728 Normal weather. Choose freely.";
  }
}
