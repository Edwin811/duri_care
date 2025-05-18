import 'package:duri_care/core/resources/resources.dart';
import 'package:duri_care/features/management_user/user_management_controller.dart';
import 'package:duri_care/models/role_model.dart';
import 'package:duri_care/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final List<RoleModel> roles;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const UserListItem({
    super.key,
    required this.user,
    required this.roles,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColor.greenPrimary.withAlpha(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullname ?? 'No Name',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? 'No Email',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_ind_outlined,
                          size: 18,
                          color: AppColor.greenPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Role: ${user.roleName == 'employee' ? 'Pegawai' : user.roleName}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Hapus User',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.profileUrl != null && user.profileUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(user.profileUrl!),
      );
    } else {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppColor.greenPrimary,
        child: Text(
          _getInitials(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  String _getInitials() {
    if (user.fullname == null || user.fullname!.isEmpty) {
      return '?';
    }

    final nameParts = user.fullname!.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    }

    return user.fullname![0].toUpperCase();
  }
}
