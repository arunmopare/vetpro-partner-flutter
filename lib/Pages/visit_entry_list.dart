import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expandable/expandable.dart';

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
        backgroundColor: Theme.of(context).primaryColor,
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
                          child: Center(
                            child: Text(
                              'No visit entries found.',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: visitEntries.length,
                      itemBuilder: (context, index) {
                        final entry = visitEntries[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: ExpandableNotifier(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        child: Icon(
                                          Icons.location_on,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry['siteName'] ?? 'No Site Name',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    entry['siteLocation'] ?? 'No Site Location',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ExpandablePanel(
                                    header: Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        'Notes:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    collapsed: Text(
                                      entry['notes'] ?? 'No Notes',
                                      softWrap: true,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    expanded: Text(
                                      entry['notes'] ?? 'No Notes',
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    theme: ExpandableThemeData(
                                      hasIcon: true,
                                      iconColor: Theme.of(context).primaryColor,
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
