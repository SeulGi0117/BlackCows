import 'package:flutter/material.dart';
import 'package:cow_management/models/cow.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

class CowProvider with ChangeNotifier {
  final List<Cow> _cows = [];
  final _logger = Logger('CowProvider');
  bool _favoritesLoaded = false;

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
    _favoritesLoaded = false;
    notifyListeners();
  }

  void clearCows() {
    _cows.clear();
    _favoritesLoaded = false;
    notifyListeners();
  }

  List<Cow> filterByStatus(String status) {
    return _cows.where((cow) => cow.status == status).toList();
  }

  List<Cow> get favorites => _cows.where((cow) => cow.isFavorite).toList();

  // 즐겨찾기 기능 (새로운 API 엔드포인트 사용)
  Future<void> toggleFavorite(Cow cow, String token) async {
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    final newValue = !cow.isFavorite;

    try {
      final response = await dio.patch(
        '$apiUrl/cows/${cow.id}/favorite',
        data: {'favorite': newValue},
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
        _logger.info('즐겨찾기 상태 변경 성공: ${cow.name} -> $newValue');
      } else {
        throw Exception('즐겨찾기 변경 실패: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('즐겨찾기 변경 API 오류: $e');
      throw Exception('즐겨찾기 변경 실패: $e');
    }
  }

  bool isFavoriteByName(String cowname) {
    return favorites.any((cow) => cow.name == cowname);
  }

  Future<void> toggleFavoriteByName(String cowname, String token) async {
    final cow = cows.firstWhere((c) => c.name == cowname);
    await toggleFavorite(cow, token);
  }

  // 이표번호로 젖소 검색
  Future<Cow?> searchByEarTag(String earTagNumber, String token) async {
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    try {
      final response = await dio.get(
        '$apiUrl/cows/search/by-tag/$earTagNumber',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Cow.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      _logger.warning('이표번호 검색 실패: $e');
      return null;
    }
  }

  // 농장 통계 조회
  Future<Map<String, dynamic>?> getFarmStatistics(String token) async {
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    try {
      final response = await dio.get(
        '$apiUrl/cows/statistics/summary',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      _logger.warning('농장 통계 조회 실패: $e');
      return null;
    }
  }

  // 즐겨찾기 젖소 목록 조회
  Future<List<Cow>> getFavoritesList(String token) async {
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    try {
      final response = await dio.get(
        '$apiUrl/cows/favorites/list',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        return jsonList.map((json) => Cow.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      _logger.warning('즐겨찾기 목록 조회 실패: $e');
      return [];
    }
  }

  // 젖소 상세정보 보유 여부 확인
  Future<bool> hasDetailedInfo(String cowId, String token) async {
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    try {
      final response = await dio.get(
        '$apiUrl/cows/$cowId/has-details',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['has_detailed_info'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      _logger.warning('상세정보 보유 여부 확인 실패: $e');
      return false;
    }
  }

  // 축산물이력제 정보 조회
  Future<Map<String, dynamic>?> getLivestockTraceInfo(String cowId, String token) async {
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    try {
      final response = await dio.get(
        '$apiUrl/cows/$cowId/livestock-trace-info',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      _logger.warning('축산물이력제 정보 조회 실패: $e');
      return null;
    }
  }

  void setFavorites(List<Cow> favoriteList) {
    for (final fav in favoriteList) {
      final idx = _cows.indexWhere((c) => c.id == fav.id);
      if (idx != -1) {
        _cows[idx].isFavorite = true;
      }
    }
    _favoritesLoaded = true;
    notifyListeners();
  }

  Future<void> syncFavoritesFromServer(String token) async {
    if (_favoritesLoaded) return;
    final favoritesFromServer = await getFavoritesList(token);
    setFavorites(favoritesFromServer);
  }

  // 서버에서 소 전체 목록을 불러와 setCows까지 처리하는 메서드 추가
  Future<void> fetchCowsFromBackend(String token) async {
    final dio = Dio();
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
    try {
      final response = await dio.get(
        '$apiUrl/cows/?sortDirection=DESCENDING',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final List<Cow> cows = jsonList.map((json) => Cow.fromJson(json)).toList();
        setCows(cows);
      } else {
        _logger.severe('소 목록 불러오기 실패: \\${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('소 목록 불러오기 오류: $e');
    }
  }
}