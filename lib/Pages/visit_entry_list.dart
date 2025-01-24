import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expandable/expandable.dart'; // Ensure this package is added in pubspec.yaml

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
          : RefreshIndicator(
              onRefresh: fetchVisitEntries,
              child: visitEntries.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Center(child: Text('No visit entries found.')),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: visitEntries.length,
                      itemBuilder: (context, index) {
                        final entry = visitEntries[index];
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: ExpandableNotifier(
                              // Handles expand/collapse state
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry['siteName'] ?? 'No Site Name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    entry['siteLocation'] ?? 'No Site Location',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ExpandablePanel(
                                    header: Text(
                                      'Notes:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    collapsed: Text(
                                      entry['notes'] ?? 'No Notes',
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    expanded: Text(
                                      entry['notes'] ?? 'No Notes',
                                      softWrap: true,
                                    ),
                                    theme: ExpandableThemeData(
                                      hasIcon: true,
                                      iconColor: Colors.blue,
                                      tapBodyToExpand: true,
                                      tapBodyToCollapse: true,
                                      tapHeaderToExpand: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
