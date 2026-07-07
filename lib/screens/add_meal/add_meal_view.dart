import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';
import '../../providers/db_provider.dart';
import '../../widgets/utils/toast_service.dart';
import 'add_meal_model.dart';
import 'barcode_scanner_view.dart';

class AddMealView extends StatelessWidget {
  const AddMealView({super.key});

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DbProvider>(context, listen: false);
    final dateString = "${dbProvider.selectedDate.year}-${dbProvider.selectedDate.month.toString().padLeft(2, '0')}-${dbProvider.selectedDate.day.toString().padLeft(2, '0')}";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/food_log');
        }
      },
      child: ChangeNotifierProvider(
      create: (_) => AddMealViewModel(),
      child: Consumer<AddMealViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9F9FB),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                          onPressed: () => context.go('/food_log'),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Add Meal',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                initialValue: model.selectedMealType,
                                decoration: const InputDecoration(
                                  labelText: 'Choose Meal Type',
                                  labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                  border: InputBorder.none,
                                ),
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                                items: model.mealTypes.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    model.selectMealType(value);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: TextField(
                                    controller: model.textController,
                                    style: const TextStyle(color: Colors.black, fontSize: 16),
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                      suffixIcon: model.isLoading
                                          ? const Padding(
                                              padding: EdgeInsets.all(12.0),
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8C7CF0)),
                                                ),
                                              ),
                                            )
                                          : IconButton(
                                              icon: const Icon(Icons.add_circle, color: Color(0xFF8C7CF0)),
                                              onPressed: () {
                                                if (model.textController.text.trim().isNotEmpty) {
                                                  model.searchAndAddIngredient(
                                                    model.textController.text,
                                                    context,
                                                  );
                                                }
                                              },
                                            ),
                                      labelText: 'Add Meal/Ingredient',
                                      hintText: 'Start typing',
                                      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (value) {
                                      if (value.trim().isNotEmpty) {
                                        model.searchAndAddIngredient(value, context);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push<Map<String, dynamic>>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BarcodeScannerView(),
                                    ),
                                  );
                                  if (result != null) {
                                    model.addScannedFood(
                                      name: result['name'],
                                      calories: result['calories'],
                                      protein: result['protein'],
                                      carbs: result['carbs'],
                                      fat: result['fat'],
                                    );
                                  }
                                },
                                child: Container(
                                  height: 56,
                                  width: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8C7CF0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.barcode,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Meals/ Ingredients:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (model.ingredients.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'No items added yet',
                                      style: TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 10,
                                    children: List.generate(model.ingredients.length, (index) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(24),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              model.ingredients[index],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () => model.removeIngredient(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8C7CF0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (model.ingredients.isEmpty) {
                            ToastService().showToast(
                              context,
                              'Please add at least one ingredient',
                              type: ToastificationType.warning,
                            );
                            return;
                          }
                          await model.saveMeal(dbProvider, dateString);
                          if (context.mounted) {
                            ToastService().showToast(
                              context,
                              'Meal saved successfully',
                              type: ToastificationType.success,
                            );
                            context.go('/food_log');
                          }
                        },
                        child: const Text(
                          'Save Meal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),);
  }
}
