import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<void> _saveVisitEntry() async {
    if (_formKey.currentState!.validate()) {
      final siteName = _siteNameController.text;
      final siteLocation = _siteLocationController.text;
      final notes = _notesController.text;

      // Replace with your backend URL
      const String backendUrl = Constants.BASE_API_URL + '/visit-entry';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      try {
        final response = await http.post(
          Uri.parse(backendUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'siteName': siteName,
            'siteLocation': siteLocation,
            'notes': notes,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Visit entry saved successfully!')),
          );
          // Navigator.pop(context); // Return to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save visit entry.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Visit Entry'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _siteNameController,
                decoration: InputDecoration(labelText: 'Site Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the site name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _siteLocationController,
                decoration: InputDecoration(labelText: 'Site Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the site location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some notes';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveVisitEntry,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
