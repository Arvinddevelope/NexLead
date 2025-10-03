import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:nextlead/core/constants/app_colors.dart';
import 'package:nextlead/core/constants/app_texts.dart';
import 'package:nextlead/core/utils/validators.dart';
import 'package:nextlead/data/models/lead_model.dart';
import 'package:nextlead/providers/lead_provider.dart';
import 'package:nextlead/ui/widgets/custom_button.dart';

class LeadFormScreen extends StatefulWidget {
  final Lead? lead; // null for new lead, provided for edit

  const LeadFormScreen({super.key, this.lead});

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;
  late final TextEditingController _sourceController;
  late final TextEditingController _notesController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _nextFollowUpController;
  late final TextEditingController _locationController;

  String _selectedStatus = 'New';
  String _selectedSource = '';
  DateTime? _nextFollowUpDate;
  TimeOfDay? _nextFollowUpTime;
  double? _latitude;
  double? _longitude;
  String _locationAddress = '';

  // Enhanced status options to match Airtable validation
  final List<String> _statusOptions = [
    'New',
    'Contacted',
    'Qualified',
    'Proposal',
    'Won',
    'Lost'
  ];

  // Enhanced source options to match Airtable validation
  final List<String> _sourceOptions = [
    'Website',
    'Referral',
    'Social Media',
    'Event',
    'Other'
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    if (widget.lead != null) {
      _nameController = TextEditingController(text: widget.lead!.name);
      _emailController = TextEditingController(text: widget.lead!.email);
      _phoneController = TextEditingController(text: widget.lead!.phone);
      _companyController = TextEditingController(text: widget.lead!.company);
      _sourceController = TextEditingController(text: widget.lead!.source);
      _notesController = TextEditingController(text: widget.lead!.notes);
      _contactNameController =
          TextEditingController(text: widget.lead!.contactName ?? '');
      _locationController =
          TextEditingController(text: widget.lead!.locationAddress ?? '');
      _selectedStatus = widget.lead!.status;
      _selectedSource = widget.lead!.source;
      _nextFollowUpDate = widget.lead!.nextFollowUp;
      _latitude = widget.lead!.latitude;
      _longitude = widget.lead!.longitude;
      _locationAddress = widget.lead!.locationAddress ?? '';
    } else {
      _nameController = TextEditingController();
      _emailController = TextEditingController();
      _phoneController = TextEditingController();
      _companyController = TextEditingController();
      _sourceController = TextEditingController();
      _notesController = TextEditingController();
      _contactNameController = TextEditingController();
      _locationController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _sourceController.dispose();
    _notesController.dispose();
    _contactNameController.dispose();
    _nextFollowUpController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextFollowUpDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && mounted) {
      setState(() {
        _nextFollowUpDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _nextFollowUpTime ?? TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _nextFollowUpTime = picked;
      });
    }
  }

  DateTime? _combineDateAndTime() {
    if (_nextFollowUpDate == null) return null;

    final now = DateTime.now();
    return DateTime(
      _nextFollowUpDate!.year,
      _nextFollowUpDate!.month,
      _nextFollowUpDate!.day,
      _nextFollowUpTime?.hour ?? now.hour,
      _nextFollowUpTime?.minute ?? now.minute,
    );
  }

  /// Check if location permissions are granted
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled.'),
            backgroundColor: AppColors.statusLost,
          ),
        );
      }
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied.'),
              backgroundColor: AppColors.statusLost,
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
            backgroundColor: AppColors.statusLost,
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Getting current location...'),
            backgroundColor: AppColors.primary,
          ),
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Get address from coordinates
      await _getAddressFromCoordinates();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: AppColors.statusLost,
          ),
        );
      }
    }
  }

  /// Get address from coordinates
  Future<void> _getAddressFromCoordinates() async {
    if (_latitude == null || _longitude == null) return;

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        _latitude!,
        _longitude!,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        final address =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';

        setState(() {
          _locationAddress = address;
          _locationController.text = address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting address: $e'),
            backgroundColor: AppColors.statusLost,
          ),
        );
      }
    }
  }

  Future<void> _saveLead() async {
    if (_formKey.currentState!.validate()) {
      final leadProvider = Provider.of<LeadProvider>(context, listen: false);

      try {
        final now = DateTime.now();
        final combinedDateTime = _combineDateAndTime();

        if (widget.lead == null) {
          // Create new lead
          final newLead = Lead(
            id: '', // Will be assigned by backend
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            company: _companyController.text.trim(),
            source: _selectedSource.isEmpty
                ? _sourceController.text.trim()
                : _selectedSource,
            status: _selectedStatus,
            notes: _notesController.text.trim(),
            createdAt: now,
            updatedAt: now,
            nextFollowUp: combinedDateTime,
            contactName: _contactNameController.text.trim(),
            // Location fields
            latitude: _latitude,
            longitude: _longitude,
            locationAddress: _locationAddress,
          );

          await leadProvider.createLead(newLead);
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        } else {
          // Update existing lead
          final updatedLead = widget.lead!.copyWith(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            company: _companyController.text.trim(),
            source: _selectedSource.isEmpty
                ? _sourceController.text.trim()
                : _selectedSource,
            status: _selectedStatus,
            notes: _notesController.text.trim(),
            updatedAt: now,
            nextFollowUp: combinedDateTime,
            contactName: _contactNameController.text.trim(),
            // Location fields
            latitude: _latitude,
            longitude: _longitude,
            locationAddress: _locationAddress,
          );

          await leadProvider.updateLead(updatedLead);
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.statusLost,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lead == null ? AppTexts.addLead : AppTexts.editLead),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppTexts.nameLabel,
                  hintText: AppTexts.nameHint,
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 16),

              // Contact Name
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'Enter contact person name',
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: AppTexts.emailLabel,
                  hintText: AppTexts.emailHint,
                ),
                validator: Validators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: AppTexts.phoneHint,
                ),
                validator: Validators.validatePhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Company
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company',
                  hintText: AppTexts.companyHint,
                ),
              ),
              const SizedBox(height: 16),

              // Source - Dropdown with predefined options
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Source',
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSource.isEmpty ? null : _selectedSource,
                    isDense: true,
                    hint: const Text('Select or type source'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSource = newValue ?? '';
                      });
                    },
                    items: [
                      // Add "Other" option to allow custom input
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Type custom source'),
                      ),
                      // Predefined source options
                      ..._sourceOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Custom Source Input (visible when "Other" is selected or no predefined option is selected)
              if (_selectedSource.isEmpty)
                TextFormField(
                  controller: _sourceController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Source',
                    hintText: 'Enter custom source',
                  ),
                ),
              if (_selectedSource.isEmpty) const SizedBox(height: 16),

              // Status
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Status',
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isDense: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedStatus = newValue;
                        });
                      }
                    },
                    items: _statusOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Next Follow-up Date
              ListTile(
                title: const Text('Next Follow-up'),
                subtitle: Text(
                  _nextFollowUpDate == null
                      ? 'Not set'
                      : '${_nextFollowUpDate!.toLocal()}'.split(' ')[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Next Follow-up Time
              if (_nextFollowUpDate != null)
                ListTile(
                  title: const Text('Follow-up Time'),
                  subtitle: Text(
                    _nextFollowUpTime == null
                        ? 'Not set'
                        : _nextFollowUpTime!.format(context),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: _selectTime,
                ),
              if (_nextFollowUpDate != null) const SizedBox(height: 16),

              // Location
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Current Location Button
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Get Current Location'),
              ),
              const SizedBox(height: 16),

              // Location Address
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location Address',
                  hintText: 'Enter location address',
                ),
                onChanged: (value) {
                  setState(() {
                    _locationAddress = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: AppTexts.notesHint,
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              Consumer<LeadProvider>(
                builder: (context, leadProvider, child) {
                  return CustomButton(
                    text: AppTexts.saveLead,
                    onPressed: leadProvider.isLoading ? () {} : _saveLead,
                    isLoading: leadProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
