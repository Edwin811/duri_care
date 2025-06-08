import 'package:duri_care/core/resources/resources.dart';
import 'package:flutter/material.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final lowerRole = role.toLowerCase();
    String displayText;
    Color badgeColor;

    if (lowerRole == 'owner') {
      displayText = 'Owner';
      badgeColor = AppColor.greenSecondary;
    } else if (lowerRole == 'employee' || lowerRole == 'employe') {
      displayText = 'Employee';
      badgeColor = AppColor.yellowPrimary;
    } else if (lowerRole == 'user') {
      displayText = 'User';
      badgeColor = AppColor.yellowPrimary;
    } else {
      displayText = role.isNotEmpty ? role : 'User';
      badgeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      constraints: const BoxConstraints(minWidth: 50, maxWidth: 100),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: badgeColor,
      ),
      child: Text(
        displayText,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.none,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
