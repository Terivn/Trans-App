import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../models/translation_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TranslationProvider extends ChangeNotifier {
  final TranslationService _service = TranslationService();

  String _sourceLanguage = 'en';
  String _targetLanguage = 'vi';
  String _inputText = '';
  String _outputText = '';
  bool _isLoading = false;
  String? _error;
  List<TranslationHistory> _history = [];
  int _retryCount = 0;

  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  String get inputText => _inputText;
  String get outputText => _outputText;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TranslationHistory> get history => _history;

  TranslationProvider() {
    _loadHistory();
  }

  void setSourceLanguage(String lang) {
    _sourceLanguage = lang;
    notifyListeners();
  }

  void setTargetLanguage(String lang) {
    _targetLanguage = lang;
    notifyListeners();
  }

  void setInputText(String text) {
    _inputText = text;
    _error = null;
    notifyListeners();
  }

  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;

    final tempText = _inputText;
    _inputText = _outputText;
    _outputText = tempText;

    notifyListeners();
  }
  Future<void> translate() async {
    if (_inputText.trim().isEmpty) {
      _error = 'Vui lòng nhập văn bản';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gọi service mới
      final result = await _service.translate(
        text: _inputText,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      _outputText = result;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _outputText = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _performTranslation() async {
    try {
      final result = await _service.translate(
        text: _inputText,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
      );

      _outputText = result;
      _retryCount = 0;

      final historyItem = TranslationHistory(
        sourceText: _inputText,
        translatedText: result,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
        timestamp: DateTime.now(),
      );

      _history.insert(0, historyItem);
      if (_history.length > 50) {
        _history = _history.sublist(0, 50);
      }

      await _saveHistory();

    } catch (e) {
      final errorMsg = e.toString();

      if (errorMsg.contains('Model đang') && _retryCount < 2) {
        _retryCount++;
        _error = 'Đang khởi động model... (Lần thử ${_retryCount}/2)';
        notifyListeners();

        await Future.delayed(const Duration(seconds: 20));
        await _performTranslation();
        return;
      }

      _error = errorMsg.replaceAll('Exception: ', '');
      _outputText = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearInput() {
    _inputText = '';
    _outputText = '';
    _error = null;
    _retryCount = 0;
    notifyListeners();
  }

  void clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _history.map((h) => h.toJson()).toList();
    await prefs.setString('translation_history', jsonEncode(jsonList));
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('translation_history');

      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode('translation_history');
        _history = decodedList
            .map((json) => TranslationHistory.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading history: $e');
    }
  }
}