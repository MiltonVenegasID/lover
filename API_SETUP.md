# API Key Setup

## Spoonacular API

This app uses the Spoonacular API to fetch recipes in Spanish.

### How to get your FREE API key:

1. Go to https://spoonacular.com/food-api/console
2. Click "Get Access" or "Start Now"
3. Create a free account
4. Copy your API key from the dashboard
5. Open `lib/services/recipe_api_service.dart`
6. Replace `'YOUR_API_KEY'` with your actual API key

```dart
static const String apiKey = 'YOUR_API_KEY'; // Replace this
```

### Free Tier Limits:
- 150 requests per day
- Perfect for testing and personal use

### Note:
The app won't load recipes until you add a valid API key.
