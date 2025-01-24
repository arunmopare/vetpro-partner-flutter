import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:vetpro/Constants/Constants.dart';

class VisitEntryListPage extends StatefulWidget {
  @override
  _VisitEntryListPageState createState() => _VisitEntryListPageState();
}

class _VisitEntryListPageState extends State<VisitEntryListPage> {
  List<dynamic> visitEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVisitEntries();
  }

  Future<void> fetchVisitEntries() async {
    // Replace with your backend URL
    const String backendUrl = Constants.BASE_API_URL + '/visit-entry';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await http.get(Uri.parse(backendUrl),
          headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        setState(() {
          visitEntries = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load visit entries');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visit Entries'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : visitEntries.isEmpty
              ? Center(child: Text('No visit entries found.'))
              : ListView.builder(
                  itemCount: visitEntries.length,
                  itemBuilder: (context, index) {
                    final entry = visitEntries[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(entry['siteName'] ?? 'No Site Name'),
                        subtitle:
                            Text(entry['siteLocation'] ?? 'No Site Location'),
                        trailing: Text(entry['notes'] ?? 'No Notes'),
                      ),
                    );
                  },
                ),
    );
  }
}
