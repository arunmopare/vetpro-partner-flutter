import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expandable/expandable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'package:vetpro/Constants/Constants.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Entries'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Date Selector
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _changeDate(-1),
                  icon: const Icon(Icons.arrow_left),
                  label: const Text('Previous'),
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
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _changeDate(1),
                  icon: const Icon(Icons.arrow_right),
                  label: const Text('Next'),
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
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: const Center(
                                  child: Text(
                                    'No visit entries found.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
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
                              final latitude = entry['latitude'];
                              final longitude = entry['longitude'];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: ExpandableNotifier(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              child: Icon(
                                                Icons.location_on,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                entry['siteName'] ??
                                                    'No Site Name',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.pin_drop,
                                                color: (latitude != null &&
                                                        longitude != null)
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.grey,
                                              ),
                                              onPressed: latitude != null &&
                                                      longitude != null
                                                  ? () => _openInGoogleMaps(
                                                      latitude, longitude)
                                                  : null,
                                              tooltip: 'Open in Google Maps',
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          entry['siteLocation'] ??
                                              'No Site Location',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ExpandablePanel(
                                          header: const Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 8.0),
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
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          expanded: Text(
                                            entry['notes'] ?? 'No Notes',
                                            softWrap: true,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          theme: ExpandableThemeData(
                                            hasIcon: true,
                                            iconColor:
                                                Theme.of(context).primaryColor,
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
          ),
        ],
      ),
    );
  }
}
