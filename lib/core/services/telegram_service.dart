import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TelegramService {
  // Use the existing Telegram bot token from OpenClaw config
  // Token: stored in memory, will be fetched from config
  
  static const String _telegramApi = 'https://api.telegram.org/bot';
  static String? _botToken;

  static void setBotToken(String token) {
    _botToken = token;
  }

  static Future<void> sendMessage(String chatId, String text) async {
    if (_botToken == null) return;
    
    try {
      await http.post(
        Uri.parse('$_telegramApi$_botToken/sendMessage'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': text,
          'parse_mode': 'HTML',
          'disable_web_page_preview': true,
        }),
      );
    } catch (e) {
      debugPrint('Telegram error: $e');
    }
  }

  static Future<void> sendApprovalAlert(String chatId, String agent, String preview) async {
    final text = '''
📋 <b>Approval Required</b>

Agent: ${agent}
Preview: ${preview.length > 100 ? preview.substring(0, 100) + '...' : preview}

<a href="missioncontrol://approvals">Open Mission Control</a>
''';
    await sendMessage(chatId, text);
  }

  static Future<void> sendAgentActiveAlert(String chatId, String agent, String task) async {
    final text = '🤖 <b>Agent Active</b>\n\n${agent} started: $task';
    await sendMessage(chatId, text);
  }

  static Future<void> sendTaskDoneAlert(String chatId, String agent, String task) async {
    final text = '✅ <b>Task Done</b>\n\n${agent}: $task';
    await sendMessage(chatId, text);
  }
}
