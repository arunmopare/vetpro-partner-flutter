import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:vetpro/Constants/Constants.dart';

class AddVisitEntryPage extends StatefulWidget {
  @override
  _AddVisitEntryPageState createState() => _AddVisitEntryPageState();
}

class _AddVisitEntryPageState extends State<AddVisitEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _siteNameController = TextEditingController();
  final TextEditingController _siteLocationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _saveVisitEntry() async {
    if (_formKey.currentState!.validate()) {
      // Hide keyboard
      FocusScope.of(context).unfocus();

      setState(() {
        _isSubmitting = true;
      });

      // Get Location
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData locationData = await location.getLocation();

      final siteName = _siteNameController.text;
      final siteLocation = _siteLocationController.text;
      final notes = _notesController.text;

      const String backendUrl = Constants.BASE_API_URL + '/visit-entry';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      try {
        final response = await http.post(
          Uri.parse(backendUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'siteName': siteName,
            'siteLocation': siteLocation,
            'notes': notes,
            'latitude': locationData.latitude,
            'longitude': locationData.longitude,
          }),
        );

        setState(() {
          _isSubmitting = false;
        });

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Visit entry saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _formKey.currentState?.reset();
          _siteNameController.clear();
          _siteLocationController.clear();
          _notesController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save visit entry.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if this page can be popped (i.e., it was pushed onto the navigation stack)
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6600).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    if (canPop)
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xFFFF6600)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    if (canPop) SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Visit Entry',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          'Create a new visit record',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        // Site Name Field
                        _buildInputLabel('Site Name', Icons.business),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _siteNameController,
                          decoration: _buildInputDecoration(
                            hintText: 'Enter site name',
                            icon: Icons.business,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the site name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        // Site Location Field
                        _buildInputLabel('Site Location', Icons.location_on),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _siteLocationController,
                          decoration: _buildInputDecoration(
                            hintText: 'Enter site location',
                            icon: Icons.location_on,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the site location';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        // Notes Field
                        _buildInputLabel('Notes', Icons.notes),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          decoration: _buildInputDecoration(
                            hintText: 'Enter visit notes and details',
                            icon: Icons.notes,
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some notes';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        // Info Box
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6600).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFFFF6600).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFFFF6600),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your location will be captured automatically when you save this visit.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        // Save Button
                        _isSubmitting
                            ? Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      color: Color(0xFFFF6600),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Saving visit entry...',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFF6600),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    shadowColor:
                                        Color(0xFFFF6600).withOpacity(0.4),
                                  ),
                                  onPressed: _saveVisitEntry,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline,
                                          size: 24),
                                      SizedBox(width: 12),
                                      Text(
                                        'Save Visit Entry',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xFFFF6600)),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Color(0xFFFF6600)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Color(0xFFFF6600), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
