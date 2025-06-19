import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(SmartDispenserApp());
}

class SmartDispenserApp extends StatelessWidget {
  const SmartDispenserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Water Dispenser',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? data;
  bool isLoading = false;

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("https://tensorflowtitan.xyz/backends/fetchdata.php"),
      );

      if (response.statusCode == 200) {
        setState(() => data = json.decode(response.body));
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to load data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // auto-load on start
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sensor Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoTile(
              label: "Temperature",
              value: "${data?['temperature'] ?? 'N/A'} °C",
            ),
            InfoTile(
              label: "Humidity",
              value: "${data?['humidity'] ?? 'N/A'} %",
            ),
            InfoTile(
              label: "Water Level",
              value: "${data?['water_level'] ?? 'N/A'} cm",
            ),
            InfoTile(
              label: "Leak Status",
              value: data?['leak_status'] == "1" ? "Detected" : "Safe",
            ),
            InfoTile(
              label: "Relay",
              value: data?['relay_state'] ?? "N/A",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchData,
              child: const Text("Refresh"),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const InfoTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.sensor_window_outlined),
      title: Text(label),
      trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
