import 'package:flutter/material.dart';
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
    {"role": "ai", "text": "Hello! Describe the issue your car is having."},
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
      final result = await sl<HomeRemoteSource>().diagnoseIssue(text);
      setState(() {
        _messages.add({
          "role": "ai",
          "text": result['ai_response'] ?? "I'm checking that...",
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
          "text": "Connection issue. Please try again.",
        });
        isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Virtual Mechanic"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildBubble(_messages[index]),
            ),
          ),
          if (isTyping)
            const LinearProgressIndicator(
              color: AppColors.primaryBlue,
              minHeight: 2,
            ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg) {
    bool isAi = msg['role'] == 'ai';
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAi ? Colors.grey.shade100 : AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isAi ? Radius.zero : const Radius.circular(16),
            bottomRight: isAi ? const Radius.circular(16) : Radius.zero,
          ),
        ),
        child: Text(
          msg['text'],
          style: TextStyle(color: isAi ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type issue...",
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
          IconButton(
            onPressed: isTyping ? null : _sendMessage,
            icon: const Icon(Icons.send, color: AppColors.actionOrange),
          ),
        ],
      ),
    );
  }
}
