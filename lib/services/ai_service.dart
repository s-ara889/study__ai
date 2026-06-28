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

      // =========================
      // IMAGE REQUEST
      // =========================
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
        }

        final body = jsonEncode({
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
        });

        var response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: body,
        );

        // Retry once if quota exceeded
        if (response.statusCode == 429) {
          await Future.delayed(
            const Duration(seconds: 35),
          );

          response = await http.post(
            uri,
            headers: {
              'Content-Type': 'application/json',
            },
            body: body,
          );
        }

        print("IMAGE STATUS: ${response.statusCode}");
        print(response.body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          return data["candidates"][0]
          ["content"]["parts"][0]["text"];
        }

        if (response.statusCode == 429) {
          return '''
⚠️ StudyAI is receiving too many requests right now.

Please wait about one minute and try again.
''';
        }

        return '''
⚠️ Unable to analyze the image.

Please try another image.
''';
      }

      // =========================
      // TEXT REQUEST
      // =========================
      final body = jsonEncode({
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
      });

      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // Retry once if quota exceeded
      if (response.statusCode == 429) {
        await Future.delayed(
          const Duration(seconds: 35),
        );

        response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: body,
        );
      }

      print("TEXT STATUS: ${response.statusCode}");
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["candidates"][0]
        ["content"]["parts"][0]["text"];
      }

      if (response.statusCode == 429) {
        return '''
⚠️ StudyAI is receiving too many requests right now.

Please wait about one minute and try again.
''';
      }

      return '''
⚠️ Something went wrong.

Please try again later.
''';
    } catch (e) {
      print(e);

      return '''
⚠️ Unable to contact the AI service.

Please check your internet connection and try again.
''';
    }
  }
}