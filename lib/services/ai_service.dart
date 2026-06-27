import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:study_ai/logic/chat_mode.dart';
import 'package:study_ai/services/api_keys.dart';
import 'package:study_ai/services/prompt_service.dart';

class AIService {
  static Future<String> sendMessage({
    required String message,
    required ChatMode mode,
    File? imageFile,
  }) async {
    try {
      final String systemPrompt =
      PromptService.getSystemPrompt(mode);

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${ApiKeys.geminiApiKey}',
      );


      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {
                    "text":
                    "$systemPrompt\n\nUser question: $message"
                  },
                  {
                    "inline_data": {
                      "mime_type": "image/jpeg",
                      "data": base64Image,
                    }
                  }
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          return data["candidates"][0]["content"]["parts"][0]["text"];
        }

        return "Error: ${response.statusCode}";
      }


      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "$systemPrompt\n\nUser: $message"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["candidates"][0]["content"]["parts"][0]["text"];
      }

      return "Error: ${response.statusCode}";
    } catch (e) {
      return "Error: $e";
    }
  }
}