import 'dart:io';
import 'package:duri_care/models/role_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:duri_care/core/utils/helpers/dialog_helper.dart';

class UserService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString roleName = ''.obs;

  static UserService get to => Get.find<UserService>();

  // ================= PROFILE =================
  Future<UserService> init() async {
    return this;
  }

  User? getCurrentUserRaw() {
    return _supabase.auth.currentUser;
  }

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

  Future<String?> uploadProfileImage(File file) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final filePath =
        'avatars/${user.id}_${DateTime.now().millisecondsSinceEpoch}.png';

    final storageResponse = await _supabase.storage
        .from('image')
        .upload(filePath, file, fileOptions: const FileOptions(upsert: true));

    if (storageResponse.isEmpty) {
      throw Exception('Upload to storage failed');
    }

    return filePath;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ================= USER MANAGEMENT =================
  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final dbUsers = await _supabase.from('extended_users').select();
      return dbUsers.map<UserModel>((u) => UserModel.fromJson(u)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String fullname,
    required String roleId,
    String? profileImage,
  }) async {
    try {
      final currentSession = _supabase.auth.currentSession;
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      final user = authResponse.user;
      if (user == null) throw Exception('Gagal membuat user');
      await _supabase.from('users').insert({
        'id': user.id,
        'fullname': fullname,
        'profile_image': profileImage,
      });
      await _supabase.from('user_roles').insert({
        'user_id': user.id,
        'role_id': roleId,
      });
      await signOut();
      if (currentSession != null && currentSession.refreshToken != null) {
        await _supabase.auth.setSession(currentSession.refreshToken!);
      }
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> updateUser({
    required String userId,
    String? fullname,
    String? profileImage,
    String? roleId,
  }) async {
    final updates = <String, dynamic>{};
    if (fullname != null) updates['fullname'] = fullname;
    if (profileImage != null) updates['profile_image'] = profileImage;
    if (roleId != null) updates['role_id'] = roleId;
    if (updates.isNotEmpty) {
      await _supabase.from('users').update(updates).eq('id', userId);
    }
  }

  Future<void> updateUserRole(String userId, String roleId) async {
    try {
      final existingRoles = await _supabase
          .from('user_roles')
          .select()
          .eq('user_id', userId);
      if (existingRoles.isNotEmpty) {
        await _supabase
            .from('user_roles')
            .update({'role_id': roleId})
            .eq('user_id', userId);
      } else {
        await _supabase.from('user_roles').insert({
          'user_id': userId,
          'role_id': roleId,
        });
      }
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('zone_users').delete().eq('user_id', userId);
      await _supabase.from('user_permissions').delete().eq('user_id', userId);
      await _supabase.from('user_roles').delete().eq('user_id', userId);
      await _supabase.from('users').delete().eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<List<dynamic>> getAllRoles() async {
    final data = await _supabase.from('roles').select('*');
    return data.map<RoleModel>((role) => RoleModel.fromJson(role)).toList();
  }

  Future<List<dynamic>> getAllPermissions() async {
    final data = await _supabase.from('permissions').select('*');
    return data;
  }

  Future<void> assignUserToZone(String userId, int zoneId) async {
    try {
      // Check if assignment already exists
      final existing =
          await _supabase
              .from('zone_users')
              .select()
              .eq('user_id', userId)
              .eq('zone_id', zoneId)
              .maybeSingle();

      if (existing == null) {
        // Only insert if it doesn't already exist
        await _supabase.from('zone_users').insert({
          'user_id': userId,
          'zone_id': zoneId,
        });
      }
    } catch (e) {
      throw Exception('Failed to assign user to zone: $e');
    }
  }

  Future<void> removeUserFromZone(String userId, int zoneId) async {
    try {
      await _supabase.from('zone_users').delete().match({
        'user_id': userId,
        'zone_id': zoneId,
      });
    } catch (e) {
      throw Exception('Failed to remove user from zone: $e');
    }
  }

  Future<void> assignPermissionToUser(
    String userId,
    String permissionId,
  ) async {
    try {
      // Check if permission already exists
      final existing =
          await _supabase
              .from('user_permissions')
              .select()
              .eq('user_id', userId)
              .eq('permission_id', permissionId)
              .maybeSingle();

      if (existing == null) {
        // Only insert if it doesn't already exist
        await _supabase.from('user_permissions').insert({
          'user_id': userId,
          'permission_id': permissionId,
        });
      }
    } catch (e) {
      throw Exception('Failed to assign permission to user: $e');
    }
  }

  Future<void> removePermissionFromUser(
    String userId,
    String permissionId,
  ) async {
    try {
      await _supabase.from('user_permissions').delete().match({
        'user_id': userId,
        'permission_id': permissionId,
      });
    } catch (e) {
      throw Exception('Failed to remove permission from user: $e');
    }
  }

  void loadUserFromMap(Map<String, dynamic> data) {
    if (data.containsKey('auth') && data.containsKey('user')) {
      currentUser.value = UserModel.fromCombinedJson(
        data['auth'],
        data['user'],
      );
    } else {
      currentUser.value = UserModel(
        id: data['id'] ?? '',
        email: data['email'],
        lastSignInAt:
            data['last_sign_in_at'] != null
                ? DateTime.tryParse(data['last_sign_in_at'])
                : null,
        fullname: data['fullname'],
        profileUrl: data['profile_image'],
        roleId: data['role_id'],
        roleName: data['role_name'],
      );
    }
  }

  Future<UserModel?> getCurrentUser({bool forceRefresh = false}) async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    // Return cached user unless force refresh is requested
    if (!forceRefresh && currentUser.value != null) {
      return currentUser.value;
    }

    try {
      final response =
          await _supabase
              .from('users')
              .select('fullname, profile_image')
              .eq('id', authUser.id)
              .maybeSingle();
      if (response != null) {
        final userModel = UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          lastSignInAt:
              authUser.lastSignInAt != null
                  ? DateTime.tryParse(authUser.lastSignInAt!)
                  : null,
          fullname: response['fullname'] ?? '',
          profileUrl: response['profile_image'],
        );
        currentUser.value = userModel;
        return userModel;
      } else {
        final userModel = UserModel(
          id: authUser.id,
          email: authUser.email ?? '',
          fullname: '',
          profileUrl: null,
        );
        currentUser.value = userModel;
        return userModel;
      }
    } catch (e) {
      DialogHelper.showErrorDialog(message: 'Gagal mendapatkan data user: $e');
      return null;
    }
  }

  Future<int> countStaff() async {
    try {
      final response = await _supabase
          .from('extended_users')
          .select()
          .neq('role_name', 'owner');
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> isEmailAlreadyExists(String email) async {
    final response = await _supabase.rpc(
      'is_email_exists',
      params: {'email_to_check': email},
    );
    return response as bool;
  }

  Future<void> updateZonePermission(
    String userId,
    int zoneId,
    String permissionKey,
    bool value,
  ) async {
    try {
      final existing =
          await _supabase
              .from('zone_users')
              .select()
              .eq('user_id', userId)
              .eq('zone_id', zoneId)
              .maybeSingle();

      if (existing != null) {
        // Update existing zone_users record with new permission value
        await _supabase
            .from('zone_users')
            .update({permissionKey: value})
            .eq('user_id', userId)
            .eq('zone_id', zoneId);
      } else {
        // If no record exists, create one with the permission
        await _supabase.from('zone_users').insert({
          'user_id': userId,
          'zone_id': zoneId,
          permissionKey: value,
        });
      }
    } catch (e) {
      throw Exception('Failed to update zone permission: $e');
    }
  }
}
