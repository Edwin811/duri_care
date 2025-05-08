import 'package:duri_care/models/permission_model.dart';
import 'package:duri_care/models/role_model.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManagementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserModel>> fetchAllUsers() async {
    try {
      final dbUsers = await _supabase.from('extended_users').select();
      debugPrint('DB Users FROM USER MANAGEMENT: $dbUsers');

      return dbUsers.map<UserModel>((u) => UserModel.fromJson(u)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Buat user baru + masukkan ke tabel users + user_roles
  Future<void> createUser({
    required String email,
    required String password,
    required String fullname,
    required String roleId,
    String? profileImage,
  }) async {
    try {
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

      // Insert into user_roles table
      await _supabase.from('user_roles').insert({
        'user_id': user.id,
        'role_id': roleId,
      });
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Perbarui informasi user di tabel `users`
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

  /// Update user role
  Future<void> updateUserRole(String userId, String roleId) async {
    try {
      // First check if record exists in user_roles
      final existingRoles = await _supabase
          .from('user_roles')
          .select()
          .eq('user_id', userId);

      if (existingRoles.isNotEmpty) {
        // Update existing record
        await _supabase
            .from('user_roles')
            .update({'role_id': roleId})
            .eq('user_id', userId);
      } else {
        // Insert new record
        await _supabase.from('user_roles').insert({
          'user_id': userId,
          'role_id': roleId,
        });
      }
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Hapus user
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

  /// Dapatkan semua role
  Future<List<RoleModel>> getAllRoles() async {
    final data = await _supabase.from('roles').select('*');
    return data.map<RoleModel>((r) => RoleModel.fromJson(r)).toList();
  }

  /// Dapatkan semua permission
  Future<List<PermissionModel>> getAllPermissions() async {
    final data = await _supabase.from('permissions').select('*');
    return data
        .map<PermissionModel>((p) => PermissionModel.fromMap(p))
        .toList();
  }

  /// Tambah akses zona ke user
  Future<void> assignUserToZone(String userId, int zoneId) async {
    await _supabase.from('zone_users').insert({
      'user_id': userId,
      'zone_id': zoneId,
    });
  }

  /// Hapus akses zona dari user
  Future<void> removeUserFromZone(String userId, int zoneId) async {
    await _supabase.from('zone_users').delete().match({
      'user_id': userId,
      'zone_id': zoneId,
    });
  }

  /// Tambah permission khusus ke user
  Future<void> assignPermissionToUser(
    String userId,
    String permissionId,
  ) async {
    await _supabase.from('user_permissions').insert({
      'user_id': userId,
      'permission_id': permissionId,
    });
  }

  /// Hapus permission khusus dari user
  Future<void> removePermissionFromUser(
    String userId,
    String permissionId,
  ) async {
    await _supabase.from('user_permissions').delete().match({
      'user_id': userId,
      'permission_id': permissionId,
    });
  }
}
