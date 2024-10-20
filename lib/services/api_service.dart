import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiUrl = 'https://dolarapi.com/v1/dolares';

  Future<List<dynamic>> fetchDollarData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data;
      } else {
        throw Exception('Error al cargar los datos del dólar');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      throw Exception('Fallo al obtener datos de la API');
    }
  }
}
