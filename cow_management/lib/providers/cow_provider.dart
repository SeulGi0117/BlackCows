import 'package:flutter/material.dart';
import 'package:cow_management/models/cow.dart';

class CowProvider with ChangeNotifier {
  final List<Cow> _cows = [];

  List<Cow> get cows => List.unmodifiable(_cows);

  void addCow(Cow cow) {
    _cows.add(cow);
    notifyListeners();
  }

  void removeCow(String id) {
    _cows.removeWhere((cow) => cow.name == id); // cow ID로 비교해도 OK
    notifyListeners();
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
  void toggleFavorite(Cow cow) {
    cow.isFavorite = !cow.isFavorite;
    notifyListeners();
  }

  bool isFavoriteByName(String cowname) {
    return favorites.any((cow) => cow.name == cowname);
  }

  void toggleFavoriteByName(String cowname) {
    final cow = cows.firstWhere((c) => c.name == cowname);
    toggleFavorite(cow); // 기존에 정의된 toggleFavorite 사용
  }
}
