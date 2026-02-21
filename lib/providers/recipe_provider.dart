import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../services/recipe_api_service.dart';

final recipeApiServiceProvider = Provider<RecipeApiService>((ref) {
  return RecipeApiService();
});

class RecipesNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    return await _fetchRecipes();
  }

  Future<List<Recipe>> _fetchRecipes() async {
    final apiService = ref.read(recipeApiServiceProvider);
    return await apiService.fetchRandomRecipes(count: 10);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchRecipes());
  }

  Future<void> searchRecipes(String query) async {
    if (query.trim().isEmpty) {
      await refresh();
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final apiService = ref.read(recipeApiServiceProvider);
      return await apiService.searchRecipes(query);
    });
  }
}

final recipesProvider = AsyncNotifierProvider<RecipesNotifier, List<Recipe>>(
  () {
    return RecipesNotifier();
  },
);

final selectedRecipeProvider = StateProvider<Recipe?>((ref) => null);
