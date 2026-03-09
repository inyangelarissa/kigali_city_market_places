import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/listing.dart';
import 'auth_service.dart';

final listingServiceProvider = Provider<ListingService>((ref) => ListingService());

final listingsProvider = StreamProvider<List<Listing>>((ref) {
  return ref.watch(listingServiceProvider).getListings();
});

final myListingsProvider = StreamProvider<List<Listing>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final user = authService.currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(listingServiceProvider).getListingsByUser(user.uid);
});

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _listingsCollection = 'listings';

  Stream<List<Listing>> getListings() {
    return _firestore.collection(_listingsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  Stream<List<Listing>> getListingsByUser(String userId) {
    return _firestore.collection(_listingsCollection)
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList());
  }

  Future<void> createListing(Listing listing) async {
    await _firestore.collection(_listingsCollection).add(listing.toMap());
  }

  Future<void> updateListing(Listing listing) async {
    if (listing.id == null) return;
    await _firestore.collection(_listingsCollection).doc(listing.id).update(listing.toMap());
  }

  Future<void> deleteListing(String listingId) async {
    await _firestore.collection(_listingsCollection).doc(listingId).delete();
  }

  void dispose() {
    // Cleanup if needed
  }
}
