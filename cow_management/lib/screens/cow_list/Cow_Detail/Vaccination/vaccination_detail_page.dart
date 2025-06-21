import 'package:flutter/material.dart';

class VaccinationDetailPage extends StatelessWidget {
  final String cowId;
  final String cowName;

  const VaccinationDetailPage({
    super.key,
    required this.cowId,
    required this.cowName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$cowName 백신접종 상세'),
      ),
      body: const Center(
        child: Text('백신접종 기록 상세보기 페이지 구현 예정'),
      ),
    );
  }
}
