import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // ✅ API endpoint của MyMemory
  static const String baseUrl = 'https://api.mymemory.translated.net/get';

  // Danh sách ngôn ngữ hỗ trợ (Mã chuẩn ISO)
  final List<String> supportedLanguages = ['en', 'vi', 'fr', 'de', 'es', 'zh', 'ja', 'ko'];

  // Tên hiển thị ngôn ngữ
  final Map<String, String> languageNames = {
    'en': 'Tiếng Anh',
    'vi': 'Tiếng Việt',
    'fr': 'Tiếng Pháp',
    'de': 'Tiếng Đức',
    'es': 'Tây Ban Nha',
    'zh': 'Trung Quốc',
    'ja': 'Nhật Bản',
    'ko': 'Hàn Quốc',
  };

  Future<String> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    // Kiểm tra đầu vào rỗng
    if (text.trim().isEmpty) return '';

    // Nếu nguồn và đích giống nhau thì trả về luôn
    if (sourceLanguage == targetLanguage) return text;

    try {
      // Tạo URL với tham số query
      // q: text cần dịch
      // langpair: cặp ngôn ngữ (ví dụ: en|vi)
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        'q': text,
        'langpair': '$sourceLanguage|$targetLanguage',
      });

      print('🚀 Requesting: $uri');

      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Hết thời gian chờ kết nối (Timeout). Kiểm tra mạng của bạn.');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Kiểm tra cấu trúc phản hồi của MyMemory
        if (data['responseData'] != null) {
          final translatedText = data['responseData']['translatedText'];
          print('✅ Kết quả: $translatedText');
          return translatedText ?? text;
        } else {
          // Trường hợp lỗi trả về từ API (ví dụ: quota exceeded)
          throw Exception('Lỗi API: ${data['responseStatus']} - ${data['responseDetails']}');
        }
      } else {
        throw Exception('Lỗi máy chủ (${response.statusCode})');
      }
    } catch (e) {
      print('❌ Lỗi dịch: $e');
      throw Exception('Không thể dịch: $e');
    }
  }

  // Hàm hỗ trợ lấy tên ngôn ngữ
  String getLanguageName(String code) {
    return languageNames[code] ?? code;
  }
}