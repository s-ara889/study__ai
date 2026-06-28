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
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${ApiKeys.geminiApiKey}',
      );

      // IMAGE + TEXT
      if (imageFile != null) {
        print("IMAGE FILE: ${imageFile.path}");

        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        String mimeType = "image/jpeg";

        final path = imageFile.path.toLowerCase();

        if (path.endsWith(".png")) {
          mimeType = "image/png";
        } else if (path.endsWith(".webp")) {
          mimeType = "image/webp";
        } else if (path.endsWith(".jpeg")) {
          mimeType = "image/jpeg";
        } else if (path.endsWith(".jpg")) {
          mimeType = "image/jpeg";
        }

        print("MIME TYPE: $mimeType");

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
                    "$systemPrompt\n\nUser question:\n$message"
                  },
                  {
                    "inline_data": {
                      "mime_type": mimeType,
                      "data": base64Image,
                    }
                  }
                ]
              }
            ]
          }),
        );

        print("IMAGE STATUS: ${response.statusCode}");
        print("IMAGE RESPONSE:");
        print(response.body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          return data["candidates"][0]["content"]["parts"][0]["text"];
        }

        return "Error ${response.statusCode}\n${response.body}";
      }

      // TEXT ONLY
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
                  "$systemPrompt\n\nUser:\n$message"
                }
              ]
            }
          ]
        }),
      );

      print("TEXT STATUS: ${response.statusCode}");
      print("TEXT RESPONSE:");
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["candidates"][0]["content"]["parts"][0]["text"];
      }

      return "Error ${response.statusCode}\n${response.body}";
    } catch (e) {
      print(e);
      return "Error: $e";
    }
  }
}