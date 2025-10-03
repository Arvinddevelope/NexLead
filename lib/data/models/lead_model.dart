class Lead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String source;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextFollowUp;
  final String? userId;
  // New fields based on your requirements (only fields that exist in Airtable)
  final String? contactName;
  // Location fields
  final double? latitude;
  final double? longitude;
  final String? locationAddress;

  Lead({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.company,
    required this.source,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.nextFollowUp,
    this.userId,
    this.contactName,
    // Location fields
    this.latitude,
    this.longitude,
    this.locationAddress,
    // Note: Removed lastStatus and lastSource as they don't exist in Airtable
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      company: json['company'] as String,
      source: json['source'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      nextFollowUp: json['nextFollowUp'] != null
          ? DateTime.parse(json['nextFollowUp'] as String)
          : null,
      userId: json['userId'] as String?,
      contactName: json['contactName'] as String?,
      // Location fields
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationAddress: json['locationAddress'] as String?,
      // Note: Removed lastStatus and lastSource as they don't exist in Airtable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'source': source,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'nextFollowUp': nextFollowUp?.toIso8601String(),
      'userId': userId,
      'contactName': contactName,
      // Location fields
      'latitude': latitude,
      'longitude': longitude,
      'locationAddress': locationAddress,
      // Note: Removed lastStatus and lastSource as they don't exist in Airtable
    };
  }

  Lead copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? source,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? nextFollowUp,
    String? userId,
    String? contactName,
    // Location fields
    double? latitude,
    double? longitude,
    String? locationAddress,
    // Note: Removed lastStatus and lastSource as they don't exist in Airtable
  }) {
    return Lead(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      source: source ?? this.source,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextFollowUp: nextFollowUp ?? this.nextFollowUp,
      userId: userId ?? this.userId,
      contactName: contactName ?? this.contactName,
      // Location fields
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAddress: locationAddress ?? this.locationAddress,
      // Note: Removed lastStatus and lastSource as they don't exist in Airtable
    );
  }
}
