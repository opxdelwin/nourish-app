import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/nutrient_item.dart';
import '../../widgets/app_bottom_navigation_bar.dart';
import 'food_info_model.dart';
import 'food_info_scanner_view.dart';

class FoodInfoView extends StatefulWidget {
  const FoodInfoView({super.key});

  @override
  State<FoodInfoView> createState() => _FoodInfoViewState();
}

class _FoodInfoViewState extends State<FoodInfoView> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _startScan(BuildContext context, FoodInfoViewModel model) async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const FoodInfoScannerView()),
    );
    if (barcode != null && barcode.isNotEmpty) {
      await model.fetchProduct(barcode);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        create: (_) => FoodInfoViewModel(),
        child: Consumer<FoodInfoViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.go('/home'),
              ),
              title: const Text(
                'Food info',
                style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EFEF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Enter barcode...',
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  model.fetchProduct(val.trim());
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _startScan(context, model),
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6F60EF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: model.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6F60EF),
                            ),
                          )
                        : !model.hasData
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8DEF8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.qr_code_scanner,
                                          color: Color(0xFF6F60EF),
                                          size: 40,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Scan or Enter Barcode',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Scan a food product barcode or enter it manually to view detailed nutritional facts, allergens, and ingredients list dynamically.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${model.productName} (${model.productQuantity})',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            width: 170,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2ECFC),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    NutrientItem(label: 'Calories', value: '${model.calories.toInt()}', unit: 'kcal'),
                                                    NutrientItem(label: 'Protein', value: '${model.protein.toInt()}', unit: 'g'),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    NutrientItem(label: 'Carbs', value: '${model.carbs.toInt()}', unit: 'g'),
                                                    NutrientItem(label: 'Fat', value: '${model.fat.toInt()}', unit: 'g'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      width: 120,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          model.imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: const Color(0xFFF1EFEF),
                                              child: const Icon(Icons.fastfood, color: Colors.grey, size: 48),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                const Text(
                                  'Allergen Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: model.allergens.map((allergen) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFE0E0E0)),
                                      ),
                                      child: Text(
                                        allergen,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    const Text(
                                      'Ingredients',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    if (model.isVegetarian)
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.green, width: 1.5),
                                        ),
                                        padding: const EdgeInsets.all(2.5),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: model.ingredients.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '• ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              model.ingredients[index],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                  ),
                  const AppBottomNavigationBar(currentIndex: 0),
                ],
              ),
            ),
          );
        },
      ),
    ),);
  }

}
