import 'package:flutter/material.dart';

class NutritionRow extends StatelessWidget {
  final List<String> items;
  final TextStyle style;
  
  const NutritionRow({
    super.key,
    required this.items,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final item in items)
          Expanded(
            child: Center(
              child: Text(item, style: style),
            )
          ),
      ],
    );
  }
}

class NutritionInfo extends StatelessWidget {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final Color backgroundColor;
  
  // New parameters for sizing control
  final double horizontalPadding;  // Controls horizontal width
  final double verticalPadding;   // Controls vertical height
  final double outerPadding;      // Space around the container

  const NutritionInfo({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.backgroundColor = const Color(0xFFF3E5F5), 
    this.horizontalPadding = 10.0,  // Default horizontal padding
    this.verticalPadding = 16.0,    // Default vertical padding
    this.outerPadding = 4.0,       // Default outer padding
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(outerPadding), 
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding, 
          horizontal: horizontalPadding,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Labels row
            const NutritionRow(
              items: ['Calories', 'Protein', 'Carbs', 'Fat'],
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            
            // Values row
            NutritionRow(
              items: ['$calories', '$protein', '$carbs', '$fat'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            
            // Units row
            const NutritionRow(
              items: ['kcal', 'g', 'g', 'g'],
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}