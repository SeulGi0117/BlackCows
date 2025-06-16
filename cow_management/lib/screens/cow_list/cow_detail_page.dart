import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:cow_management/models/cow.dart';
import 'package:cow_management/screens/cow_list/cow_edit_page.dart';
import 'package:cow_management/providers/user_provider.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 20),
            _buildMilkingInfoCard(),
            const SizedBox(height: 30),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pets, size: 20),
              SizedBox(width: 6),
              Text('기본 정보',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('이름', currentCow.name),
          _infoRow('개체번호', currentCow.number),
          _infoRow('품종', currentCow.breed ?? '미등록'),
          _infoRow('센서 번호', currentCow.sensor),
          _infoRow('상태', currentCow.status),
        ],
      ),
    );
  }

  Widget _buildMilkingInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_drink, size: 20),
              SizedBox(width: 6),
              Text('우유 착유 정보',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              '최근 착유량: ${currentCow.milk.isNotEmpty ? currentCow.milk : '정보 없음'}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/milking-records',
                      arguments: {
                        'cowId': currentCow.id,
                        'cowName': currentCow.name,
                      },
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('착유 기록 보기'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/milking-record',
                      arguments: {
                        'cowId': currentCow.id,
                        'cowName': currentCow.name,
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('착유 기록 추가'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
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
          child: const Text('🛠️ 정보 수정하기'),
        ),
        const SizedBox(height: 10),
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
              if (success && context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("젖소가 삭제되었습니다")));
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("삭제에 실패했습니다")));
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("❌ 삭제하기   "),
        ),
      ],
    );
  }
}

Future<bool> deleteCow(BuildContext context, String cowId) async {
  final dio = Dio();
  final String? apiUrl = dotenv.env['API_BASE_URL'];
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

    return response.statusCode == 200 || response.statusCode == 204;
  } catch (e) {
    print("❌ 삭제 중 오류 발생: $e");
    return false;
  }
}
