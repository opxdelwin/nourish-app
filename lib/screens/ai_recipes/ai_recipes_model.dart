import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../backend/models.dart';
import '../../backend/open_food_facts_service.dart';
import 'fallback_recipes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Local helper class to bridge the mock recipe list with SavedRecipeModel
class Recipe extends SavedRecipeModel {
  final String duration;

  Recipe({
    required super.id,
    required super.title,
    required this.duration,
    required super.ingredients,
    required super.instructions,
    required super.calories,
    required double protein,
    required double carbs,
    required double fat,
  }) : super(
          imageUrl: '',
          protein: protein.round(),
          carbs: carbs.round(),
          fat: fat.round(),
        );
}

class AiRecipesViewModel extends ChangeNotifier {
  bool _isSearching = false;
  bool _isGenerating = false;
  List<FoodProduct> _searchResults = [];
  final List<FoodProduct> _selectedIngredients = [];
  List<Recipe> _generatedRecipes = [];
  String _selectedCookingStyle = 'Stir Fry';
  String _selectedMealType = 'Lunch';
  String _errorMessage = '';

  bool get isSearching => _isSearching;
  bool get isGenerating => _isGenerating;
  List<FoodProduct> get searchResults => _searchResults;
  List<FoodProduct> get selectedIngredients => _selectedIngredients;
  List<Recipe> get generatedRecipes => _generatedRecipes;
  String get selectedCookingStyle => _selectedCookingStyle;
  String get selectedMealType => _selectedMealType;
  String get errorMessage => _errorMessage;

  void setCookingStyle(String style) {
    _selectedCookingStyle = style;
    notifyListeners();
  }

  void setMealType(String type) {
    _selectedMealType = type;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<void> searchIngredients(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await OpenFoodFactsService.searchProducts(query);
      if (results.isEmpty) {
        _searchResults = _getLocalSuggestions(query);
      } else {
        _searchResults = results;
      }
    } catch (e) {
      _searchResults = _getLocalSuggestions(query);
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void addIngredient(FoodProduct product) {
    if (!_selectedIngredients.any((p) => p.name.toLowerCase() == product.name.toLowerCase())) {
      _selectedIngredients.add(product);
      notifyListeners();
    }
  }

  void addIngredientByName(String name) {
    if (name.trim().isEmpty) return;
    final cleanName = name.trim();
    if (!_selectedIngredients.any((p) => p.name.toLowerCase() == cleanName.toLowerCase())) {
      _selectedIngredients.add(FoodProduct(
        code: 'manual_${Random().nextInt(100000)}',
        name: cleanName,
        imageUrl: '',
        ingredients: '',
        calories: 80.0,
        protein: 3.0,
        carbs: 15.0,
        fat: 2.0,
      ));
      notifyListeners();
    }
  }

  void removeIngredient(FoodProduct product) {
    _selectedIngredients.removeWhere((p) => p.code == product.code);
    notifyListeners();
  }

  void clearIngredients() {
    _selectedIngredients.clear();
    notifyListeners();
  }

  Future<void> generateRecipe() async {
    if (_selectedIngredients.isEmpty) {
      _errorMessage = 'Please add at least one ingredient.';
      notifyListeners();
      return;
    }

    _isGenerating = true;
    _errorMessage = '';
    _generatedRecipes = [];
    notifyListeners();

    final selectedIngNames = _selectedIngredients.map((e) => e.name).toList();
    final mainIng = selectedIngNames.isNotEmpty ? selectedIngNames[0] : 'Fresh Veggies';

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? const String.fromEnvironment('GEMINI_API_KEY');
      if (apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY is not defined in environment variables.');
      }
      const model = 'gemini-2.0-flash-lite-preview'; 
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');

      final prompt = '''
Generate 2 creative, seasonal Indian recipes that can be prepared using some of these ingredients: ${selectedIngNames.join(', ')}.
Cooking style/preference: $_selectedCookingStyle
Meal type: $_selectedMealType

Requirements:
- The recipes must prominently feature at least one of the provided ingredients.
- Keep ingredients list realistic and instructions clear.
- Do not include markdown code block tags in the JSON response itself.
- Return the response matching the specified JSON schema.
''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': {
              'type': 'ARRAY',
              'items': {
                'type': 'OBJECT',
                'properties': {
                  'id': {'type': 'STRING'},
                  'title': {'type': 'STRING'},
                  'duration': {'type': 'STRING'},
                  'ingredients': {
                    'type': 'ARRAY',
                    'items': {'type': 'STRING'}
                  },
                  'instructions': {
                    'type': 'ARRAY',
                    'items': {'type': 'STRING'}
                  },
                  'calories': {'type': 'INTEGER'},
                  'protein': {'type': 'NUMBER'},
                  'carbs': {'type': 'NUMBER'},
                  'fat': {'type': 'NUMBER'}
                },
                'required': [
                  'id',
                  'title',
                  'duration',
                  'ingredients',
                  'instructions',
                  'calories',
                  'protein',
                  'carbs',
                  'fat'
                ]
              }
            }
          }
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        final List<dynamic> jsonList = jsonDecode(text);

        final List<Recipe> fetchedRecipes = jsonList.map((item) {
          final title = item['title'] ?? 'Generated Recipe';
          final stableId = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

          return Recipe(
            id: stableId,
            title: title,
            duration: item['duration'] ?? '15 mins',
            ingredients: List<String>.from(item['ingredients'] ?? []),
            instructions: List<String>.from(item['instructions'] ?? []),
            calories: (item['calories'] as num?)?.toInt() ?? 250,
            protein: (item['protein'] as num?)?.toDouble() ?? 5.0,
            carbs: (item['carbs'] as num?)?.toDouble() ?? 30.0,
            fat: (item['fat'] as num?)?.toDouble() ?? 8.0,
          );
        }).toList();

        if (fetchedRecipes.isNotEmpty) {
          _generatedRecipes = fetchedRecipes;
          return;
        }
      }
      throw Exception('API error or empty response (Status: ${response.statusCode})');

    } catch (e) {
      debugPrint('Gemini API call failed, using fallback recipes: $e');
      final fallbackList = getFallbackRecipes(mainIng, selectedIngNames, _selectedMealType, _selectedCookingStyle);
      
      fallbackList.sort((a, b) {
        final style = _selectedCookingStyle.toLowerCase();
        final aMatches = _doesRecipeMatchStyle(a.id, style);
        final bMatches = _doesRecipeMatchStyle(b.id, style);
        if (aMatches && !bMatches) return -1;
        if (!aMatches && bMatches) return 1;
        return 0;
      });

      _generatedRecipes = fallbackList;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  bool _doesRecipeMatchStyle(String id, String style) {
    final cleanStyle = style.replaceAll(' ', '').toLowerCase();
    return id.contains(cleanStyle);
  }

  Future<FoodProduct?> lookupBarcode(String barcode) async {
    try {
      final product = await OpenFoodFactsService.getProductByBarcode(barcode);
      if (product != null) {
        return product;
      }
    } catch (e) {
      debugPrint('Barcode lookup error: $e');
    }
    return null;
  }

  List<FoodProduct> _getLocalSuggestions(String query) {
    final suggestions = [
      FoodProduct(code: 'sug_1', name: 'Paneer', imageUrl: '', ingredients: '', calories: 265.0, protein: 18.0, carbs: 1.2, fat: 20.8),
      FoodProduct(code: 'sug_2', name: 'Chicken Breast', imageUrl: '', ingredients: '', calories: 165.0, protein: 31.0, carbs: 0.0, fat: 3.6),
      FoodProduct(code: 'sug_3', name: 'Eggs', imageUrl: '', ingredients: '', calories: 155.0, protein: 13.0, carbs: 1.1, fat: 11.0),
      FoodProduct(code: 'sug_4', name: 'Potatoes', imageUrl: '', ingredients: '', calories: 77.0, protein: 2.0, carbs: 17.0, fat: 0.1),
      FoodProduct(code: 'sug_5', name: 'Maggi Noodles', imageUrl: '', ingredients: '', calories: 320.0, protein: 8.0, carbs: 48.0, fat: 12.0),
    ];
    return suggestions.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
