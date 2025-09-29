class UserModel {
  final String id;
  final String? email; // comes from Supabase Auth, not profiles
  final String? fullName;
  final String? profilePictureUrl;
  final String? dob;
  final String? gender;
  final String? location;
  final String? experience;
  final String? preferredTime;
  final String? emergencyContact;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.profilePictureUrl,
    this.dob,
    this.gender,
    this.location,
    this.experience,
    this.preferredTime,
    this.emergencyContact,
  });

  /// Build a UserModel from a Supabase `profiles` row
  factory UserModel.fromJson(Map<String, dynamic> json, {String? email}) {
    return UserModel(
      id: json['id'] as String,
      email: email, //  inject from Supabase.auth.currentUser
      fullName: json['full_name'] as String?,
      profilePictureUrl: json['profile_image_url'] as String?, //  matches DB column
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      location: json['location'] as String?,
      experience: json['experience'] as String?,
      preferredTime: json['preferred_time'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
    );
  }

  /// Convert UserModel to JSON for Supabase insertion/updating
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'profile_image_url': profilePictureUrl,
      'dob': dob,
      'gender': gender,
      'location': location,
      'experience': experience,
      'preferred_time': preferredTime,
      'emergency_contact': emergencyContact,
      //  no email here, since it lives in auth.users
    };
  }
}
