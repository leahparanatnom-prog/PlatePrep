import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/ui_feedback.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? userProfile;
  final AuthService authService;
  final FirestoreService firestoreService;

  const ProfileScreen({
    super.key,
    required this.userProfile,
    required this.authService,
    required this.firestoreService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? get _resolvedUserId =>
      widget.userProfile?.userId ?? widget.authService.currentUserId;

  String get _currentName =>
      widget.userProfile?.name ??
      widget.authService.currentUser?.displayName ??
      'Student Chef';

  String get _currentEmail =>
      widget.userProfile?.email ??
      widget.authService.currentUser?.email ??
      'student@university.edu';

  void _editUsername() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _currentName);
    final emailController = TextEditingController(text: _currentEmail);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Username'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'e.g. Chef Alex',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  enabled: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email (cannot be changed)',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    filled: true,
                    fillColor: AppColors.cardSurfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final userId = _resolvedUserId;
                      if (userId == null || userId.isEmpty) return;

                      final newName = nameController.text.trim();
                      setDialogState(() => isSaving = true);
                      try {
                        await widget.firestoreService.updateUserName(
                          userId,
                          newName,
                          email: _currentEmail,
                        );
                        await widget.authService.updateDisplayName(newName);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (mounted) {
                          UIFeedback.showSuccess(
                            context,
                            'Username updated to $newName',
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          setDialogState(() => isSaving = false);
                        }
                        if (mounted) {
                          UIFeedback.showError(
                            context,
                            'Failed to update username: $e',
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      nameController.dispose();
      emailController.dispose();
    });
  }

  void _editCalorieTarget() {
    final formKey = GlobalKey<FormState>();
    final currentTarget = widget.userProfile?.calorieTarget ?? 2000;
    final controller = TextEditingController(text: currentTarget.toString());
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Update Calorie Target'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Goal (kcal)',
                hintText: 'e.g. 2200',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                final parsed = int.tryParse(value?.trim() ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid calorie target (> 0)';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      final userId = _resolvedUserId;
                      if (userId == null || userId.isEmpty) return;

                      final newTarget = int.parse(controller.text.trim());
                      setDialogState(() => isSaving = true);
                      try {
                        await widget.firestoreService.updateCalorieTarget(
                          userId,
                          newTarget,
                          name: _currentName,
                          email: _currentEmail,
                        );
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        if (mounted) {
                          UIFeedback.showSuccess(
                            context,
                            'Calorie goal updated to $newTarget kcal',
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          setDialogState(() => isSaving = false);
                        }
                        if (mounted) {
                          UIFeedback.showError(
                            context,
                            'Failed to update calorie target: $e',
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Target', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ).whenComplete(controller.dispose);
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of PlatePrep?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.authService.signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userProfile;
    final name = _currentName;
    final email = _currentEmail;
    final calorieTarget = user?.calorieTarget ?? 2000;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Chef Profile',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Avatar Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: _editUsername,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Goals Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meal & Nutritional Goals',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.local_fire_department_rounded, color: AppColors.accent, size: 22),
                    ),
                    title: const Text(
                      'Daily Calorie Target',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                    ),
                    subtitle: Text(
                      '$calorieTarget kcal / day',
                      style: const TextStyle(color: AppColors.textMedium, fontSize: 13),
                    ),
                    trailing: TextButton(
                      onPressed: _editCalorieTarget,
                      child: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // PlatePrep Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About PlatePrep',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cloud Firestore Real-Time Sync',
                          style: TextStyle(fontSize: 13.5, color: AppColors.textDark, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        'Active',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Firebase Auth Protection',
                          style: TextStyle(fontSize: 13.5, color: AppColors.textDark, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        'Secured',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.palette_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Design Theme',
                          style: TextStyle(fontSize: 13.5, color: AppColors.textDark, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        'Sage & Warm Orange',
                        style: TextStyle(color: AppColors.textMedium, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Sign Out Button
            CustomButton(
              text: 'Sign Out',
              icon: Icons.logout_rounded,
              variant: ButtonVariant.outline,
              onPressed: _confirmSignOut,
            ),
          ],
        ),
      ),
    );
  }
}

