import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cow_management/models/cow.dart';
import 'package:cow_management/screens/cow_list/cow_edit_page.dart';
import 'package:cow_management/providers/user_provider.dart'; // 추가: UserProvider import

class CowDetailPage extends StatefulWidget {
  final Cow cow;

  const CowDetailPage({super.key, required this.cow});

  @override
  State<CowDetailPage> createState() => _CowDetailPageState();
}

class _CowDetailPageState extends State<CowDetailPage> {
  late Cow currentCow;

  @override
  void initState() {
    super.initState();
    currentCow = widget.cow;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentCow.name} 상세 정보'),
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
            Text('이름: ${currentCow.name}'),
            Text('개체번호: ${currentCow.number}'),
            Text('품종: ${currentCow.breed}'),
            Text('센서 번호: ${currentCow.sensor}'),
            Text('상태: ${currentCow.status}'),
            Text('우유 생산량: ${currentCow.milk}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('뒤로가기'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedCow = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CowEditPage(cow: currentCow),
                  ),
                );

                if (updatedCow != null && updatedCow is Cow) {
                  setState(() {
                    currentCow = updatedCow;
                  });
                }
              },
              child: const Text('수정하기'),
            ),
            ElevatedButton(
              onPressed: () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("삭제 확인"),
                    content: const Text("정말 이 젖소를 삭제하시겠습니까?"),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("취소")),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("삭제")),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final success = await deleteCow(context, currentCow.id);
                  if (success) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("젖소가 삭제되었습니다")),
                      );
                      Navigator.pop(context, true);
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("삭제에 실패했습니다")),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("삭제하기"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> deleteCow(BuildContext context, String cowId) async {
  final dio = Dio();
  final String? apiUrl = dotenv.env['API_BASE_URL'];

  // UserProvider에서 토큰 로드
  final token = await Provider.of<UserProvider>(context, listen: false)
      .loadTokenFromStorage();

  if (apiUrl == null || token == null) {
    print("❌ API 주소 또는 토큰 없음");
    return false;
  }

  try {
    final response = await dio.delete(
      '$apiUrl/cows/$cowId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print("❌ 삭제 실패: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("❌ 삭제 중 오류 발생: $e");
    return false;
  }
}
