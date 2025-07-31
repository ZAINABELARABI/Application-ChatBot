import 'dart:async'; // Import nécessaire pour TimeoutException
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = 'http://10.0.2.2:11434';
  final Duration timeoutDuration = const Duration(seconds: 30);

  Future<String> sendMessage(String message) async {
    try {
      // Vérification du serveur
      await http.get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));

      // Envoi du message
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'phi3',
          'prompt': message,
          'options': {'num_ctx': 1024},
          'stream': false
        }),
      ).timeout(timeoutDuration);

      return _handleResponse(response);
      
    } on TimeoutException catch (_) { // Maintenant correct
      throw Exception('Le serveur ne répond pas - vérifiez que Ollama est bien lancé');
    } on http.ClientException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  String _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'] ?? 'Pas de réponse';
    } else {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }
}