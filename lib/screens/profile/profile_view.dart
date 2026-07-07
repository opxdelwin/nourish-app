import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'profile_model.dart';
import '../../providers/db_provider.dart';
import '../../widgets/profile/profile_info_tile.dart';
import '../../widgets/profile/profile_picture_widget.dart';
import '../../widgets/profile/profile_macros_widget.dart';
import '../../widgets/profile/dob_picker_dialog.dart';
import '../../widgets/profile/profile_input_dialog.dart';
import '../../widgets/profile/gender_picker_dialog.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final dbProvider = context.watch<DbProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      },
      child: ChangeNotifierProvider(
      create: (_) {
        final model = ProfileViewModel();
        model.initFromDb(dbProvider.currentUser, dbProvider.mealPreferences);
        return model;
      },
      child: Consumer<ProfileViewModel>(
        builder: (context, model, child) {
          final screenWidth = MediaQuery.of(context).size.width;
          final paddingValue = screenWidth > 600 ? 32.0 : 24.0;
          final contentWidth = screenWidth > 600 ? 500.0 : double.infinity;

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: isDark ? Colors.black : Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Chivo',
                  fontWeight: FontWeight.w300,
                  fontSize: 28,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () => context.push('/about_us'),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.grey[900] : Colors.white,
                        border: Border.all(
                          color: const Color(0xffFFC009),
                          width: 1.5,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/gdg_logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingValue,
                      vertical: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        ProfilePictureWidget(
                          profilePhotoBase64: model.profilePhotoBase64,
                          isEditMode: model.isEditMode,
                          onPhotoChanged: model.updateProfilePhoto,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your info',
                              style: TextStyle(
                                fontFamily: 'Chivo',
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (model.isEditMode) ...[
                                  IconButton(
                                    icon: Icon(
                                      Icons.save_outlined,
                                      color: model.hasUnsavedChanges
                                          ? const Color(0xffFFC009)
                                          : Colors.grey,
                                    ),
                                    onPressed: model.hasUnsavedChanges
                                        ? () => model.saveChanges(dbProvider)
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Color(0xffF44336),
                                    ),
                                    onPressed: model.cancelChanges,
                                  ),
                                ] else
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                    onPressed: model.startEditing,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ProfileInfoTile(
                          label: 'Name:',
                          value: model.name,
                          isEditMode: model.isEditMode,
                          onTap: () async {
                            final result = await ProfileInputDialog.show(
                              context,
                              label: 'Name',
                              initialValue: model.name,
                            );
                            if (result != null) model.updateName(result);
                          },
                        ),
                        ProfileInfoTile(
                          label: 'Gender:',
                          value: model.gender,
                          isEditMode: model.isEditMode,
                          onTap: () async {
                            final result = await GenderPickerDialog.show(
                              context,
                              model.gender,
                            );
                            if (result != null) {
                              model.updateGender(result);
                            }
                          },
                        ),
                        ProfileInfoTile(
                          label: 'DOB:',
                          value: model.dob.isEmpty
                              ? (model.age == 0 ? '' : '${model.age} yrs')
                              : model.dob,
                          isEditMode: model.isEditMode,
                          suffixIcon: Icons.calendar_today,
                          onTap: () async {
                            final selectedDob = await DobPickerDialog.show(
                              context,
                              model.dob,
                            );
                            if (selectedDob != null) {
                              model.updateDob(selectedDob);
                            }
                          },
                        ),
                        ProfileInfoTile(
                          label: 'Height:',
                          value: model.height == 0.0
                              ? ''
                              : '${model.height.toInt()} cm',
                          isEditMode: model.isEditMode,
                          onTap: () async {
                            final result = await ProfileInputDialog.show(
                              context,
                              label: 'Height',
                              initialValue: model.height == 0.0
                                  ? ''
                                  : model.height.toInt().toString(),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              suffix: 'cm',
                              minValue: 50,
                              maxValue: 300,
                            );
                            if (result != null) {
                              model.updateHeight(double.tryParse(result) ?? model.height);
                            }
                          },
                        ),
                        ProfileInfoTile(
                          label: 'Weight:',
                          value: model.weight == 0.0
                              ? ''
                              : '${model.weight.toInt()} kg',
                          isEditMode: model.isEditMode,
                          onTap: () async {
                            final result = await ProfileInputDialog.show(
                              context,
                              label: 'Weight',
                              initialValue: model.weight == 0.0
                                  ? ''
                                  : model.weight.toInt().toString(),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              suffix: 'kg',
                              minValue: 10,
                              maxValue: 500,
                            );
                            if (result != null) {
                              model.updateWeight(double.tryParse(result) ?? model.weight);
                            }
                          },
                        ),
                        ProfileInfoTile(
                          label: 'Activity Level:',
                          value: model.activityLevel,
                          isEditMode: model.isEditMode,
                          dropdownOptions: const [
                            'Sedentary',
                            'Lightly Active',
                            'Moderately Active',
                            'Very Active',
                          ],
                          onChanged: model.updateActivityLevel,
                        ),
                        ProfileMacrosWidget(
                          targetCalories: model.targetCalories,
                          protein: model.protein,
                          carbs: model.carbs,
                          fat: model.fat,
                          isEditMode: model.isEditMode,
                          onCaloriesChanged: model.updateCalories,
                          onProteinChanged: model.updateProtein,
                          onCarbsChanged: model.updateCarbs,
                          onFatChanged: model.updateFat,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),);
  }
}
