import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:city_market/models/listing.dart';
import 'package:city_market/services/auth_service.dart';
import 'package:city_market/views/map_screen.dart';
import 'package:city_market/services/listing_service.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  CreateListingScreenState createState() => CreateListingScreenState();
}

class CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  String? _selectedCategory;
  Position? _currentPosition;
  bool _isLoading = false;

  // Category options
  final List<String> _categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Hotel',
    'Bank',
    'Pharmacy',
    'Shopping Mall',
    'School',
    'Other',
  ];

  void _onMapLocationSelected(Position position) {
    setState(() {
      _currentPosition = position;
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
    });
  }

  double? _getLatitude() {
    if (_latitudeController.text.isNotEmpty) {
      return double.tryParse(_latitudeController.text);
    }
    return _currentPosition?.latitude;
  }

  double? _getLongitude() {
    if (_longitudeController.text.isNotEmpty) {
      return double.tryParse(_longitudeController.text);
    }
    return _currentPosition?.longitude;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final lat = _getLatitude();
      final lng = _getLongitude();
      
      if (lat == null || lng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter coordinates or select location on map'),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a category'),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      final user = ref.read(authServiceProvider).currentUser;
      if (user == null) return;

      final newListing = Listing(
        name: _nameController.text,
        category: _selectedCategory!,
        address: _addressController.text,
        contactNumber: _contactController.text,
        description: _descriptionController.text,
        coordinates: GeoPoint(lat, lng),
        createdBy: user.uid,
        timestamp: Timestamp.now(),
      );

      try {
        await ref.read(listingServiceProvider).createListing(newListing);
        if (!mounted) return;
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Listing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                ).createShader(bounds),
                child: Text(
                  'new listing.',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the details below to add a new place or service.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Place/Service Name',
                  prefixIcon: Icon(Icons.business_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              
              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Select Category',
                  prefixIcon: Icon(Icons.category_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              
              // Address Field
              TextFormField(
                controller: _addressController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 16),
              
              // Contact Field
              TextFormField(
                controller: _contactController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a contact number' : null,
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Description',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 24),
              
              // Location Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.map_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Geographic Coordinates',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter coordinates manually or select on map',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Latitude and Longitude Fields
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              hintText: 'Latitude',
                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: InputDecoration(
                              hintText: 'Longitude',
                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Map Selection Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final position = await Navigator.of(context).push<Position>(
                            MaterialPageRoute(builder: (context) => const MapScreen()),
                          );
                          if (position != null && mounted) {
                            _onMapLocationSelected(position);
                          }
                        },
                        icon: const Icon(Icons.map),
                        label: Text(
                          _currentPosition == null 
                              ? 'Select on Map' 
                              : 'Change Location on Map'
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Create Listing'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
