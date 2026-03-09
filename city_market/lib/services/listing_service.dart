// lib/services/listing_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'listings';
  static const String _reviewsCollection = 'reviews';

  // Stream all listings (real-time)
  Stream<List<ListingModel>> streamAllListings() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromFirestore).toList());
  }

  // Stream listings by user
  Stream<List<ListingModel>> streamUserListings(String uid) {
    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromFirestore).toList());
  }

  // Get single listing
  Future<ListingModel?> getListing(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return ListingModel.fromFirestore(doc);
  }

  // Create listing
  Future<String> createListing(ListingModel listing) async {
    final docRef = await _firestore.collection(_collection).add(listing.toMap());
    return docRef.id;
  }

  // Update listing
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete listing
  Future<void> deleteListing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
    // Also delete reviews
    final reviews = await _firestore
        .collection(_reviewsCollection)
        .where('listingId', isEqualTo: id)
        .get();
    for (final doc in reviews.docs) {
      await doc.reference.delete();
    }
  }

  // Search listings
  Future<List<ListingModel>> searchListings(String query) async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
    return snapshot.docs.map(ListingModel.fromFirestore).toList();
  }

  // Get listings by category
  Stream<List<ListingModel>> streamListingsByCategory(String category) {
    if (category == 'All') return streamAllListings();
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromFirestore).toList());
  }

  // Add review
  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection(_reviewsCollection).add(review.toMap());

    // Update listing rating
    final reviews = await _firestore
        .collection(_reviewsCollection)
        .where('listingId', isEqualTo: review.listingId)
        .get();

    if (reviews.docs.isNotEmpty) {
      double total = 0;
      for (final doc in reviews.docs) {
        total += (doc.data()['rating'] ?? 0.0).toDouble();
      }
      final avgRating = total / reviews.docs.length;
      await _firestore.collection(_collection).doc(review.listingId).update({
        'rating': avgRating,
        'reviewCount': reviews.docs.length,
      });
    }
  }

  // Stream reviews for a listing
  Stream<List<ReviewModel>> streamReviews(String listingId) {
    return _firestore
        .collection(_reviewsCollection)
        .where('listingId', isEqualTo: listingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  // Seed sample data for Kigali
  Future<void> seedSampleData(String uid, String userName) async {
    final existingDocs = await _firestore.collection(_collection).limit(1).get();
    if (existingDocs.docs.isNotEmpty) return; // Already seeded

    final sampleListings = [
      ListingModel(
        id: '',
        name: 'Kimironko Café',
        category: 'Cafés',
        address: 'Kimironko, Kigali',
        contactNumber: '+250 788 123 456',
        description: 'Popular neighborhood café offering fresh coffee pastries and light meals in a cozy setting.',
        latitude: -1.9356,
        longitude: 30.1027,
        createdBy: uid,
        createdByName: userName,
        createdAt: DateTime.now(),
        rating: 4.3,
        reviewCount: 45,
      ),
      ListingModel(
        id: '',
        name: 'Green Bean Coffee',
        category: 'Cafés',
        address: 'Kacyiru, Kigali',
        contactNumber: '+250 788 234 567',
        description: 'Specialty coffee roasters serving premium Rwandan single-origin beans.',
        latitude: -1.9441,
        longitude: 30.0619,
        createdBy: uid,
        createdByName: userName,
        createdAt: DateTime.now(),
        rating: 4.0,
        reviewCount: 38,
      ),
      ListingModel(
        id: '',
        name: 'Umuganda Coffee',
        category: 'Cafés',
        address: 'Remera, Kigali',
        contactNumber: '+250 788 345 678',
        description: 'Community café with workspace and excellent Rwandan coffee.',
        latitude: -1.9547,
        longitude: 30.1152,
        createdBy: uid,
        createdByName: userName,
        createdAt: DateTime.now(),
        rating: 4.4,
        reviewCount: 62,
      ),
      ListingModel(
        id: '',
        name: 'King Faisal Hospital',
        category: 'Hospitals',
        address: 'Kacyiru, Kigali',
        contactNumber: '+250 252 582 421',
        description: 'Leading referral hospital providing comprehensive medical services.',
        latitude: -1.9392,
        longitude: 30.0617,
        createdBy: uid,
        createdByName: userName,
        createdAt: DateTime.now(),
        rating: 4.1,
        reviewCount: 120,
      ),
      ListingModel(
        id: '',
        name: 'Kigali Public Library',
        category: 'Libraries',
        address: 'Nyarugenge, Kigali',
        contactNumber: '+250 252 571 201',
        description: 'Modern public library with extensive collection and digital resources.',
        latitude: -1.9490,
        longitude: 30.0587,
        createdBy: uid,
        createdByName: userName,
        createdAt: DateTime.now(),
        rating: 4.5,
        reviewCount: 88,
      ),
      ListingModel(
        id: '',
        name: 'Nyandungu Urban Wetland',
        category: 'Parks',
        address: 'Kicukiro, Kigali',
        contactNumber: '+250 788 456 789',
        description: 'Beautiful urban eco-park featuring walking trails through restored wetlands.',
        latitude: -1.9825,
        longitude: 30.1012,
        createdBy: uid,
        createdByName: userName,
        createdAt: DateTime.now(),
        rating: 4.7,
        reviewCount: 215,
      ),
      ListingModel(
        id: '',
        name: 'Kigali Genocide Memorial',
        category: 'Tourist Attractions',
        address: 'Gisozi, Kigali',
        contactNumber: '+250 252 502 094',
        description: 'National memorial site honoring victims of the 1994 Genocide against the Tutsi.',
        latitude: -1.9293,
        longitude: 30.0607,
        createdBy: uid,
        createdByName: userName,
        createdAt: DateTime.now(),
        rating: 4.9,
        reviewCount: 540,
      ),
    ];

    for (final listing in sampleListings) {
      await _firestore.collection(_collection).add(listing.toMap());
    }
  }
}