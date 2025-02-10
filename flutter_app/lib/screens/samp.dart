import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _urlController = TextEditingController();
  Map<String, dynamic> _results = {};
  String _error = "";
  bool _isLoading = false;
  double _progress = 0.0;

  Future<void> scanUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = "Please enter a valid URL.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = "";
      _results = {};
      _progress = 0.1;
    });

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/scan"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"url": url}),
      );

      setState(() => _progress = 0.6);

      if (response.statusCode == 200) {
        setState(() {
          _results = json.decode(response.body);
          _progress = 1.0;
        });
      } else {
        setState(() => _error = "Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _error = "Error: $e");
    } finally {
      Future.delayed(Duration(seconds: 1), () {
        setState(() => _isLoading = false);
      });
    }
  }

  Widget _buildResults() {
    if (_isLoading) {
      return Column(
        children: [
          LinearProgressIndicator(value: _progress, minHeight: 8),
          SizedBox(height: 10),
          Text("Scanning... ${(100 * _progress).toInt()}%",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      );
    }

    if (_error.isNotEmpty) {
      return Text(_error, style: TextStyle(color: Colors.red, fontSize: 16));
    }

    if (_results.isEmpty) {
      return Text("No results yet. Enter a URL to start scanning.");
    }

    return Expanded(
      child: ListView(
        children: _results.entries.map((entry) {
          final vulnerability = entry.key;
          final result = entry.value;

          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vulnerability.toUpperCase(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                  ),
                  Divider(),
                  if (result is Map<String, dynamic>)
                    ...result.entries.map((subEntry) {
                      final key = subEntry.key;
                      final value = subEntry.value;

                      if (key == "results") {
                        return Column(
                          children: (value as List<dynamic>).map((item) {
                            final payload = item["payload"];
                            final vulnerable = item["vulnerable"];
                            return ListTile(
                              leading: Icon(
                                vulnerable ? Icons.warning : Icons.check_circle,
                                color: vulnerable ? Colors.red : Colors.green,
                              ),
                              title: Text("Payload: $payload"),
                              subtitle: Text(
                                vulnerable ? "Vulnerable" : "Not Vulnerable",
                                style: TextStyle(
                                    color:
                                        vulnerable ? Colors.red : Colors.green),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return ListTile(
                          title: Text("$key: $value"),
                        );
                      }
                    })
                  else
                    Text(
                      result.toString(),
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vulnerability Scanner"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Enter URL",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: scanUrl,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text("Scan", style: TextStyle(fontSize: 18)),
              ),
            ),
            SizedBox(height: 20),
            _buildResults(),
          ],
        ),
      ),
    );
  }
}
