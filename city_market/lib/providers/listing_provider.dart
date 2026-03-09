// lib/providers/listing_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';
import '../services/listing_service.dart';

enum ListingStatus { initial, loading, loaded, error }

class ListingProvider extends ChangeNotifier {
  final ListingService _service = ListingService();

  List<ListingModel> _allListings = [];
  List<ListingModel> _userListings = [];
  List<ListingModel> _filteredListings = [];
  final List<String> _bookmarkedIds = [];

  ListingStatus _status = ListingStatus.initial;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  StreamSubscription<List<ListingModel>>? _listingsSubscription;
  StreamSubscription<List<ListingModel>>? _userListingsSubscription;

  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get userListings => _userListings;
  List<ListingModel> get filteredListings => _filteredListings;
  List<ListingModel> get bookmarkedListings =>
      _allListings.where((l) => _bookmarkedIds.contains(l.id)).toList();
  ListingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _status == ListingStatus.loading;

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  // Initialize and subscribe to listings
  void initListings() {
    _status = ListingStatus.loading;
    notifyListeners();

    _listingsSubscription?.cancel();
    _listingsSubscription = _service.streamAllListings().listen(
      (listings) {
        _allListings = listings;
        _applyFilters();
        _status = ListingStatus.loaded;
        notifyListeners();
      },
      onError: (e) {
        _status = ListingStatus.error;
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  void initUserListings(String uid) {
    _userListingsSubscription?.cancel();
    _userListingsSubscription = _service.streamUserListings(uid).listen(
      (listings) {
        _userListings = listings;
        notifyListeners();
      },
    );
  }

  void _applyFilters() {
    List<ListingModel> result = List.from(_allListings);

    // Category filter
    if (_selectedCategory != 'All') {
      result = result.where((l) => l.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((l) =>
          l.name.toLowerCase().contains(query) ||
          l.category.toLowerCase().contains(query) ||
          l.address.toLowerCase().contains(query) ||
          l.description.toLowerCase().contains(query)).toList();
    }

    _filteredListings = result;
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void toggleBookmark(String id) {
    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
    } else {
      _bookmarkedIds.add(id);
    }
    notifyListeners();
  }

  Future<bool> createListing(ListingModel listing) async {
    try {
      await _service.createListing(listing);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateListing(id, data);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addReview(ReviewModel review) async {
    try {
      await _service.addReview(review);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Stream<List<ReviewModel>> streamReviews(String listingId) {
    return _service.streamReviews(listingId);
  }

  Future<void> seedSampleData(String uid, String userName) async {
    await _service.seedSampleData(uid, userName);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    _userListingsSubscription?.cancel();
    super.dispose();
  }
}