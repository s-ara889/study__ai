import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:study_ai/logic/chat_mode.dart';
import 'package:study_ai/models/chat_message.dart';
import 'package:study_ai/services/ai_service.dart';
import 'package:study_ai/services/firestore_service.dart';
import 'package:study_ai/services/prompt_service.dart';
import 'package:study_ai/widgets/message_bubble.dart';
import 'package:study_ai/services/pdf_service.dart';
import 'package:study_ai/services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatMode mode;
  final String? conversationId;

  const ChatScreen({
    super.key,
    required this.mode,
    this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller =
  TextEditingController();

  final ScrollController scrollController =
  ScrollController();

  List<ChatMessage> messages = [];

  String? conversationId;

  File? selectedFile;
  String? selectedFileName;
  String? uploadedFileUrl;
  bool isLoading = false;



  @override
  void initState() {
    super.initState();

    conversationId = widget.conversationId;

    if (conversationId != null) {
      _loadConversation();
    }
  }

  Future<void> _loadConversation() async {
    final chats =
    await FirestoreService.loadMessages(
      conversationId!,
    );

    if (!mounted) return;

    setState(() {
      messages = chats;
    });

    _scrollToBottom();
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty &&
        selectedFile == null) {
      return;
    }

    String userMessage = controller.text.trim();

    if (selectedFile != null &&
        selectedFileName != null &&
        selectedFileName!.toLowerCase().endsWith(".pdf")) {

      var pdfText =
      await PdfService.extractText(selectedFile!);

      if (pdfText.length > 15000) {
        pdfText = pdfText.substring(0, 15000);
      }

      userMessage = '''
PDF CONTENT:

$pdfText

USER QUESTION:

${controller.text}
''';
    }

    if (conversationId == null) {
      conversationId =
      await FirestoreService.createConversation(
        userMessage.isEmpty
            ? "New Chat"
            : (userMessage.length > 30
            ? userMessage.substring(0, 30)
            : userMessage),
      );
    }

    String finalMessage = userMessage;

    if (selectedFileName != null) {
      finalMessage = '''
The user attached a file named:
$selectedFileName

Unfortunately image analysis is not enabled yet.

User question:
$userMessage
''';
    }

    final userChat = ChatMessage(
      text: finalMessage,
      isUser: true,
      timestamp:
      DateTime.now().millisecondsSinceEpoch,
    );



    controller.clear();

    setState(() {
      messages.add(userChat);
      isLoading = true;
    });

    await FirestoreService.saveMessage(
      conversationId!,
      userChat,
    );
    setState(() {
      selectedFile = null;
      selectedFileName = null;
      uploadedFileUrl = null;
    });
    _scrollToBottom();

    try {
      final response =
      await AIService.sendMessage(
        message: finalMessage,
        mode: widget.mode,
        imageFile: selectedFile
      );

      final aiChat = ChatMessage(
        text: response,
        isUser: false,
        timestamp:
        DateTime.now().millisecondsSinceEpoch,
      );

      if (!mounted) return;

      setState(() {
        messages.removeLast();
        messages.add(aiChat);
        isLoading = false;
        });

      await FirestoreService.saveMessage(
        conversationId!,
        aiChat,
      );
    } catch (e) {
      final errorChat = ChatMessage(
        text: "Error: $e",
        isUser: false,
        timestamp:
        DateTime.now().millisecondsSinceEpoch,
      );

      if (!mounted) return;

      setState(() {
        messages.removeLast();
        messages.add(errorChat);
        isLoading = false;
      });

      await FirestoreService.saveMessage(
        conversationId!,
        errorChat,
      );
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 100),
          () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController
                .position.maxScrollExtent,
            duration: const Duration(
              milliseconds: 300,
            ),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  Future<void> attachFile() async {
    showModalBottomSheet(
      context: context,
      backgroundColor:
      const Color(0xFF141932),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [

              ListTile(
                leading: const Icon(
                  Icons.photo,
                  color: Colors.white,
                ),
                title: const Text(
                  "Gallery",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final picker =
                  ImagePicker();

                  final image =
                  await picker.pickImage(
                    source:
                    ImageSource.gallery,
                  );

                  if (image != null) {
                    final file = File(image.path);

                    final url =
                    await StorageService.uploadFile(
                      file,
                      image.name,
                    );

                    setState(() {
                      selectedFile = file;
                      selectedFileName = image.name;
                      uploadedFileUrl = url;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.description,
                  color: Colors.white,
                ),
                title: const Text(
                  "Document",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final result =
                  await FilePicker
                      .platform
                      .pickFiles();

                  if (result != null) {
                    final file = File(
                      result.files.single.path!,
                    );

                    final url =
                    await StorageService.uploadFile(
                      file,
                      result.files.single.name,
                    );

                    setState(() {
                      selectedFile = file;
                      selectedFileName =
                          result.files.single.name;
                      uploadedFileUrl = url;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor:
        const Color(0xFF0F1419),
        elevation: 0,
        title: Text(
          PromptService.getChatTitle(
            widget.mode,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Text(
                "Start chatting with ${PromptService.getChatTitle(widget.mode)}",
                style:
                const TextStyle(
                  color:
                  Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
                : ListView.builder(
              controller:
              scrollController,
              padding:
              const EdgeInsets
                  .all(16),
              itemCount:
              messages.length,
              itemBuilder:
                  (context,
                  index) {
                final msg =
                messages[
                index];

                return MessageBubble(
                  text: msg.text,
                  isUser:
                  msg.isUser,
                );
              },
            ),
          ),

          if (selectedFileName != null)
            Container(
              width:
              double.infinity,
              margin:
              const EdgeInsets
                  .symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              padding:
              const EdgeInsets
                  .all(12),
              decoration:
              BoxDecoration(
                color:
                const Color(
                    0xFF1E2538),
                borderRadius:
                BorderRadius
                    .circular(
                    12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .attach_file,
                    color:
                    Colors.white,
                  ),
                  const SizedBox(
                      width: 10),
                  Expanded(
                    child: Text(
                      selectedFileName!,
                      style:
                      const TextStyle(
                        color: Colors
                            .white,
                      ),
                      overflow:
                      TextOverflow
                          .ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedFile =
                        null;
                        selectedFileName =
                        null;
                      });
                    },
                    icon:
                    const Icon(
                      Icons.close,
                      color:
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),

          Container(
            padding:
            const EdgeInsets
                .all(12),
            decoration:
            const BoxDecoration(
              color:
              Color(0xFF141932),
              border: Border(
                top: BorderSide(
                  color: Color(
                      0xFF2D3548),
                ),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap:
                  attachFile,
                  child:
                  Container(
                    height: 42,
                    width: 42,
                    decoration:
                    BoxDecoration(
                      color: const Color(
                          0xFF1E2538),
                      borderRadius:
                      BorderRadius
                          .circular(
                          12),
                    ),
                    child:
                    const Icon(
                      Icons
                          .attach_file,
                      color: Colors
                          .white70,
                    ),
                  ),
                ),

                const SizedBox(
                    width: 8),


                const SizedBox(
                    width: 10),

                Expanded(
                  child:
                  TextField(
                    controller:
                    controller,
                    style:
                    const TextStyle(
                      color: Colors
                          .white,
                    ),
                    decoration:
                    InputDecoration(
                      hintText:
                      selectedFileName ==
                          null
                          ? "Ask anything..."
                          : "Ask about attached file...",
                      hintStyle:
                      const TextStyle(
                        color:
                        Colors
                            .grey,
                      ),
                      filled:
                      true,
                      fillColor:
                      const Color(
                          0xFF1E2538),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                            14),
                        borderSide:
                        BorderSide
                            .none,
                      ),
                    ),
                    onSubmitted:
                        (_) async {
                      await sendMessage();
                    },
                  ),
                ),

                const SizedBox(
                    width: 10),

                GestureDetector(
                  onTap:
                      () async {
                    await sendMessage();
                  },
                  child:
                  Container(
                    height: 46,
                    width: 46,
                    decoration:
                    const BoxDecoration(
                      color: Color(
                          0xFF3B82F6),
                      shape: BoxShape
                          .circle,
                    ),
                    child:
                    const Icon(
                      Icons.send,
                      color: Colors
                          .white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}