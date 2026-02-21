import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import '../models/recipe.dart';

class RecipeApiService {
  static const String apiKey = '2097da0deb87495284ae0040017f1514';
  static const String baseUrl = 'https://api.spoonacular.com';
  final translator = GoogleTranslator();

  Future<List<Recipe>> fetchRandomRecipes({int count = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recipes/random?number=$count&apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['recipes'] != null) {
          final recipes = (data['recipes'] as List)
              .map((recipe) => _parseRecipe(recipe))
              .toList();

          // Translate all recipes in parallel
          final translatedRecipes = await Future.wait(
            recipes.map((recipe) => translateRecipe(recipe)),
          );

          return translatedRecipes;
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching recipes: $e');
    }
    return [];
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/recipes/complexSearch?query=$query&number=10&addRecipeInformation=true&apiKey=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final recipes = (data['results'] as List)
              .map((recipe) => _parseRecipe(recipe))
              .toList();

          // Translate all recipes in parallel
          final translatedRecipes = await Future.wait(
            recipes.map((recipe) => translateRecipe(recipe)),
          );

          return translatedRecipes;
        }
      }
    } catch (e) {
      print('Error searching recipes: $e');
    }
    return [];
  }

  Recipe _parseRecipe(Map<String, dynamic> recipe) {
    // Extract ingredients from extendedIngredients or analyzedInstructions
    final ingredients = <String>[];

    if (recipe['extendedIngredients'] != null) {
      for (var ingredient in recipe['extendedIngredients']) {
        final amount = ingredient['amount']?.toString() ?? '';
        final unit = ingredient['unit']?.toString() ?? '';
        final name = ingredient['name']?.toString() ?? '';

        if (name.isNotEmpty) {
          final full = '$amount $unit $name'.trim();
          ingredients.add(full);
        }
      }
    }

    // Extract instructions
    final instructions = <String>[];

    // Try analyzedInstructions first (more structured)
    if (recipe['analyzedInstructions'] != null &&
        recipe['analyzedInstructions'].isNotEmpty) {
      final analyzed = recipe['analyzedInstructions'][0];
      if (analyzed['steps'] != null) {
        for (var step in analyzed['steps']) {
          final stepText = step['step']?.toString() ?? '';
          if (stepText.isNotEmpty) {
            instructions.add(stepText);
          }
        }
      }
    }

    // Fallback to plain instructions text
    if (instructions.isEmpty && recipe['instructions'] != null) {
      final instructionsText = recipe['instructions'].toString();
      instructions.addAll(
        instructionsText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList(),
      );
    }

    // Get cuisine types
    final cuisines = recipe['cuisines'] != null
        ? (recipe['cuisines'] as List).join(', ')
        : '';

    final dishTypes = recipe['dishTypes'] != null
        ? (recipe['dishTypes'] as List).join(', ')
        : '';

    final category = dishTypes.isNotEmpty ? dishTypes : 'Variado';
    final description = cuisines.isNotEmpty
        ? 'Cocina $cuisines'
        : 'Deliciosa receta';

    return Recipe(
      id:
          recipe['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: recipe['title'] ?? 'Receta Desconocida',
      description: description,
      category: category,
      ingredients: ingredients,
      instructions: instructions.isNotEmpty
          ? instructions
          : ['Instrucciones no disponibles'],
    );
  }

  // Translate recipe to Spanish using Google Translate API
  Future<Recipe> translateRecipe(Recipe recipe) async {
    try {
      // Translate all fields in parallel
      final results = await Future.wait([
        // Translate ingredients in parallel
        Future.wait(
          recipe.ingredients.map((ingredient) =>
            translator.translate(ingredient, from: 'en', to: 'es')
              .then((t) => t.text)
              .catchError((_) => ingredient)
          ),
        ),
        // Translate instructions in parallel
        Future.wait(
          recipe.instructions.map((instruction) =>
            translator.translate(instruction, from: 'en', to: 'es')
              .then((t) => t.text)
              .catchError((_) => instruction)
          ),
        ),
        // Translate name
        translator.translate(recipe.name, from: 'en', to: 'es')
          .then((t) => t.text)
          .catchError((_) => recipe.name),
      ]);

      final translatedIngredients = results[0] as List<String>;
      final translatedInstructions = results[1] as List<String>;
      final translatedName = results[2] as String;

      return Recipe(
        id: recipe.id,
        name: translatedName,
        description: recipe.description,
        category: recipe.category,
        ingredients: translatedIngredients,
        instructions: translatedInstructions,
      );
    } catch (e) {
      print('Translation error: $e');
      return recipe;
    }
  }
}
