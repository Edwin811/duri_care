import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isOwner = role.toLowerCase() == 'owner';

    return Container(
      margin: const EdgeInsets.only(left: 6),
      width: 55,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isOwner ? AppColor.greenSecondary : AppColor.yellowPrimary,
      ),
      alignment: Alignment.center,
      child: Text(
        isOwner ? 'Owner' : 'Staff',
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
