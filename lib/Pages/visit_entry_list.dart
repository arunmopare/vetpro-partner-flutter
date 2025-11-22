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
  const VisitEntryListPage({Key? key}) : super(key: key);

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6600).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visit Entries',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track and manage your visits',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Date Selector with Modern UI
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => _changeDate(-1),
                      icon: Icon(Icons.chevron_left, color: Color(0xFFFF6600)),
                      style: IconButton.styleFrom(
                        backgroundColor: Color(0xFFFF6600).withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6600), Color(0xFFFF8833)],
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF6600).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeDate(1),
                      icon: Icon(Icons.chevron_right, color: Color(0xFFFF6600)),
                      style: IconButton.styleFrom(
                        backgroundColor: Color(0xFFFF6600).withOpacity(0.1),
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
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFFFF6600)),
                            SizedBox(height: 16),
                            Text(
                              'Loading visits...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: Color(0xFFFF6600),
                        onRefresh: fetchVisitEntries,
                        child: visitEntries.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                itemCount: visitEntries.length,
                                physics: AlwaysScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _VisitEntryCard(
                                    entry: visitEntries[index],
                                    userName: state.userName,
                                    onMapTap: _openInGoogleMaps,
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: 100),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              SizedBox(height: 16),
              Text(
                'No visit entries found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pull down to refresh',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Separate stateless widget for better performance
class _VisitEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final String userName;
  final Function(double, double) onMapTap;

  const _VisitEntryCard({
    required this.entry,
    required this.userName,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    final latitude = entry['latitude'] as double;
    final longitude = entry['longitude'] as double;
    final createdOn = DateFormat('MMM dd, yyyy • hh:mm a')
        .format(DateTime.parse(entry['createdAt']).toLocal());
    final siteName = entry['siteName'] ?? 'No Site Name';
    final siteLocation = entry['siteLocation'] ?? 'No Site Location';
    final notes = entry['notes'] ?? 'No Notes';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetailsBottomSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFFF6600).withOpacity(0.15),
                    child: Icon(
                      Icons.person_outline,
                      color: Color(0xFFFF6600),
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 12, color: Colors.grey[500]),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                createdOn,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Map button
                  IconButton(
                    icon: Icon(Icons.location_on, color: Color(0xFFFF6600)),
                    onPressed: () => onMapTap(latitude, longitude),
                    tooltip: 'Open in Maps',
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 14),
              // Divider
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
              SizedBox(height: 14),
              // Site Name
              _InfoRow(
                icon: Icons.business_outlined,
                label: 'Site',
                value: siteName,
              ),
              SizedBox(height: 10),
              // Location
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: siteLocation,
              ),
              SizedBox(height: 10),
              // Notes preview
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 16,
                    color: Color(0xFFFF6600),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          notes,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF555555),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Tap to view more indicator
              if (notes.length > 100)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tap to view more',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFF6600),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context) {
    final latitude = entry['latitude'] as double;
    final longitude = entry['longitude'] as double;
    final createdOn = DateFormat('MMM dd, yyyy • hh:mm a')
        .format(DateTime.parse(entry['createdAt']).toLocal());
    final siteName = entry['siteName'] ?? 'No Site Name';
    final siteLocation = entry['siteLocation'] ?? 'No Site Location';
    final notes = entry['notes'] ?? 'No Notes';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Title
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6600), Color(0xFFFF8833)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.receipt_long,
                              color: Colors.white, size: 24),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Visit Details',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Complete visit information',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    // User & Date Info
                    _DetailSection(
                      icon: Icons.person_outline,
                      title: 'Recorded By',
                      content: userName,
                    ),
                    SizedBox(height: 16),
                    _DetailSection(
                      icon: Icons.calendar_today,
                      title: 'Visit Date & Time',
                      content: createdOn,
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    // Site Name
                    _DetailSection(
                      icon: Icons.business,
                      title: 'Site Name',
                      content: siteName,
                    ),
                    SizedBox(height: 16),
                    // Site Location
                    _DetailSection(
                      icon: Icons.location_on,
                      title: 'Site Location',
                      content: siteLocation,
                    ),
                    SizedBox(height: 16),
                    // Coordinates
                    _DetailSection(
                      icon: Icons.my_location,
                      title: 'GPS Coordinates',
                      content:
                          '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    // Notes
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note,
                                  color: Color(0xFFFF6600), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Visit Notes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            notes,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF555555),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onMapTap(latitude, longitude),
                            icon: Icon(Icons.location_on, size: 18),
                            label: Text('Open in Maps'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(0xFFFF6600),
                              side: BorderSide(color: Color(0xFFFF6600)),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, size: 18),
                            label: Text('Close'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF6600),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Detail section widget for bottom sheet
class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFFF6600).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFFFF6600), size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Reusable info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Color(0xFFFF6600),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
