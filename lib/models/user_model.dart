class UserModel {
  final String id;
  final String email;
  final String fullName;
  final bool isAdmin;
  final bool isActive;

  // extra profile fields
  final String? dob;
  final String? gender;
  final String? location;
  final String? experience;
  final String? preferredTime;
  final String? emergencyContact;
  final String? profileImageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.isAdmin = false,
    this.isActive = true, // default: active
    this.dob,
    this.gender,
    this.location,
    this.experience,
    this.preferredTime,
    this.emergencyContact,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,

      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      location: json['location'] as String?,
      experience: json['experience'] as String?,
      preferredTime: json['preferred_time'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'is_admin': isAdmin,
      'is_active': isActive,
      'dob': dob,
      'gender': gender,
      'location': location,
      'experience': experience,
      'preferred_time': preferredTime,
      'emergency_contact': emergencyContact,
      'profile_image_url': profileImageUrl,
    };
  }

  /// 🔹 Create a new UserModel changing only some fields.
  UserModel copyWith({bool? isAdmin, bool? isActive}) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName,
      isAdmin: isAdmin ?? this.isAdmin,
      isActive: isActive ?? this.isActive,
      dob: dob,
      gender: gender,
      location: location,
      experience: experience,
      preferredTime: preferredTime,
      emergencyContact: emergencyContact,
      profileImageUrl: profileImageUrl,
    );
  }
}
