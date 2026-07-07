import 'package:flutter/material.dart';
import '../../backend/models.dart';
import '../../providers/db_provider.dart';

class ProfileViewModel extends ChangeNotifier {
  bool _isEditMode = false;

  String name = '';
  int age = 0;
  String dob = '';
  String gender = 'Male';
  double weight = 0.0;
  double height = 0.0;
  String activityLevel = 'Sedentary';
  String? profilePhotoBase64;

  int targetCalories = 2000;
  int protein = 150;
  int carbs = 200;
  int fat = 70;

  UserModel? _originalUser; //changed according to onboarding
  MealPreferencesModel? _originalPrefs;

  bool get isEditMode => _isEditMode;

  void initFromDb(UserModel? user, MealPreferencesModel? prefs) {
    if (_originalUser == null && _originalPrefs == null) {
      _originalUser = user;
      _originalPrefs = prefs;
      _resetToOriginal();
    }
  }

  int calculateAge(String dobStr) {
    if (dobStr.isEmpty) return 0;
    try {
      final parts = dobStr.split('/');
      if (parts.length != 3) return 0;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();
      int calculatedAge = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        calculatedAge--;
      }
      return calculatedAge;
    } catch (_) {
      return 0;
    }
  }

  void _resetToOriginal() {
    if (_originalUser != null) {
      name = _originalUser!.name;
      age = _originalUser!.age;
      dob = _originalUser!.dob ?? '';
      gender = _originalUser!.gender;
      weight = _originalUser!.weightKg;
      height = _originalUser!.heightCm;
      activityLevel = _originalUser!.activityLevel;
      profilePhotoBase64 = _originalUser!.profilePhotoBase64;
    } else {
      name = '';
      age = 0;
      dob = '';
      gender = '';
      weight = 0.0;
      height = 0.0;
      activityLevel = '';
      profilePhotoBase64 = null;
    }

    if (_originalPrefs != null) {
      targetCalories = _originalPrefs!.targetCalories;
      protein = _originalPrefs!.targetProtein;
      carbs = _originalPrefs!.targetCarbs;
      fat = _originalPrefs!.targetFat;
    } else {
      targetCalories = 0;
      protein = 0;
      carbs = 0;
      fat = 0;
    }
  }

  bool get hasUnsavedChanges {
    final userChanged =
        _originalUser == null
            ? (name.isNotEmpty || profilePhotoBase64 != null)
            : (name != _originalUser!.name ||
                age != _originalUser!.age ||
                dob != (_originalUser!.dob ?? '') ||
                gender != _originalUser!.gender ||
                weight != _originalUser!.weightKg ||
                height != _originalUser!.heightCm ||
                activityLevel != _originalUser!.activityLevel ||
                profilePhotoBase64 != _originalUser!.profilePhotoBase64);

    final prefsChanged =
        _originalPrefs == null
            ? false
            : (targetCalories != _originalPrefs!.targetCalories ||
                protein != _originalPrefs!.targetProtein ||
                carbs != _originalPrefs!.targetCarbs ||
                fat != _originalPrefs!.targetFat);

    return userChanged || prefsChanged;
  }

  void startEditing() {
    _isEditMode = true;
    notifyListeners();
  }

  void cancelChanges() {
    _resetToOriginal();
    _isEditMode = false;
    notifyListeners();
  }

  Future<void> saveChanges(DbProvider dbProvider) async {
    final updatedUser = UserModel(
      name: name,
      age: age,
      dob: dob,
      gender: gender,
      weightKg: weight,
      heightCm: height,
      activityLevel: activityLevel,
      profilePhotoBase64: profilePhotoBase64,
    );

    final updatedPrefs = MealPreferencesModel(
      targetCalories: targetCalories,
      targetProtein: protein,
      targetCarbs: carbs,
      targetFat: fat,
    );

    await dbProvider.saveUser(updatedUser);
    await dbProvider.saveMealPreferences(updatedPrefs);

    _originalUser = updatedUser;
    _originalPrefs = updatedPrefs;
    _isEditMode = false;
    notifyListeners();
  }

  void updateName(String val) {
    name = val;
    notifyListeners();
  }

  void updateAge(int val) {
    age = val;
    notifyListeners();
  }

  void updateDob(String val) {
    dob = val;
    age = calculateAge(val);
    notifyListeners();
  }

  void updateGender(String val) {
    gender = val;
    notifyListeners();
  }

  void updateWeight(double val) {
    weight = val;
    notifyListeners();
  }

  void updateHeight(double val) {
    height = val;
    notifyListeners();
  }

  void updateActivityLevel(String val) {
    activityLevel = val;
    notifyListeners();
  }

  void updateProfilePhoto(String base64) {
    profilePhotoBase64 = base64;
    notifyListeners();
  }

  void updateCalories(int val) {
    targetCalories = val;
    notifyListeners();
  }

  void updateProtein(int val) {
    protein = val;
    notifyListeners();
  }

  void updateCarbs(int val) {
    carbs = val;
    notifyListeners();
  }

  void updateFat(int val) {
    fat = val;
    notifyListeners();
  }
}
