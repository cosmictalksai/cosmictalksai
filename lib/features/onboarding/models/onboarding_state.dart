import 'package:flutter/material.dart';

class OnboardingState {
  final String name;
  final DateTime? birthDate;
  final TimeOfDay? birthTime;
  final bool isTimeUnknown;
  final String? birthPlace;
  final double? latitude;
  final double? longitude;
  final int currentStep;
  final bool isLoading;
  final String? errorMessage;

  OnboardingState({
    this.name = '',
    this.birthDate,
    this.birthTime,
    this.isTimeUnknown = false,
    this.birthPlace,
    this.latitude,
    this.longitude,
    this.currentStep = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    String? name,
    DateTime? birthDate,
    TimeOfDay? birthTime,
    bool? isTimeUnknown,
    String? birthPlace,
    double? latitude,
    double? longitude,
    int? currentStep,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      isTimeUnknown: isTimeUnknown ?? this.isTimeUnknown,
      birthPlace: birthPlace ?? this.birthPlace,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isStepValid {
    switch (currentStep) {
      case 0: return name.trim().isNotEmpty;
      case 1: return birthDate != null;
      case 2: return isTimeUnknown || birthTime != null;
      case 3: return birthPlace != null && latitude != null && longitude != null;
      default: return true;
    }
  }
}
