import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/ui_feedback.dart';
import '../../widgets/congratulations_dialog.dart';
import '../../widgets/custom_button.dart';

class CookingTimerSection extends StatefulWidget {
  const CookingTimerSection({super.key});

  @override
  State<CookingTimerSection> createState() => _CookingTimerSectionState();
}

class _CookingTimerSectionState extends State<CookingTimerSection> {
  // Timer state
  int _initialSeconds = 25 * 60; // Default 25 min
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  int _selectedPresetMinutes = 25;

  final List<int> _presetMinutes = [10, 15, 25, 45, 60];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;

    setState(() => _isRunning = true);
    UIFeedback.showInfo(context, 'Timer started!');

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
    UIFeedback.showInfo(context, 'Timer paused');
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _initialSeconds;
    });
  }

  void _setDuration(int minutes) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _selectedPresetMinutes = minutes;
      _initialSeconds = minutes * 60;
      _remainingSeconds = _initialSeconds;
    });
  }

  void _onTimerComplete() {
    UIFeedback.triggerCompletionHaptics();
    CongratulationsDialog.show(
      context,
      durationMinutes: _selectedPresetMinutes,
    );
  }

  void _showCustomDurationDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Custom Prep Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Duration in Minutes',
                hintText: 'e.g. 30',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixText: 'mins',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final mins = int.tryParse(controller.text.trim());
              if (mins != null && mins > 0) {
                _setDuration(mins);
                Navigator.of(ctx).pop();
                UIFeedback.showSuccess(context, 'Set timer to $mins minutes');
              }
            },
            child: const Text('Set Timer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _initialSeconds > 0
        ? (_remainingSeconds / _initialSeconds)
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Timer Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              children: [
                // Circular Progress Timer Display
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 230,
                      height: 230,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: AppColors.primaryLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress < 0.2 ? AppColors.accent : AppColors.primary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.soup_kitchen_rounded,
                          color: AppColors.textMedium,
                          size: 26,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormatter.formatTimerDuration(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -1.5,
                            fontFeatures: [],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRunning ? 'Cooking in progress...' : 'Ready to cook',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isRunning ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Controls Row: Start / Pause / Reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Reset Button
                    IconButton.outlined(
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: AppColors.border, width: 1.5),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textMedium, size: 24),
                      tooltip: 'Reset',
                      onPressed: _resetTimer,
                    ),
                    const SizedBox(width: 20),

                    // Play / Pause Main Action
                    SizedBox(
                      width: 140,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRunning ? AppColors.accent : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isRunning ? _pauseTimer : _startTimer,
                        icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 26),
                        label: Text(
                          _isRunning ? 'Pause' : 'Start',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preset Options Section
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Preset Timers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showCustomDurationDialog,
                  icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                  label: const Text(
                    'Custom',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Presets Grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presetMinutes.map((mins) {
              final isSelected = _selectedPresetMinutes == mins;
              return ChoiceChip(
                label: Text('$mins mins'),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1.2,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
                showCheckmark: false,
                onSelected: (selected) {
                  if (selected) _setDuration(mins);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Student Cooking Prep Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Prep Tip',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Batch cook grains (rice, quinoa, pasta) and chop hearty veggies ahead of time to cut weekday cooking down to under 15 minutes!',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

