// 필요한 위젯들 import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cow_management/screens/cow_list/cow_add_done_page.dart';

class CowAddPage extends StatefulWidget {
  const CowAddPage({super.key});

  @override
  State<CowAddPage> createState() => _CowAddPageState();
}

class _CowAddPageState extends State<CowAddPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sensorController = TextEditingController();
  final TextEditingController healthController = TextEditingController();
  String? _selectedReproStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('젖소 기록 추가'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '새로운 젖소의 정보 추가',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('개체 번호'),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                hintText: 'ABC12345',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('이름 (별명)'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: '김젖례',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('센서 번호'),
            TextField(
              controller: sensorController,
              decoration: const InputDecoration(
                hintText: '13-Digit Sensor Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('건강상태'),
            TextField(
              controller: healthController,
              decoration: const InputDecoration(
                hintText: '건강 양호 / 이상',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('번식 상태'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _selectedReproStatus,
              hint: const Text('번식 상태를 선택하세요'),
              items: const [
                DropdownMenuItem(value: '발정 전', child: Text('발정 전')),
                DropdownMenuItem(value: '배란 임박', child: Text('배란 임박')),
                DropdownMenuItem(value: '임신 확인', child: Text('임신 확인')),
                DropdownMenuItem(value: '번식 완료', child: Text('번식 완료')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedReproStatus = value;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  // 유효성 검사
                  if (idController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      sensorController.text.isEmpty ||
                      healthController.text.isEmpty ||
                      _selectedReproStatus == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('모든 정보를 입력해주세요!'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  final cowName = nameController.text;
                  final cowData = {
                    'id': idController.text,
                    'name': cowName,
                    'sensor': sensorController.text,
                    'health': healthController.text,
                    'reproductive': _selectedReproStatus ?? '',
                  };

                  final url = Uri.parse('http://your-server.com/api/cows/');

                  try {
                    final response = await http.post(
                      url,
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(cowData),
                    );

                    if (!mounted) return;

                    if (response.statusCode == 201) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CowAddDonePage(cowName: cowName),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('오류: ${response.statusCode}')),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('에러 발생: $e')),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
