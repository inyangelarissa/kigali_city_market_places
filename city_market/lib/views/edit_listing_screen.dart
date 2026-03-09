import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:city_market/models/listing.dart';
import 'package:city_market/services/listing_service.dart';
import 'package:city_market/views/map_screen.dart';
import 'package:geolocator/geolocator.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  final Listing listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  EditListingScreenState createState() => EditListingScreenState();
}

class EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  
  String? _selectedCategory;
  bool _isLoading = false;

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listing.name);
    _addressController = TextEditingController(text: widget.listing.address);
    _contactController = TextEditingController(text: widget.listing.contactNumber);
    _descriptionController = TextEditingController(text: widget.listing.description);
    _latitudeController = TextEditingController(
      text: widget.listing.coordinates.latitude.toStringAsFixed(6),
    );
    _longitudeController = TextEditingController(
      text: widget.listing.coordinates.longitude.toStringAsFixed(6),
    );
    _selectedCategory = _categories.contains(widget.listing.category)
        ? widget.listing.category
        : 'Other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final lat = double.tryParse(_latitudeController.text);
      final lng = double.tryParse(_longitudeController.text);
      
      if (lat == null || lng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter valid coordinates'),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final updatedListing = Listing(
        id: widget.listing.id,
        name: _nameController.text,
        category: _selectedCategory!,
        address: _addressController.text,
        contactNumber: _contactController.text,
        description: _descriptionController.text,
        coordinates: GeoPoint(lat, lng),
        createdBy: widget.listing.createdBy,
        timestamp: widget.listing.timestamp,
      );

      try {
        await ref.read(listingServiceProvider).updateListing(updatedListing);
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).pop(); // Go back to directory
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully')),
        );
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
        title: const Text('Edit Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit',
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
                  'listing.',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
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
                    const SizedBox(height: 16),
                    
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
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final position = await Navigator.of(context).push<Position>(
                            MaterialPageRoute(builder: (context) => const MapScreen()),
                          );
                          if (position != null && mounted) {
                            setState(() {
                              _latitudeController.text = position.latitude.toStringAsFixed(6);
                              _longitudeController.text = position.longitude.toStringAsFixed(6);
                            });
                          }
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Select on Map'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
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
                            Text('Save Changes'),
                            SizedBox(width: 8),
                            Icon(Icons.check, size: 20),
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
