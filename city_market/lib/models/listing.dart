import 'package:cloud_firestore/cloud_firestore.dart';

class Listing {
  final String? id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final GeoPoint coordinates;
  final String createdBy;
  final Timestamp timestamp;

  Listing({
    this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.coordinates,
    required this.createdBy,
    required this.timestamp,
  });

  factory Listing.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Listing(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      coordinates: data['coordinates'] ?? const GeoPoint(0, 0),
      createdBy: data['createdBy'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'coordinates': coordinates,
      'createdBy': createdBy,
      'timestamp': timestamp,
    };
  }
}
