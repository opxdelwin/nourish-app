import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/db_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/app_bottom_navigation_bar.dart';
import '../../widgets/empty_widget.dart';
import '../../backend/models.dart';

class FoodLogView extends StatelessWidget {
  const FoodLogView({super.key});

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DbProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateLogs = dbProvider.selectedDateLogs;
    final profilePhoto = dbProvider.currentUser?.profilePhotoBase64;

    final double totalCalories = dbProvider.totalCaloriesConsumed;
    final double caloriesTarget = dbProvider.caloriesTarget;
    final double totalProtein = dbProvider.totalProteinConsumed;
    final double proteinTarget = dbProvider.proteinTarget;
    final double totalCarbs = dbProvider.totalCarbsConsumed;
    final double carbsTarget = dbProvider.carbsTarget;
    final double totalFat = dbProvider.totalFatConsumed;
    final double fatTarget = dbProvider.fatTarget;

    final double caloriePercent = dbProvider.calorieProgressPercent;
    final int caloriePercentInt = (caloriePercent * 100).toInt();

    final double totalMacrosWeight = totalProtein + totalCarbs + totalFat;
    double proteinPercentage = 0.0;
    double carbsPercentage = 0.0;
    double fatPercentage = 0.0;

    if (totalMacrosWeight > 0) {
      proteinPercentage = (totalProtein / totalMacrosWeight) * 100;
      carbsPercentage = (totalCarbs / totalMacrosWeight) * 100;
      fatPercentage = (totalFat / totalMacrosWeight) * 100;
    } else {
      proteinPercentage = 27.0;
      carbsPercentage = 45.0;
      fatPercentage = 28.0;
    }

    final breakfastLogs = dateLogs.where((log) => log.mealType == 'Breakfast').toList();
    final lunchLogs = dateLogs.where((log) => log.mealType == 'Lunch').toList();
    final dinnerLogs = dateLogs.where((log) => log.mealType == 'Dinner').toList();
    final snacksLogs = dateLogs.where((log) => log.mealType == 'Snacks').toList();

    Future<void> pickDate(BuildContext context) async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: dbProvider.selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF6F60EF),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6F60EF),
                ),
              ),
            ),
            child: child!,
          );
        },
      );
      if (pickedDate != null) {
        dbProvider.changeDate(pickedDate);
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Food Log',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: profilePhoto != null && profilePhoto.isNotEmpty
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: profilePhoto.startsWith('assets/')
                                        ? Image.asset(profilePhoto, fit: BoxFit.cover)
                                        : Image.memory(
                                            base64Decode(profilePhoto),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: const Color(0xFFE8DEF8),
                                              child: const Icon(Icons.person, color: Color(0xFF6F60EF), size: 22),
                                            ),
                                          ),
                                  ),
                                )
                              : Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFE8DEF8),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color(0xFF6F60EF),
                                    size: 22,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
                          onPressed: () => dbProvider.decrementDate(),
                        ),
                        GestureDetector(
                          onTap: () => pickDate(context),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, color: Colors.black, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('EEE, MMM d').format(dbProvider.selectedDate),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.black, size: 28),
                          onPressed: () => dbProvider.incrementDate(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Calories',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${totalCalories.toInt()}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6F60EF),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / ${caloriesTarget.toInt()} kcal',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF919297),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        CircularPercentIndicator(
                          radius: 28.0,
                          lineWidth: 6.0,
                          percent: caloriePercent,
                          center: Text(
                            '$caloriePercentInt%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          progressColor: const Color(0xFF6F60EF),
                          backgroundColor: const Color(0xFFE8DEF8),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Macronutrient Distribution',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF9C27B0),
                                value: proteinPercentage,
                                title: '',
                                radius: 16,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFFFC009),
                                value: carbsPercentage,
                                title: '',
                                radius: 16,
                              ),
                              PieChartSectionData(
                                color: const Color(0xFFF44336),
                                value: fatPercentage,
                                title: '',
                                radius: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroLegendItem('Protein', '${proteinPercentage.toInt()}%', const Color(0xFF9C27B0)),
                        _buildMacroLegendItem('Carbs', '${carbsPercentage.toInt()}%', const Color(0xFFFFC009)),
                        _buildMacroLegendItem('Fats', '${fatPercentage.toInt()}%', const Color(0xFFF44336)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildMacroProgressBar(
                      'Protein',
                      totalProtein,
                      proteinTarget,
                      const Color(0xFF9C27B0),
                      const Color(0xFFE8DEF8),
                    ),
                    const SizedBox(height: 16),
                    _buildMacroProgressBar(
                      'Carbohydrates',
                      totalCarbs,
                      carbsTarget,
                      const Color(0xFFFFC009),
                      const Color(0xFFF2E5C7),
                    ),
                    const SizedBox(height: 16),
                    _buildMacroProgressBar(
                      'Fats',
                      totalFat,
                      fatTarget,
                      const Color(0xFFF44336),
                      const Color(0xFFF1D0D2),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Meal Log',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (dateLogs.isEmpty) ...[
                      const EmptyWidget(message: 'No meals logged for this day'),
                    ],
                    if (breakfastLogs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMealLogSection(
                        context,
                        'Breakfast',
                        SvgPicture.asset('assets/images/breakfast.svg', width: 24, height: 24),
                        breakfastLogs,
                        dbProvider,
                      ),
                    ],
                    if (lunchLogs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMealLogSection(
                        context,
                        'Lunch',
                        SvgPicture.asset('assets/images/lunch.svg', width: 24, height: 24),
                        lunchLogs,
                        dbProvider,
                      ),
                    ],
                    if (dinnerLogs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMealLogSection(
                        context,
                        'Dinner',
                        SvgPicture.asset('assets/images/dinner.svg', width: 24, height: 24),
                        dinnerLogs,
                        dbProvider,
                      ),
                    ],
                    if (snacksLogs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMealLogSection(
                        context,
                        'Snacks',
                        SvgPicture.asset('assets/images/snacks.svg', width: 24, height: 24),
                        snacksLogs,
                        dbProvider,
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const AppBottomNavigationBar(currentIndex: 1),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () => context.go('/add_meal'),
          backgroundColor: const Color(0xFF6F60EF),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    ),);
  }

  Widget _buildMacroLegendItem(String label, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroProgressBar(
    String label,
    double current,
    double target,
    Color activeColor,
    Color trackColor,
  ) {
    final double percent = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${current.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: '/${target.toInt()}g',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 8.0,
          percent: percent,
          progressColor: activeColor,
          backgroundColor: trackColor,
          barRadius: const Radius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMealLogSection(
    BuildContext context,
    String title,
    Widget iconWidget,
    List<FoodLogModel> logs,
    DbProvider dbProvider,
  ) {
    final double totalCal = logs.fold(0.0, (sum, log) => sum + log.calories);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Text(
              '${totalCal.toInt()} kcal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8F83F2),
              ),
            ),
          ],
        ),
        const Divider(height: 16, thickness: 1, color: Color(0xFFE0E0E0)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          separatorBuilder: (context, index) => const Divider(
            height: 16,
            thickness: 0.5,
            color: Color(0xFFF1F4F8),
          ),
          itemBuilder: (context, index) {
            final log = logs[index];
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Qty: 1',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${log.calories.toInt()} kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => dbProvider.deleteMealLog(log.id),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

}
