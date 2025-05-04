import 'dart:io';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service responsible for handling all profile-related database operations
class ProfileService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static ProfileService get to => Get.find<ProfileService>();

  /// Initializes the profile service
  Future<ProfileService> init() async {
    return this;
  }

  /// Gets the current user from Supabase auth
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Updates the user in auth and users table
  Future<void> updateUserProfile({
    String? email,
    String? password,
    required String fullname,
    String? profileImageUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updates = <String, dynamic>{};
    if (email != null) {
      updates['email'] = email;
    }
    if (password != null) {
      updates['password'] = password;
    }

    if (updates.isNotEmpty) {
      await _supabase.auth.updateUser(
        UserAttributes(email: updates['email'], password: updates['password']),
      );
    }

    final updateData = {
      'fullname': fullname,
      if (profileImageUrl != null) 'profile_image': profileImageUrl,
    };

    await _supabase.from('users').update(updateData).eq('id', user.id);
  }

  /// Uploads an image to Supabase storage
  Future<String?> uploadProfileImage(File file) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final filePath =
        'avatars/${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';

    final storageResponse = await _supabase.storage
        .from('duricare')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    if (storageResponse.isEmpty) {
      throw Exception('Upload to storage failed');
    }

    return _supabase.storage.from('duricare').getPublicUrl(filePath);
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
