import 'package:flutter/material.dart';
import 'package:road_hero/core/di/injection_container.dart';
import 'package:road_hero/core/theme/app_colors.dart';
import 'package:road_hero/features/home/data/datasources/home_remote_source.dart';

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
      // The method name is 'diagnose' and it takes a named parameter 'symptoms'
      final result = await sl<HomeRemoteSource>().diagnose(symptoms: text);

      setState(() {
        _messages.add({
          "role": "ai",
          // The new API returns 'diagnosis'
          "text":
              result['diagnosis'] ?? result['message'] ?? "I'm not quite sure.",
          "action": result['suggested_providers'] != null ? "service" : null,
        });
        isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "ai",
          "text": "I'm having trouble connecting. Try again later.",
        });
        isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
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
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isAi = msg['role'] == 'ai';
                return Align(
                  alignment: isAi
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isAi
                          ? Colors.grey.shade100
                          : AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomLeft: isAi
                            ? Radius.zero
                            : const Radius.circular(16),
                        bottomRight: isAi
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isAi ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
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

  Widget _buildInput() {
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
              decoration: const InputDecoration(
                hintText: "Describe the issue...",
                border: OutlineInputBorder(),
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
