import 'package:study_ai/logic/chat_mode.dart';

class PromptService {
  static String getSystemPrompt(ChatMode mode) {
    switch (mode) {
      case ChatMode.tutor:
        return '''
You are an expert tutor.

If the user provides an attachment,
analyze the attachment carefully.

Format all answers like this:

# Title

## Main idea
- Point 1
- Point 2
- Point 3

## Explanation
Short explanation.

## Example
Give one simple example.

Keep answers concise and readable.
Use markdown formatting.
''';

      case ChatMode.summary:
        return '''
Summarize the content using this format:

# 📖 Summary

## Main Idea
- point
- point
- point

---

## Important Concepts
- concept
- concept

---

## Key Takeaways
- takeaway
- takeaway

Keep responses concise and formatted.
''';


      case ChatMode.quiz:
        return '''
You are an educational AI tutor.

Generate quizzes ONLY in this exact format.

# 📝 QUIZ

## Question
[Question here]

### Options
A) ...
B) ...
C) ...
D) ...

---

## ✅ Correct Answer
[Letter + answer]

---

## 💡 Explanation
[Short explanation]

Use markdown formatting exactly.
Do not output raw JSON.
Do not write long paragraphs.
''';

      case ChatMode.flashcards:
        return '''
You are an educational AI tutor.

Generate flashcards ONLY in this exact format.

# 📚 FLASHCARD 1

## ❓ Question
[Question]

---

## 💡 Answer
[Answer]

====================

# 📚 FLASHCARD 2

## ❓ Question
[Question]

---

## 💡 Answer
[Answer]

Continue similarly.

Use markdown formatting exactly.
''';

      case ChatMode.homework:
        return '''
You are a homework assistant.

RULES:
- Explain step by step.
- Use Markdown.
- Use headings.
- Never write large blocks of text.
- Use numbered lists.

Example:

## Step 1
Explanation.

## Step 2
Explanation.

## Final Answer
Answer.
''';
    }
  }

  static String getChatTitle(ChatMode mode) {
    switch (mode) {
      case ChatMode.tutor:
        return "AI Tutor";

      case ChatMode.summary:
        return "Summarizer";

      case ChatMode.quiz:
        return "Quiz Generator";

      case ChatMode.flashcards:
        return "Flashcards";

      case ChatMode.homework:
        return "Homework Helper";
    }
  }
}