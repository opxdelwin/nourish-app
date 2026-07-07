import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FoodProduct {
  final String code;
  final String name;
  final String imageUrl;
  final String ingredients;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  FoodProduct({
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};
    
    // Extract calories (energy-kcal) and macro nutrients
    double calories = 0.0;
    if (nutriments['energy-kcal_100g'] != null) {
      calories = (nutriments['energy-kcal_100g'] as num).toDouble();
    } else if (nutriments['energy-kcal'] != null) {
      calories = (nutriments['energy-kcal'] as num).toDouble();
    }

    double protein = 0.0;
    if (nutriments['proteins_100g'] != null) {
      protein = (nutriments['proteins_100g'] as num).toDouble();
    } else if (nutriments['proteins'] != null) {
      protein = (nutriments['proteins'] as num).toDouble();
    }

    double carbs = 0.0;
    if (nutriments['carbohydrates_100g'] != null) {
      carbs = (nutriments['carbohydrates_100g'] as num).toDouble();
    } else if (nutriments['carbohydrates'] != null) {
      carbs = (nutriments['carbohydrates'] as num).toDouble();
    }

    double fat = 0.0;
    if (nutriments['fat_100g'] != null) {
      fat = (nutriments['fat_100g'] as num).toDouble();
    } else if (nutriments['fat'] != null) {
      fat = (nutriments['fat'] as num).toDouble();
    }

    return FoodProduct(
      code: json['code'] ?? '',
      name: json['product_name'] ?? json['product_name_en'] ?? 'Unknown Product',
      imageUrl: json['image_url'] ?? json['image_front_url'] ?? '',
      ingredients: json['ingredients_text'] ?? json['ingredients_text_en'] ?? '',
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
  }
}

class OpenFoodFactsService {
  static Future<List<FoodProduct>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=15&fields=product_name,product_name_en,image_url,image_front_url,ingredients_text,ingredients_text_en,nutriments,code'
      );
      
      final response = await http.get(url, headers: {
        'User-Agent': 'NourishApp - Flutter - Version 1.0'
      });
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final productsJson = data['products'] as List? ?? [];
        return productsJson
            .map((p) => FoodProduct.fromJson(p as Map<String, dynamic>))
            .where((p) => p.name.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error querying OpenFoodFacts API: $e');
    }
    return [];
  }

  static Future<FoodProduct?> getProductByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return null;
    
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/${barcode.trim()}.json');
      final response = await http.get(url, headers: {
        'User-Agent': 'NourishApp - Flutter - Version 1.0'
      });
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          return FoodProduct.fromJson(data['product'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Error querying OpenFoodFacts Barcode API: $e');
    }
    return null;
  }
}

