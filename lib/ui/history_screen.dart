import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<List<Map<String, String>>> _loadResults() async {
    const storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    String? storedResults =
        await storage.read(key: 'results') ?? prefs.getString('results');

    if (storedResults != null) {
      List<dynamic> jsonList = jsonDecode(storedResults);
      return jsonList.map((item) {
        return Map<String, String>.from(item);
      }).toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History",
          style: TextStyle(fontSize: 20.0, color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _loadResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return const Center(
              child: Text('No history available'),
            );
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return ListTile(
                title: Text("Input: ${result['expression']}"),
                subtitle: Text("Result: ${result['result']}"),
              );
            },
          );
        },
      ),
    );
  }
}
