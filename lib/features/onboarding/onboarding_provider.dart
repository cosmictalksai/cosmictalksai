import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/onboarding_state.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setBirthDate(DateTime date) {
    state = state.copyWith(birthDate: date);
  }

  void setBirthTime(TimeOfDay? time, {bool isUnknown = false}) {
    state = state.copyWith(birthTime: time, isTimeUnknown: isUnknown);
  }

  void setLocation(String name, double lat, double lon) {
    state = state.copyWith(birthPlace: name, latitude: lat, longitude: lon);
  }

  void nextStep() {
    if (state.isStepValid) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> submit() async {
    if (!state.isStepValid) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final userId = user.id;

      // 1. Update Profile
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'full_name': state.name,
        'email': user.email,
      });

      // 2. Save Birth Details
      // If unknown, we store 12:00:00 as a default but set the boolean flag
      final timeStr = state.isTimeUnknown || state.birthTime == null
          ? '12:00:00'
          : '${state.birthTime!.hour.toString().padLeft(2, '0')}:${state.birthTime!.minute.toString().padLeft(2, '0')}:00';

      await Supabase.instance.client.from('birth_details').insert({
        'user_id': userId,
        'date_of_birth': state.birthDate!.toIso8601String().split('T')[0],
        'time_of_birth': timeStr,
        'is_time_unknown': state.isTimeUnknown,
        'latitude': state.latitude,
        'longitude': state.longitude,
        'place_name': state.birthPlace,
        'timezone': DateTime.now().timeZoneName, // This will be refined with better location data later
      });

      state = state.copyWith(isLoading: false, currentStep: 5); 
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
