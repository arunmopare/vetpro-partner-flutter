import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:vetpro/Constants/Constants.dart';
import 'package:vetpro/State/vet_pro_state.dart';

class VisitEntryListPage extends StatefulWidget {
  @override
  _VisitEntryListPageState createState() => _VisitEntryListPageState();
}

class _VisitEntryListPageState extends State<VisitEntryListPage> {
  List<dynamic> visitEntries = [];
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchVisitEntries();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VetProState>(context, listen: false).loadUserDetails();
    });
  }


  Future<void> fetchVisitEntries() async {
    const String backendUrl = Constants.BASE_API_URL + '/visit-entry';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    try {
      final response = await http.get(
        Uri.parse('$backendUrl?date=$formattedDate'),
        headers: {'Authorization': 'Bearer $token'},
      );

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

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
      isLoading = true;
    });
    fetchVisitEntries();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        isLoading = true;
      });
      fetchVisitEntries();
    }
  }

  Future<void> _openInGoogleMaps(double latitude, double longitude) async {
    final uri =
        Uri.https('www.google.com', '/maps', {'q': '$latitude,$longitude'});

    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<VetProState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Entries'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Date Selector with Modern UI
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeDate(-1),
                  icon: Icon(Icons.arrow_back_rounded,
                      color: Theme.of(context).primaryColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _changeDate(1),
                  icon: Icon(Icons.arrow_forward_rounded,
                      color: Theme.of(context).primaryColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Visit Entries List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchVisitEntries,
                    child: visitEntries.isEmpty
                        ? const Center(
                            child: Text(
                              'No visit entries found.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: visitEntries.length,
                            itemBuilder: (context, index) {
                              final entry = visitEntries[index];
                              final latitude = entry['latitude'];
                              final longitude = entry['longitude'];
                              final createdOn =
                                  DateFormat('MMM dd, yyyy hh:mm a').format(
                                      DateTime.parse(entry['createdAt'])
                                          .toLocal());
                              return Card(
                                elevation: 6.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.1),
                                          child: Icon(
                                            Icons.person,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        title: Text(
                                          state.userName ?? 'Unknown User',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        subtitle:
                                            Text('Created on: $createdOn'),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.pin_drop,
                                              color: Colors.blue),
                                          onPressed: () => _openInGoogleMaps(
                                              latitude, longitude),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Site Name: ${entry['siteName'] ?? 'No Site Name'}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "Site Location: ${entry['siteLocation'] ?? 'No Site Location'}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      ExpandablePanel(
                                        header: Text(
                                          'Notes:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        collapsed: Text(
                                          entry['notes'] ?? 'No Notes',
                                          softWrap: true,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        expanded: Text(
                                          entry['notes'] ?? 'No Notes',
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
