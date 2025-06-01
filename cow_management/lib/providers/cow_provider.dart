import 'package:flutter/material.dart';
import '../models/cow.dart';

class CowProvider with ChangeNotifier {
  final List<Cow> _cows = [];

  List<Cow> get cows => List.unmodifiable(_cows);

  void addCow(Cow cow) {
    _cows.add(cow);
    notifyListeners();
  }

  void removeCow(String id) {
    _cows.removeWhere((cow) => cow.cow_name == id); // cow ID로 비교해도 OK
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

  List<Cow> filterByStatus(CowStatus status) {
    return _cows.where((cow) => cow.status == status).toList();
  }
}
