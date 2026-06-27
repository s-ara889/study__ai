import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<String> extractText(File file) async {
    try {
      final bytes = await file.readAsBytes();

      final PdfDocument document =
      PdfDocument(inputBytes: bytes);

      String text = PdfTextExtractor(document).extractText();

      document.dispose();

      return text;
    } catch (e) {
      return "Failed to read PDF";
    }
  }
}