import 'dart:io';
import 'package:flutter/material.dart';
import '/controllers/profile_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = ProfileController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _preferredTimeController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;

  String _statusMessage = '';
  Color _statusColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Load user profile from Supabase
  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await _controller.fetchUserProfile(user.id);
    if (profile != null) {
      setState(() {
        _nameController.text = profile.fullName ?? '';
        _dobController.text = profile.dob ?? '';
        _genderController.text = profile.gender ?? '';
        _locationController.text = profile.location ?? '';
        _experienceController.text = profile.experience ?? '';
        _preferredTimeController.text = profile.preferredTime ?? '';
        _emergencyContactController.text = profile.emergencyContact ?? '';
        _profileImageUrl = profile.profilePictureUrl;

         // This line sets the profile image URL from the model
        _profileImageUrl = profile.profilePictureUrl; 


      });
    }
  }

  /// Pick profile image from gallery
  Future<void> _pickImage() async {
    final picked = await _controller.pickProfileImage();
    if (picked != null) setState(() => _profileImage = picked);
  }

  /// Save profile to Supabase
  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Validate full name
    final validationMessage = _controller.validateProfile(fullName: _nameController.text);
    if (validationMessage != null) {
      setState(() {
        _statusMessage = validationMessage;
        _statusColor = Colors.red;
      });
      return;
    }

    // Upload image if changed
    String? uploadedUrl = _profileImageUrl;
    if (_profileImage != null) {
      final url = await _controller.uploadProfileImage(_profileImage!, user.id);
      debugPrint('Uploaded image URL: $url');
      if (url != null) uploadedUrl = url;
    }

    // Upsert profile in Supabase
    final success = await _controller.updateProfile(
      uid: user.id,
      fullName: _nameController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _genderController.text.trim(),
      location: _locationController.text.trim(),
      experience: _experienceController.text.trim(),
      preferredTime: _preferredTimeController.text.trim(),
      emergencyContact: _emergencyContactController.text.trim(),
      profileImageUrl: uploadedUrl,
    );

    debugPrint('Profile update success: $success, URL saved: $uploadedUrl');

    if (success) {
      _profileImageUrl = uploadedUrl;
      await _loadUserProfile(); // Reload profile from Supabase
    }

    setState(() {
      _statusMessage = success ? "Profile updated successfully!" : "Failed to update profile";
      _statusColor = success ? Colors.green : Colors.red;
    });
  }

  /// Helper for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!) as ImageProvider
                        : null),
                backgroundColor: Colors.purple.withAlpha(153),
                child: _profileImage == null && _profileImageUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Status message
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 12),

            // Profile fields
            _buildTextField(controller: _nameController, label: "Full Name"),
            _buildTextField(controller: _dobController, label: "Date of Birth"),
            _buildTextField(controller: _genderController, label: "Gender"),
            _buildTextField(controller: _locationController, label: "Neighborhood (Nairobi)"),
            _buildTextField(controller: _experienceController, label: "Running Experience"),
            _buildTextField(controller: _preferredTimeController, label: "Preferred Running Time"),
            _buildTextField(controller: _emergencyContactController, label: "Emergency Contact"),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 156, 39, 176),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Save Profile", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
