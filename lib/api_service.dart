import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.1.8:8001/products';

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load products: ${response.body}");
    }
  }

Future<void> createProduct(String name, String description, double price) async {
  final response = await http.post(
    Uri.parse(baseUrl),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      'name': name,
      'description': description,
      'price': price,
    }),
  );

  print("🔹 Response Status Code: ${response.statusCode}");
  print("🔹 Response Body: ${response.body}");

  if (response.statusCode != 201) {  // ❌ อาจเป็น 200 ทำให้ Flutter เข้าใจผิด
    throw Exception("Failed to create product: ${response.body}");
  }
}






  Future<void> updateProduct(String id, String name, String description, double price) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update product: ${response.body}");
    }
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete product: ${response.body}");
    }
  }
}
