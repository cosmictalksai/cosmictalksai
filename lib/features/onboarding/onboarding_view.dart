import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_provider.dart';
import '../../services/location_service.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final LocationService _locationService = LocationService();
  List<LocationSuggestion> _suggestions = [];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep < 4) {
      ref.read(onboardingProvider.notifier).nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (state.currentStep == 4) {
      // Already handled by Step 4 entry calling submit
    }
  }

  void _prevPage() {
    final state = ref.read(onboardingProvider);
    if (state.currentStep > 0) {
      ref.read(onboardingProvider.notifier).prevStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    // Auto-trigger submit when reaching Step 4 (The Loading Step is actually Step 4 in index 0-4)
    // Wait, let's look at the logic: Step 1 (0), Step 2 (1), Step 3 (2), Step 4 (3), Step 5 (4).
    if (state.currentStep == 4 && !state.isLoading && state.errorMessage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(onboardingProvider.notifier).submit();
      });
    }

    // Navigation on success
    ref.listen(onboardingProvider, (previous, next) {
      if (next.currentStep == 5) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29), // Deep cosmic mystery
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(state.currentStep),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
            if (state.currentStep < 4) _buildFooter(state),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int step) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return Container(
                width: (MediaQuery.of(context).size.width - 80) / 5,
                height: 4,
                decoration: BoxDecoration(
                  color: index <= step ? Colors.amber : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: index <= step 
                    ? [BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 4)] 
                    : [],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${step + 1} of 5',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'First, what should we call you?',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your name ripples through the cosmic energies.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            decoration: InputDecoration(
              hintText: 'Full Name',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            ),
            onChanged: (val) => ref.read(onboardingProvider.notifier).setName(val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    final state = ref.watch(onboardingProvider);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When did you arrive?',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                ref.read(onboardingProvider.notifier).setBirthDate(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.birthDate == null 
                      ? 'Select Date of Birth' 
                      : '${state.birthDate!.day}/${state.birthDate!.month}/${state.birthDate!.year}',
                    style: TextStyle(
                      color: state.birthDate == null ? Colors.white38 : Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const Icon(Icons.calendar_month, color: Colors.amber),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final state = ref.watch(onboardingProvider);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The exact moment...',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          if (!state.isTimeUnknown)
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 12, minute: 0),
                );
                if (time != null) {
                  ref.read(onboardingProvider.notifier).setBirthTime(time);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.birthTime == null 
                        ? 'Select Time of Birth' 
                        : state.birthTime!.format(context),
                      style: TextStyle(
                        color: state.birthTime == null ? Colors.white38 : Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const Icon(Icons.access_time, color: Colors.amber),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
          Row(
            children: [
              Checkbox(
                value: state.isTimeUnknown,
                activeColor: Colors.amber,
                onChanged: (val) {
                  ref.read(onboardingProvider.notifier).setBirthTime(null, isUnknown: val ?? false);
                },
              ),
              const Text(
                'I don\'t know my exact time of birth',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where were you born?',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _locationController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search city...',
              hintStyle: TextStyle(color: Colors.white38),
              suffixIcon: Icon(Icons.search, color: Colors.amber),
            ),
            onChanged: (val) async {
              if (val.length >= 3) {
                final results = await _locationService.searchLocations(val);
                setState(() => _suggestions = results);
              }
            },
          ),
          if (_suggestions.isNotEmpty)
            Container(
              height: 200,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final s = _suggestions[index];
                  return ListTile(
                    title: Text(s.name, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      ref.read(onboardingProvider.notifier).setLocation(s.name, s.latitude, s.longitude);
                      _locationController.text = s.name;
                      setState(() => _suggestions = []);
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    final state = ref.watch(onboardingProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.errorMessage != null) ...[
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 24),
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => ref.read(onboardingProvider.notifier).submit(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('Try Again', style: TextStyle(color: Colors.black)),
            ),
          ] else ...[
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 40),
            const Text(
              'Analyzing your birth chart...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 12),
            const Text(
              'The stars are aligning for you.',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFooter(OnboardingState state) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (state.currentStep > 0)
            TextButton(
              onPressed: _prevPage,
              child: const Text('Back', style: TextStyle(color: Colors.white70)),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: state.isStepValid ? _nextPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              disabledBackgroundColor: Colors.white10,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text(
              state.currentStep == 3 ? 'Analyze Chart' : 'Continue',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
