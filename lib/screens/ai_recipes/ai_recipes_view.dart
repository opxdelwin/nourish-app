import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'ai_recipes_model.dart';
import 'barcode_scanner_view.dart';
import '../../providers/db_provider.dart';
import '../../widgets/app_bottom_navigation_bar.dart';
import '../../widgets/recipe_card.dart';

class AiRecipesView extends StatefulWidget {
  const AiRecipesView({super.key});

  @override
  State<AiRecipesView> createState() => _AiRecipesViewState();
}

class _AiRecipesViewState extends State<AiRecipesView> with SingleTickerProviderStateMixin {
  final TextEditingController _ingredientController = TextEditingController();
  final FocusNode _ingredientFocusNode = FocusNode();
  bool _showDetails = false;
  Recipe? _selectedRecipe;

  AnimationController? _laserController;
  Animation<double>? _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_laserController!);
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _ingredientFocusNode.dispose();
    _laserController?.dispose();
    super.dispose();
  }

  void _openBarcodeScanner(BuildContext context, AiRecipesViewModel model) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        final testBarcodes = [
          {'name': 'Paneer Pack', 'code': '8901719101037'},
          {'name': 'Coriander Leaves', 'code': '8901234567890'},
          {'name': 'Onions', 'code': '8909876543210'},
          {'name': 'Turmeric Powder', 'code': '8908888999900'},
        ];

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Barcode Scanner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Chivo',
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.camera_alt, color: Colors.white54, size: 48),
                      AnimatedBuilder(
                        animation: _laserAnimation!,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (_laserAnimation!.value * 140),
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.8),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 20, left: 20,
                        child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.green, width: 3), left: BorderSide(color: Colors.green, width: 3)))),
                      ),
                      Positioned(
                        top: 20, right: 20,
                        child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.green, width: 3), right: BorderSide(color: Colors.green, width: 3)))),
                      ),
                      Positioned(
                        bottom: 20, left: 20,
                        child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.green, width: 3), left: BorderSide(color: Colors.green, width: 3)))),
                      ),
                      Positioned(
                        bottom: 20, right: 20,
                        child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.green, width: 3), right: BorderSide(color: Colors.green, width: 3)))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Simulate scanning by clicking below OR enter a barcode manually:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Enter Barcode Number',
                    labelStyle: const TextStyle(color: Colors.grey),
                    hintText: 'e.g. 8901719101037',
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onSubmitted: (val) async {
                    if (val.trim().isEmpty) return;
                    Navigator.pop(context);
                    
                    if (!context.mounted) return;
                    toastification.show(
                      context: context,
                      title: const Text('Looking up product...'),
                      type: ToastificationType.info,
                      style: ToastificationStyle.flat,
                      autoCloseDuration: const Duration(seconds: 2),
                    );

                    final product = await model.lookupBarcode(val.trim());
                    if (!context.mounted) return;
                    if (product != null) {
                      model.addIngredient(product);
                      toastification.show(
                        context: context,
                        title: Text('Found & Added: ${product.name}'),
                        type: ToastificationType.success,
                        style: ToastificationStyle.flat,
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                    } else {
                      toastification.show(
                        context: context,
                        title: const Text('Product not found in OpenFoodFacts'),
                        type: ToastificationType.error,
                        style: ToastificationStyle.flat,
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: testBarcodes.map((item) {
                    return ActionChip(
                      label: Text(item['name']!),
                      backgroundColor: const Color(0xFFF0EFFF),
                      labelStyle: const TextStyle(color: Color(0xFF8B80F9), fontSize: 12, fontWeight: FontWeight.w600),
                      onPressed: () async {
                        Navigator.pop(context);
                        
                        if (!context.mounted) return;
                        toastification.show(
                          context: context,
                          title: const Text('Looking up product...'),
                          type: ToastificationType.info,
                          style: ToastificationStyle.flat,
                          autoCloseDuration: const Duration(seconds: 2),
                        );

                        final product = await model.lookupBarcode(item['code']!);
                        if (!context.mounted) return;
                        if (product != null) {
                          model.addIngredient(product);
                          toastification.show(
                            context: context,
                            title: Text('Found & Added: ${product.name}'),
                            type: ToastificationType.success,
                            style: ToastificationStyle.flat,
                            autoCloseDuration: const Duration(seconds: 3),
                          );
                        } else {
                          model.addIngredientByName(item['name']!);
                          toastification.show(
                            context: context,
                            title: Text('Added: ${item['name']}'),
                            type: ToastificationType.success,
                            style: ToastificationStyle.flat,
                            autoCloseDuration: const Duration(seconds: 3),
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownButton({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    return Expanded(
      child: PopupMenuButton<String>(
        onSelected: onChanged,
        itemBuilder: (context) {
          return items.map((val) => PopupMenuItem(value: val, child: Text(val))).toList();
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dbProvider = Provider.of<DbProvider>(context);

    final cookingStyles = ['Stir Fry', 'Curry', 'Sautéed', 'Baked', 'Fried'];
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_showDetails) {
          setState(() {
            _showDetails = false;
            _selectedRecipe = null;
          });
        } else {
          context.go('/home');
        }
      },
      child: ChangeNotifierProvider(
      create: (_) => AiRecipesViewModel(),
      child: Consumer<AiRecipesViewModel>(
        builder: (context, model, child) {
          if (_showDetails && _selectedRecipe != null) {
            final recipe = _selectedRecipe!;
            final isSaved = dbProvider.isRecipeSaved(recipe.id);

            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                  onPressed: () {
                    setState(() {
                      _showDetails = false;
                      _selectedRecipe = null;
                    });
                  },
                ),
                title: Text(
                  'AI Recipes',
                  style: TextStyle(
                    fontFamily: 'Chivo',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
                actions: [
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                    onPressed: () => context.push('/saved_recipes'),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100',
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: TextStyle(
                              fontFamily: 'Chivo',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? const Color(0xFF8B80F9) : (isDark ? Colors.white : Colors.black87),
                            size: 26,
                          ),
                          onPressed: () async {
                            if (isSaved) {
                              await dbProvider.deleteRecipe(recipe.id);
                              if (!context.mounted) return;
                              toastification.show(
                                context: context,
                                title: const Text('Recipe removed from Saved'),
                                type: ToastificationType.info,
                                style: ToastificationStyle.flat,
                                autoCloseDuration: const Duration(seconds: 2),
                              );
                            } else {
                              await dbProvider.saveRecipe(recipe);
                              if (!context.mounted) return;
                              toastification.show(
                                context: context,
                                title: const Text('Recipe saved successfully!'),
                                type: ToastificationType.success,
                                style: ToastificationStyle.flat,
                                autoCloseDuration: const Duration(seconds: 2),
                              );
                            }
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    Text(
                      recipe.duration,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0EFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFigmaNutritionItem(context, 'Calories', '${recipe.calories}', 'kcal'),
                          _buildFigmaNutritionItem(context, 'Protein', '${recipe.protein.round()}', 'g'),
                          _buildFigmaNutritionItem(context, 'Carbs', '${recipe.carbs.round()}', 'g'),
                          _buildFigmaNutritionItem(context, 'Fat', '${recipe.fat.round()}', 'g'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        fontFamily: 'Chivo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recipe.ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Text('  •  ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              ing,
                              style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 25),
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontFamily: 'Chivo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...recipe.instructions.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8B80F9),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$idx',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(fontSize: 15, height: 1.4, color: isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                'AI Recipes',
                style: TextStyle(
                  fontFamily: 'Chivo',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.favorite_border, color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
                  onPressed: () => context.push('/saved_recipes'),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100',
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Create delicious recipes from ingredients!',
                    style: TextStyle(
                      fontFamily: 'Chivo',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add ingredients that you have, and our AI will generate a seasonal Indian recipe!',
                    style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.3),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildDropdownButton(
                        label: 'Cooking Style',
                        value: model.selectedCookingStyle,
                        items: cookingStyles,
                        onChanged: model.setCookingStyle,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 12),
                      _buildDropdownButton(
                        label: 'Meal Type',
                        value: model.selectedMealType,
                        items: mealTypes,
                        onChanged: model.setMealType,
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Type the name of the ingredient or scan the bar code on the back of the packet',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientController,
                          focusNode: _ingredientFocusNode,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Add Ingredient',
                            labelStyle: const TextStyle(color: Colors.grey),
                            hintText: 'Start typing',
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF8B80F9), width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) {
                            model.searchIngredients(val);
                          },
                          onSubmitted: (val) {
                            model.addIngredientByName(val);
                            _ingredientController.clear();
                            model.clearSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          final String? code = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(builder: (_) => const BarcodeScannerView()),
                          );

                          if (!context.mounted) return;
                          if (code != null && code.trim().isNotEmpty) {
                            toastification.show(
                              context: context,
                              title: const Text('Looking up product...'),
                              type: ToastificationType.info,
                              style: ToastificationStyle.flat,
                              autoCloseDuration: const Duration(seconds: 2),
                            );

                            final product = await model.lookupBarcode(code);
                            if (!context.mounted) return;
                            if (product != null) {
                              model.addIngredient(product);
                              toastification.show(
                                context: context,
                                title: Text('Found & Added: ${product.name}'),
                                type: ToastificationType.success,
                                style: ToastificationStyle.flat,
                                autoCloseDuration: const Duration(seconds: 3),
                              );
                            } else {
                              toastification.show(
                                context: context,
                                title: const Text('Product not found in OpenFoodFacts'),
                                type: ToastificationType.error,
                                style: ToastificationStyle.flat,
                                autoCloseDuration: const Duration(seconds: 3),
                              );
                            }
                          } else {
                            _openBarcodeScanner(context, model);
                          }
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B80F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            FontAwesomeIcons.barcode,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (model.isSearching)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: const Color(0xFF8B80F9),
                          size: 30,
                        ),
                      ),
                    )
                  else if (model.searchResults.isNotEmpty)
                    Container(
                      height: 100,
                      margin: const EdgeInsets.only(top: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: model.searchResults.length,
                        itemBuilder: (context, index) {
                          final prod = model.searchResults[index];
                          return GestureDetector(
                            onTap: () {
                              model.addIngredient(prod);
                              model.clearSearch();
                              _ingredientController.clear();
                              _ingredientFocusNode.unfocus();
                            },
                            child: Container(
                              width: 85,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[50],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (prod.imageUrl.isNotEmpty)
                                    Image.network(prod.imageUrl, height: 35, width: 35, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 24))
                                  else
                                    const Icon(Icons.fastfood, size: 24, color: Colors.grey),
                                  const SizedBox(height: 4),
                                  Text(
                                    prod.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Ingredients:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        if (model.selectedIngredients.isEmpty)
                          const Text(
                            'No ingredients added. Start typing above!',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: model.selectedIngredients.map((ing) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                                  border: Border.all(color: isDark ? Colors.white70 : Colors.black87, width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ing.name,
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => model.removeIngredient(ing),
                                      child: Container(
                                        padding: const EdgeInsets.all(1.5),
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white : Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 10,
                                          color: isDark ? Colors.black : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: model.isGenerating
                        ? null
                        : () async {
                            if (_ingredientController.text.trim().isNotEmpty) {
                              model.addIngredientByName(_ingredientController.text);
                              _ingredientController.clear();
                              model.clearSearch();
                            }
                            await model.generateRecipe();
                            if (!context.mounted) return;
                            if (model.errorMessage.isNotEmpty) {
                              toastification.show(
                                context: context,
                                title: Text(model.errorMessage),
                                autoCloseDuration: const Duration(seconds: 3),
                                type: ToastificationType.error,
                                style: ToastificationStyle.flat,
                              );
                            } else {
                              setState(() {
                                _selectedRecipe = null;
                                _showDetails = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B80F9),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFD4D1FF),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: model.isGenerating
                        ? LoadingAnimationWidget.threeArchedCircle(
                            color: Colors.white,
                            size: 24,
                          )
                        : const Text(
                            'Generate Recipe',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 25),
                  if (model.generatedRecipes.isNotEmpty && !model.isGenerating) ...[
                    const Divider(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Generated Recipes',
                        style: TextStyle(
                          fontFamily: 'Chivo',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    ...model.generatedRecipes.map((recipe) {
                      final isSaved = dbProvider.isRecipeSaved(recipe.id);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRecipe = recipe;
                            _showDetails = true;
                          });
                        },
                        child: Stack(
                          children: [
                            RecipeCard(
                              title: recipe.title,
                              duration: recipe.duration,
                              horizontalOuterPadding: 0,
                              widthFactor: 1.0,
                              nutritionInfo: Row(
                                children: [
                                  Text(
                                    '${recipe.calories} kcal  •  P: ${recipe.protein.round()}g  C: ${recipe.carbs.round()}g  F: ${recipe.fat.round()}g',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 12,
                              top: 20,
                              child: IconButton(
                                icon: Icon(
                                  isSaved ? Icons.favorite : Icons.favorite_border,
                                  color: isSaved ? const Color(0xFF8B80F9) : (isDark ? Colors.white : Colors.black87),
                                ),
                                onPressed: () async {
                                  if (isSaved) {
                                    await dbProvider.deleteRecipe(recipe.id);
                                    if (!context.mounted) return;
                                    toastification.show(
                                      context: context,
                                      title: const Text('Recipe removed from Saved'),
                                      type: ToastificationType.info,
                                      style: ToastificationStyle.flat,
                                      autoCloseDuration: const Duration(seconds: 2),
                                    );
                                  } else {
                                    await dbProvider.saveRecipe(recipe);
                                    if (!context.mounted) return;
                                    toastification.show(
                                      context: context,
                                      title: const Text('Recipe saved successfully!'),
                                      type: ToastificationType.success,
                                      style: ToastificationStyle.flat,
                                      autoCloseDuration: const Duration(seconds: 2),
                                    );
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),);
  }

  Widget _buildFigmaNutritionItem(BuildContext context, String label, String value, String unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
