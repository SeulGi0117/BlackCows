import 'package:flutter/material.dart';
import 'package:cow_management/models/cow.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class CowProvider with ChangeNotifier {
  final List<Cow> _cows = [];

  List<Cow> get cows => List.unmodifiable(_cows);

  void addCow(Cow cow) {
    _cows.add(cow);
    notifyListeners();
  }

  void removeCow(String id) {
    _cows.removeWhere((cow) => cow.id == id);
    notifyListeners();
  }

  void updateCow(Cow updatedCow) {
    final index = _cows.indexWhere((c) => c.id == updatedCow.id);
    if (index != -1) {
      _cows[index] = updatedCow;
      notifyListeners();
    }
  }

  void setCows(List<Cow> newList) {
    _cows.clear();
    _cows.addAll(newList);
    notifyListeners();
  }

  void clearCows() {
    _cows.clear();
    notifyListeners();
  }

  List<Cow> filterByStatus(String status) {
    return _cows.where((cow) => cow.status == status).toList();
  }

  List<Cow> get favorites => _cows.where((cow) => cow.isFavorite).toList();

  // 즐겨찾기 기능
  Future<void> toggleFavorite(Cow cow, String token) async {
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    final newValue = !cow.isFavorite;

    try {
      final response = await dio.post(
        '$apiUrl/cows/${cow.id}/favorite',
        data: {'favorite': true}, // 또는 false
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        cow.isFavorite = newValue;
        notifyListeners();
      } else {
        throw Exception('즐겨찾기 변경 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API 오류: $e');
    }
  }

  bool isFavoriteByName(String cowname) {
    return favorites.any((cow) => cow.name == cowname);
  }

  Future<void> toggleFavoriteByName(String cowname, String token) async {
    final cow = cows.firstWhere((c) => c.name == cowname);
    await toggleFavorite(cow, token);
  }
}
