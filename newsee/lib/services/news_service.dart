import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchInterests() async {
  final response = await http.get(Uri.parse("YOUR_API_URL"));

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    return (result["data"] as List)
        .map((item) => {
              "categoryId": item["categoryId"],
              "categoryName": item["categoryName"],
            })
        .toList();
  } else {
    throw Exception("Failed to load interests");
  }
}
