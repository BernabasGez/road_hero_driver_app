import 'package:flutter/material.dart';
// Using Package Import is safer and fixes the "sl" not found error
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';

class VirtualMechanicScreen extends StatefulWidget {
  const VirtualMechanicScreen({super.key});

  @override
  State<VirtualMechanicScreen> createState() => _VirtualMechanicScreenState();
}

class _VirtualMechanicScreenState extends State<VirtualMechanicScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "role": "ai",
      "text":
          "Hello! I'm your AI Mechanic. Describe the noise or issue your car is having.",
    },
  ];
  bool isTyping = false;

  Future<void> _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
      isTyping = true;
    });

    try {
      // Calling the AI API via the Service Locator (sl)
      final result = await sl<HomeRemoteSource>().diagnoseIssue(text);
      setState(() {
        _messages.add({
          "role": "ai",
          "text": result['ai_response'],
          "action": result['requires_mechanic'] == true
              ? result['recommended_service_type']
              : null,
        });
        isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "ai",
          "text":
              "The AI is taking a bit long. Please check your signal and try again.",
        });
        isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Virtual Mechanic",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isAi = msg['role'] == 'ai';
                return _buildChatBubble(msg, isAi);
              },
            ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primaryBlue,
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg, bool isAi) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isAi
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(14),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            decoration: BoxDecoration(
              color: isAi ? Colors.grey.shade100 : AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isAi
                    ? const Radius.circular(0)
                    : const Radius.circular(16),
                bottomRight: isAi
                    ? const Radius.circular(16)
                    : const Radius.circular(0),
              ),
            ),
            child: Text(
              msg['text']!,
              style: TextStyle(
                color: isAi ? Colors.black87 : Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          if (isAi && msg['action'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Searching for ${msg['action']}..."),
                    ),
                  );
                },
                icon: const Icon(Icons.search, size: 16),
                label: Text("Find ${msg['action']}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionOrange,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Describe the issue...",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: isTyping ? null : _sendMessage,
            backgroundColor: AppColors.actionOrange,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
