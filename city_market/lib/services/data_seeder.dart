import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import 'auth_service.dart';

class DataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  
  static const String _listingsCollection = 'listings';

  // Sample Kigali locations with real coordinates
  final List<Map<String, dynamic>> _sampleListings = [
    {
      'name': 'King Faisal Hospital',
      'category': 'Hospital',
      'address': 'KG 641 St, Kigali, Rwanda',
      'contactNumber': '+250 788 123 456',
      'description': 'A leading private hospital in Kigali providing comprehensive medical services with modern facilities and experienced medical staff.',
      'coordinates': const GeoPoint(-1.9591, 30.0945),
    },
    {
      'name': 'Kigali City Police Headquarters',
      'category': 'Police Station',
      'address': 'KN 4 Ave, Kigali, Rwanda',
      'contactNumber': '+250 788 234 567',
      'description': 'Main police headquarters providing security services and maintaining law and order in Kigali city.',
      'coordinates': const GeoPoint(-1.9539, 30.0606),
    },
    {
      'name': 'Kigali Public Library',
      'category': 'Library',
      'address': 'KN 2 St, Kigali, Rwanda',
      'contactNumber': '+250 788 345 678',
      'description': 'Modern public library with extensive collection of books, digital resources, and study spaces.',
      'coordinates': const GeoPoint(-1.9529, 30.0589),
    },
    {
      'name': 'The Hut Restaurant',
      'category': 'Restaurant',
      'address': 'KN 3 Ave, Kiyovu, Kigali',
      'contactNumber': '+250 788 456 789',
      'description': 'Popular restaurant serving traditional Rwandan cuisine and international dishes in a cozy atmosphere.',
      'coordinates': const GeoPoint(-1.9488, 30.0595),
    },
    {
      'name': 'Question Coffee Café',
      'category': 'Café',
      'address': 'KN 4 St, Kigali, Rwanda',
      'contactNumber': '+250 788 567 890',
      'description': 'Trendy café serving specialty Rwandan coffee, pastries, and light meals in a modern setting.',
      'coordinates': const GeoPoint(-1.9556, 30.0589),
    },
    {
      'name': 'Nyabugogo Park',
      'category': 'Park',
      'address': 'Nyabugogo, Kigali, Rwanda',
      'contactNumber': '+250 788 678 901',
      'description': 'Beautiful public park with walking trails, playgrounds, and picnic areas for families.',
      'coordinates': const GeoPoint(-1.9696, 30.0582),
    },
    {
      'name': 'Kigali Genocide Memorial',
      'category': 'Tourist Attraction',
      'address': 'KG 14 Ave, Gisozi, Kigali',
      'contactNumber': '+250 788 789 012',
      'description': 'A memorial and educational center commemorating the 1994 genocide against the Tutsi.',
      'coordinates': const GeoPoint(-1.9636, 30.0589),
    },
    {
      'name': 'Serena Hotel Kigali',
      'category': 'Hotel',
      'address': 'KN 3 Ave, Kigali, Rwanda',
      'contactNumber': '+250 788 890 123',
      'description': 'Luxury 5-star hotel offering premium accommodation, dining, and conference facilities.',
      'coordinates': const GeoPoint(-1.9439, 30.0595),
    },
    {
      'name': 'Bank of Kigali',
      'category': 'Bank',
      'address': 'KN 2 Ave, Kigali, Rwanda',
      'contactNumber': '+250 788 901 234',
      'description': 'Leading commercial bank in Rwanda offering comprehensive banking services.',
      'coordinates': const GeoPoint(-1.9513, 30.0588),
    },
    {
      'name': 'Pharma Ltd',
      'category': 'Pharmacy',
      'address': 'KG 547 St, Kigali, Rwanda',
      'contactNumber': '+250 788 012 345',
      'description': 'Well-stocked pharmacy with prescription medicines, over-the-counter drugs, and medical supplies.',
      'coordinates': const GeoPoint(-1.9578, 30.0603),
    },
    {
      'name': 'Kigali City Tower',
      'category': 'Shopping Mall',
      'address': 'KN 4 Ave, Kigali, Rwanda',
      'contactNumber': '+250 788 123 456',
      'description': 'Modern shopping complex with retail stores, restaurants, cinema, and entertainment facilities.',
      'coordinates': const GeoPoint(-1.9536, 30.0606),
    },
    {
      'name': 'Kigali International School',
      'category': 'School',
      'address': 'KG 568 Ave, Kiyovu, Kigali',
      'contactNumber': '+250 788 234 567',
      'description': 'International school offering quality education with modern facilities and experienced teachers.',
      'coordinates': const GeoPoint(-1.9462, 30.0581),
    },
  ];

  Future<void> seedSampleData() async {
    try {
      User? user = _authService.currentUser;
      
      if (user == null) {
        debugPrint('❌ No user logged in. Please login first to seed data.');
        return;
      }

      debugPrint('✅ User authenticated: ${user.email} (UID: ${user.uid})');
      debugPrint('📱 Seeding sample listings as system data');

      debugPrint('🔍 Checking if system data already exists...');
      final existingSnapshot = await _firestore
          .collection(_listingsCollection)
          .where('createdBy', isEqualTo: 'system')
          .limit(1)
          .get();

      debugPrint('📊 Existing system documents found: ${existingSnapshot.docs.length}');
      
      if (existingSnapshot.docs.isNotEmpty) {
        debugPrint('⚠️ System sample data already exists. Skipping seeding.');
        return;
      }

      debugPrint('📝 Creating batch write for ${_sampleListings.length} listings...');
      final batch = _firestore.batch();
      
      for (final sampleListing in _sampleListings) {
        final docRef = _firestore.collection(_listingsCollection).doc();
        final listing = Listing(
          id: docRef.id,
          name: sampleListing['name'],
          category: sampleListing['category'],
          address: sampleListing['address'],
          contactNumber: sampleListing['contactNumber'],
          description: sampleListing['description'],
          coordinates: sampleListing['coordinates'],
          createdBy: 'system',
          timestamp: Timestamp.now(),
        );
        
        debugPrint('📄 Adding to batch: ${listing.name} (${docRef.id})');
        batch.set(docRef, listing.toMap());
      }

      debugPrint('💾 Committing batch to Firestore...');
      await batch.commit();
      debugPrint('✅ Successfully seeded ${_sampleListings.length} sample listings!');
      
    } catch (e) {
      debugPrint('❌ Error seeding data: $e');
      debugPrint('🔧 Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> clearAllListings() async {
    try {
      User? user = _authService.currentUser;
      
      if (user == null) {
        debugPrint('No user logged in.');
        return;
      }

      final snapshot = await _firestore
          .collection(_listingsCollection)
          .where('createdBy', isEqualTo: user.uid)
          .get();

      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('Cleared ${snapshot.docs.length} listings for user: ${user.email}');
      
    } catch (e) {
      debugPrint('Error clearing listings: $e');
    }
  }

  Future<void> seedIfEmpty() async {
    try {
      User? user = _authService.currentUser;
      
      if (user == null) {
        debugPrint('No user logged in.');
        return;
      }

      final snapshot = await _firestore
          .collection(_listingsCollection)
          .where('createdBy', isEqualTo: 'system')
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('No system listings found. Seeding sample data...');
        await seedSampleData();
      } else {
        debugPrint('System data already exists with ${snapshot.docs.length} listings.');
      }
      
    } catch (e) {
      debugPrint('Error checking/seeding data: $e');
    }
  }
}
