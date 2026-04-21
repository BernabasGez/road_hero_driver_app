import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/datasources/home_remote_source.dart';
import '../bloc/home_cubit.dart';

class AiDiagnosticScreen extends StatefulWidget {
  const AiDiagnosticScreen({super.key});

  @override
  State<AiDiagnosticScreen> createState() => _AiDiagnosticScreenState();
}

class _AiDiagnosticScreenState extends State<AiDiagnosticScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  int? _selectedVehicleId;
  bool _thinking = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _thinking = true;
    });
    _scrollToBottom();

    try {
      final result = await sl<HomeRemoteSource>().diagnose(
        symptoms: text,
        vehicleId: _selectedVehicleId,
      );

      final diagnosis = result['diagnosis'] ?? result['message'] ?? 'I could not determine the issue.';
      final suggestedProviders = result['suggested_providers'];

      setState(() {
        _messages.add(_ChatMessage(text: diagnosis.toString(), isUser: false));
        if (suggestedProviders is List && suggestedProviders.isNotEmpty) {
          _messages.add(_ChatMessage(
            text: 'I found ${suggestedProviders.length} nearby provider(s) that can help.',
            isUser: false,
            isAction: true,
          ));
        }
        _thinking = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(text: 'Sorry, something went wrong: $e', isUser: false));
        _thinking = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Virtual Mechanic'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Vehicle selector
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.vehicles.isEmpty) return const SizedBox();
              return Container(
                color: AppColors.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<int?>(
                        value: _selectedVehicleId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Select vehicle (optional)'),
                        style: AppTextStyles.bodySmall,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('No vehicle selected')),
                          ...state.vehicles.map((v) => DropdownMenuItem(
                                value: v.id,
                                child: Text('${v.displayName} (${v.plateNumber})'),
                              )),
                        ],
                        onChanged: (v) => setState(() => _selectedVehicleId = v),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.smart_toy_outlined, size: 40, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          const Text('Describe your car issue', style: AppTextStyles.sectionHeader),
                          const SizedBox(height: 8),
                          const Text(
                            'I\'ll analyze the symptoms and suggest possible causes and solutions.',
                            style: AppTextStyles.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    itemCount: _messages.length + (_thinking ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length) {
                        // Thinking indicator
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Analyzing...', style: AppTextStyles.bodySmall),
                              ],
                            ),
                          ),
                        );
                      }
                      final msg = _messages[i];
                      return _ChatBubble(message: msg);
                    },
                  ),
          ),
          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 8, MediaQuery.of(context).padding.bottom + 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Describe what\'s wrong...',
                      hintStyle: AppTextStyles.inputHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
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

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isAction;
  _ChatMessage({required this.text, required this.isUser, this.isAction = false});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary
              : message.isAction
                  ? AppColors.accent.withValues(alpha: 0.1)
                  : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
