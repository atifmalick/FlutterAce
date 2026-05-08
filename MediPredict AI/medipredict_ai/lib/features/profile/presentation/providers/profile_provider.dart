import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_profile.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';

class ProfileState {
  final bool isLoading;
  final bool isSaving;
  final UserProfile? profile;
  final String? error;
  final bool saved;

  const ProfileState({
    this.isLoading = false,
    this.isSaving = false,
    this.profile,
    this.error,
    this.saved = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    UserProfile? profile,
    String? error,
    bool? saved,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      profile: profile ?? this.profile,
      error: error,
      saved: saved ?? this.saved,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final AuthRepositoryImpl _repository;

  ProfileNotifier(this._repository) : super(const ProfileState());

  void setProfile(UserProfile? profile) {
    if (profile != null) {
      state = state.copyWith(profile: profile);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? medicalHistorySummary,
    String? bloodGroup,
  }) async {
    if (state.profile == null) return;
    state = state.copyWith(isSaving: true, error: null, saved: false);
    try {
      final updated = state.profile!.copyWith(
        fullName: fullName,
        medicalHistorySummary: medicalHistorySummary,
        bloodGroup: bloodGroup,
      );
      await _repository.updateProfile(updated);
      state = state.copyWith(profile: updated, isSaving: false, saved: true);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final notifier = ProfileNotifier(AuthRepositoryImpl());
  final authProfile = ref.watch(authProvider).profile;
  notifier.setProfile(authProfile);
  return notifier;
});
