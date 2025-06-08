import 'package:flutter/material.dart';
import 'package:cow_management/models/cow.dart';

class CowDetailPage extends StatelessWidget {
  final Cow cow;

  const CowDetailPage({super.key, required this.cow});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${cow.name} 상세 정보'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🐮 젖소 정보',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('이름: ${cow.name}'),
            Text('개체번호: ${cow.number}'),
            Text('출생일: ${cow.birthdate.toIso8601String().split('T')[0]}'),
            Text('품종: ${cow.breed}'),
            Text('센서 번호: ${cow.sensor}'),
            Text('상태: ${cow.status}'),
            Text('우유 생산량: ${cow.milk}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('뒤로가기'),
            ),
          ],
        ),
      ),
    );
  }
}
