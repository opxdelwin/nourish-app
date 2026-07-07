import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/db_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_bottom_navigation_bar.dart';
import '../../widgets/empty_widget.dart';
import '../../backend/models.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DbProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final profilePhoto = dbProvider.currentUser?.profilePhotoBase64;
    final userName = dbProvider.currentUser?.name.isNotEmpty == true
        ? dbProvider.currentUser!.name
        : authProvider.userName;

    final todayLogs = dbProvider.getLogsForDate(DateTime.now());

    final double todayCalories = todayLogs.fold(0.0, (sum, item) => sum + item.calories);
    final double todayProtein = todayLogs.fold(0.0, (sum, item) => sum + item.protein);
    final double todayCarbs = todayLogs.fold(0.0, (sum, item) => sum + item.carbs);
    final double todayFat = todayLogs.fold(0.0, (sum, item) => sum + item.fat);

    final double caloriesTarget = dbProvider.caloriesTarget;
    final double proteinTarget = dbProvider.proteinTarget;
    final double carbsTarget = dbProvider.carbsTarget;
    final double fatTarget = dbProvider.fatTarget;

    final double todayPercent = caloriesTarget > 0 ? (todayCalories / caloriesTarget).clamp(0.0, 1.0) : 0.0;
    final int todayPercentInt = (todayPercent * 100).toInt();

    final double proteinPercent = proteinTarget > 0 ? (todayProtein / proteinTarget).clamp(0.0, 1.0) : 0.0;
    final double carbsPercent = carbsTarget > 0 ? (todayCarbs / carbsTarget).clamp(0.0, 1.0) : 0.0;
    final double fatPercent = fatTarget > 0 ? (todayFat / fatTarget).clamp(0.0, 1.0) : 0.0;

    final breakfastLogs = todayLogs.where((log) => log.mealType == 'Breakfast').toList();
    final lunchLogs = todayLogs.where((log) => log.mealType == 'Lunch').toList();
    final dinnerLogs = todayLogs.where((log) => log.mealType == 'Dinner').toList();
    final snacksLogs = todayLogs.where((log) => log.mealType == 'Snacks').toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Nourish?'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          await SystemNavigator.pop();
        }
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
                        Row(
                          children: [
                            Text(
                              'Nourish ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const _GdgLogo(),
                          ],
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
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hello, ',
                            style: TextStyle(
                              fontSize: 26,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '$userName!',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8F83F2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF919297),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Today's Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${todayCalories.toInt()}',
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
                        CircularPercentIndicator(
                          radius: 28.0,
                          lineWidth: 6.0,
                          percent: todayPercent,
                          center: Text(
                            '$todayPercentInt%',
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroProgressItem(
                            context,
                            'Protein',
                            todayProtein,
                            proteinPercent,
                            const Color(0xFF9C27B0),
                            const Color(0xFFE8DEF8),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMacroProgressItem(
                            context,
                            'Carbs',
                            todayCarbs,
                            carbsPercent,
                            const Color(0xFFFFC009),
                            const Color(0xFFF2E5C7),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMacroProgressItem(
                            context,
                            'Fat',
                            todayFat,
                            fatPercent,
                            const Color(0xFFF44336),
                            const Color(0xFFF1D0D2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            'Add Meal',
                            Icons.restaurant_menu,
                            () => context.go('/add_meal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            'Saved Recipes',
                            Icons.cookie_outlined,
                            () => context.go('/saved_recipes'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildQuickActionCard(
                            context,
                            'Food Info',
                            Icons.info_outline,
                            () => context.go('/food_info'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Meals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/food_log'),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6F60EF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (todayLogs.isEmpty) ...[
                      const EmptyWidget(message: 'No meals logged for today'),
                    ],
                    if (breakfastLogs.isNotEmpty) ...[
                      _buildRecentMealSection(
                        context,
                        'Breakfast',
                        SvgPicture.asset('assets/images/breakfast.svg', width: 24, height: 24),
                        breakfastLogs,
                        dbProvider,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (lunchLogs.isNotEmpty) ...[
                      _buildRecentMealSection(
                        context,
                        'Lunch',
                        SvgPicture.asset('assets/images/lunch.svg', width: 24, height: 24),
                        lunchLogs,
                        dbProvider,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (dinnerLogs.isNotEmpty) ...[
                      _buildRecentMealSection(
                        context,
                        'Dinner',
                        SvgPicture.asset('assets/images/dinner.svg', width: 24, height: 24),
                        dinnerLogs,
                        dbProvider,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (snacksLogs.isNotEmpty) ...[
                      _buildRecentMealSection(
                        context,
                        'Snacks',
                        SvgPicture.asset('assets/images/snacks.svg', width: 24, height: 24),
                        snacksLogs,
                        dbProvider,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            const AppBottomNavigationBar(currentIndex: 0),
          ],
        ),
      ),
    ),);
  }

  Widget _buildMacroProgressItem(
    BuildContext context,
    String label,
    double current,
    double percent,
    Color activeColor,
    Color trackColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          lineHeight: 6.0,
          percent: percent,
          progressColor: activeColor,
          backgroundColor: trackColor,
          barRadius: const Radius.circular(3),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          '${current.toInt()} g',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getTextColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: _getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getBorderColor(context), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6F60EF), size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMealSection(
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getTextColor(context),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _getTextColor(context),
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
                Text(
                  '${log.calories.toInt()} kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  Color _getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white;
  }

  Color _getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2E) : const Color(0xFFF1EFEF);
  }
}

class _GdgLogoPainter extends CustomPainter {
  const _GdgLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke;

    paint.color = const Color(0xFF4285F4);
    canvas.drawLine(
      Offset(size.width * 0.40, size.height * 0.76),
      Offset(size.width * 0.15, size.height * 0.5),
      paint,
    );
    paint.color = const Color(0xFFEA4335);
    canvas.drawLine(
      Offset(size.width * 0.40, size.height * 0.24),
      Offset(size.width * 0.15, size.height * 0.5),
      paint,
    );

    paint.color = const Color(0xFFFFB300);
    canvas.drawLine(
      Offset(size.width * 0.60, size.height * 0.76),
      Offset(size.width * 0.85, size.height * 0.5),
      paint,
    );
    paint.color = const Color(0xFF34A853);
    canvas.drawLine(
      Offset(size.width * 0.60, size.height * 0.24),
      Offset(size.width * 0.85, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GdgLogo extends StatelessWidget {
  const _GdgLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 24,
      child: CustomPaint(
        painter: _GdgLogoPainter(),
      ),
    );
  }
}
