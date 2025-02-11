import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

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

      for (double i = 0.2; i <= 0.9; i += 0.1) {
        await Future.delayed(Duration(milliseconds: 200));
        setState(() => _progress = i);
      }

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

  Widget _buildProgressBar() {
    return Column(
      children: [
        Stack(
          children: [
            LinearProgressIndicator(
              value: _progress,
              minHeight: 25,
              backgroundColor: Colors.grey.shade700,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
            Positioned.fill(
              child: Center(
                child: Text("${(100 * _progress).toInt()}%",
                    style: GoogleFonts.robotoMono(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildResults() {
    if (_isLoading) return _buildProgressBar();
    if (_error.isNotEmpty) {
      return Text(_error,
          style: GoogleFonts.robotoMono(color: Colors.redAccent, fontSize: 16));
    }
    if (_results.isEmpty) {
      return Text("No results yet. Enter a URL to start scanning.",
          style: GoogleFonts.robotoMono(color: Colors.white));
    }
    return Expanded(
      child: ListView(
        children: _results.entries.map((entry) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 6,
            color: Colors.blueGrey.shade900,
            child: ListTile(
              title: Text(entry.key.toUpperCase(),
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent)),
              subtitle: Text(entry.value.toString(),
                  style: GoogleFonts.robotoMono(color: Colors.white70)),
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
        title: Text("Vulnerability Scanner", style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blueGrey.shade900,
        elevation: 6,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              style: GoogleFonts.robotoMono(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter URL",
                labelStyle: GoogleFonts.montserrat(color: Colors.white70),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link, color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: scanUrl,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.orangeAccent,
                  elevation: 6,
                ),
                child: Text("Scan",
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
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
