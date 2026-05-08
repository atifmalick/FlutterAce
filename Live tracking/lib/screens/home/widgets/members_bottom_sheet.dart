import 'package:flutter/material.dart';
import '../../../models/models.dart';

class MembersBottomSheet extends StatelessWidget {
  final List<UserProfile> members;
  final Circle? circle;
  final Function(UserProfile) onMemberTap;

  const MembersBottomSheet({
    Key? key,
    required this.members,
    required this.circle,
    required this.onMemberTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Circle Members',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Members list
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: members.isEmpty
                ? const Center(
                    child: Text('No members in this circle'),
                  )
                : ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isOnline = member.isOnline;

                      return GestureDetector(
                        onTap: () => onMemberTap(member),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFBDBDBD),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Avatar
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFF1E88E5),
                                    backgroundImage: member.avatarUrl != null
                                        ? NetworkImage(member.avatarUrl!)
                                        : null,
                                    child: member.avatarUrl == null
                                        ? Text(
                                            member.displayName[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  if (isOnline)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF43A047),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.displayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.battery_full,
                                          size: 16,
                                          color: _getBatteryColor(
                                              member.batteryLevel),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${member.batteryLevel}%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF757575),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Location indicator
                              Icon(
                                Icons.location_on,
                                color: member.lastLat != null &&
                                        member.lastLng != null
                                    ? const Color(0xFF1E88E5)
                                    : const Color(0xFFBDBDBD),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int level) {
    if (level > 50) return const Color(0xFF43A047);
    if (level > 20) return const Color(0xFFFFA726);
    return const Color(0xFFD32F2F);
  }
}
