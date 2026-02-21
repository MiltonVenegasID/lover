import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../models/web_product.dart';

class WebProductsNotifier extends StateNotifier<List<WebProduct>> {
  WebProductsNotifier() : super([]);

  Future<void> addProduct(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // Fetch product metadata from URL
    final metadata = await _fetchProductMetadata(url);

    final newProduct = WebProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: url,
      title: metadata['title'] ?? _extractTitle(url),
      description: metadata['description'] ?? 'Product from ${uri.host}',
      imageUrl: metadata['image'] ?? '',
    );

    state = [...state, newProduct];
  }

  Future<Map<String, String?>> _fetchProductMetadata(String url) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Try Open Graph tags first (most e-commerce sites use these)
        String? title = document
            .querySelector('meta[property="og:title"]')
            ?.attributes['content'];
        String? image = document
            .querySelector('meta[property="og:image"]')
            ?.attributes['content'];
        String? description = document
            .querySelector('meta[property="og:description"]')
            ?.attributes['content'];

        // Fallback to Twitter Card tags
        title ??= document
            .querySelector('meta[name="twitter:title"]')
            ?.attributes['content'];
        image ??= document
            .querySelector('meta[name="twitter:image"]')
            ?.attributes['content'];
        description ??= document
            .querySelector('meta[name="twitter:description"]')
            ?.attributes['content'];

        // Fallback to regular meta tags and title
        title ??= document.querySelector('title')?.text;
        description ??= document
            .querySelector('meta[name="description"]')
            ?.attributes['content'];

        return {
          'title': title?.trim(),
          'image': image?.trim(),
          'description': description?.trim(),
        };
      }
    } catch (e) {
      print('Error fetching product metadata: $e');
    }
    return {};
  }

  String _extractTitle(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return 'Product';

    final path = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'Product';
    return path.replaceAll('-', ' ').replaceAll('_', ' ');
  }

  void removeProduct(String id) {
    state = state.where((product) => product.id != id).toList();
  }
}

final webProductsProvider =
    StateNotifierProvider<WebProductsNotifier, List<WebProduct>>((ref) {
      return WebProductsNotifier();
    });
