import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:snipper_frontend/models.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-url.com/api/user';

  static Future<UserProduct?> getUserProduct(String sellerEmail, String id) async {
    final uri = Uri.parse('$baseUrl/get-product?seller=$sellerEmail&id=$id');
    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer your_access_token_here',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProduct.fromJson(data['userPrdt']);
      } else {
        print('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching product: $e');
    }
    return null;
  }
}
