import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _historyCtrl = TextEditingController();
  String _selectedBloodGroup = '';
  bool _editing = false;

  final _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _historyCtrl.dispose();
    super.dispose();
  }

  void _startEditing() {
    final profile = ref.read(profileProvider).profile;
    if (profile != null) {
      _nameCtrl.text = profile.fullName;
      _historyCtrl.text = profile.medicalHistorySummary;
      _selectedBloodGroup = profile.bloodGroup;
    }
    setState(() => _editing = true);
  }

  void _save() {
    ref.read(profileProvider.notifier).updateProfile(
      fullName: _nameCtrl.text.trim(),
      medicalHistorySummary: _historyCtrl.text.trim(),
      bloodGroup: _selectedBloodGroup,
    );
    setState(() => _editing = false);
    ref.read(authProvider.notifier).refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    final pState = ref.watch(profileProvider);
    final profile = pState.profile;
    // Auth state is watched via profileProvider dependency

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: AppConstants.paddingLarge, right: AppConstants.paddingLarge, bottom: 32,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.darkGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Profile', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
                IconButton(
                  icon: Icon(_editing ? Icons.close : Icons.edit_rounded, color: Colors.white70),
                  onPressed: () {
                    if (_editing) { setState(() => _editing = false); } else { _startEditing(); }
                  },
                ),
              ]),
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                ),
                child: Center(child: Text(
                  _initials(profile?.fullName ?? 'U'),
                  style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 28),
                )),
              ),
              const SizedBox(height: 12),
              Text(profile?.fullName ?? 'User', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
              if (profile?.bloodGroup.isNotEmpty == true)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Blood: ${profile!.bloodGroup}', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                ),
            ]),
          ),
        ),
        // Content
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          sliver: SliverList(delegate: SliverChildListDelegate([
            if (_editing) ...[
              _buildEditForm(),
            ] else ...[
              _infoCard('Full Name', profile?.fullName ?? '-', Icons.person_outline),
              _infoCard('Blood Group', profile?.bloodGroup.isEmpty == true ? 'Not set' : profile?.bloodGroup ?? '-', Icons.bloodtype_outlined),
              _infoCard('Medical History', profile?.medicalHistorySummary.isEmpty == true ? 'Not set' : profile?.medicalHistorySummary ?? '-', Icons.medical_information_outlined),
              const SizedBox(height: 24),
            ],
            // Sign out
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text('Sign Out', style: AppTextStyles.body.copyWith(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 100),
          ])),
        ),
      ]),
    );
  }

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Edit Profile', style: AppTextStyles.heading3),
        const SizedBox(height: 20),
        TextFormField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Full Name', prefixIcon: Icon(Icons.person_outline, color: AppColors.textLight))),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedBloodGroup.isEmpty ? null : _selectedBloodGroup,
          decoration: const InputDecoration(hintText: 'Blood Group', prefixIcon: Icon(Icons.bloodtype_outlined, color: AppColors.textLight)),
          items: _bloodGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _selectedBloodGroup = v ?? ''),
        ),
        const SizedBox(height: 16),
        TextFormField(controller: _historyCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Medical History Summary', prefixIcon: Icon(Icons.medical_information_outlined, color: AppColors.textLight))),
        const SizedBox(height: 24),
        GradientButton(label: 'Save Changes', icon: Icons.check_rounded, onPressed: _save),
      ]),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500)),
        ])),
      ]),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
