// 필요한 위젯들 import
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cow_management/models/cow.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/services/dio_client.dart';
import 'package:dio/dio.dart';

enum AddStep {
  inputEarTag,      // 이표번호 입력 단계
  showApiResult,    // API 조회 결과 표시 단계
  manualInput,      // 수동 입력 단계
}

class CowAddPage extends StatefulWidget {
  const CowAddPage({super.key});

  @override
  State<CowAddPage> createState() => _CowAddPageState();
}

class _CowAddPageState extends State<CowAddPage> {
  final TextEditingController earTagController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sensorController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? _selectedBirthdate;
  HealthStatus? _selectedHealthStatus;
  BreedingStatus? _selectedBreedingStatus;
  bool _isLoading = false;

  @override
  void dispose() {
    earTagController.dispose();
    nameController.dispose();
    sensorController.dispose();
    breedController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
      });
    }
  }

  Future<void> _addCow() async {
    if (_isLoading) return;

    if (earTagController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이표번호와 이름은 필수 입력 항목입니다!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cowData = {
        'ear_tag_number': earTagController.text.trim(),
        'name': nameController.text.trim(),
        if (_selectedBirthdate != null)
          'birthdate': _selectedBirthdate!.toIso8601String().split('T')[0],
        if (sensorController.text.trim().isNotEmpty)
          'sensor_number': sensorController.text.trim(),
        if (_selectedHealthStatus != null)
          'health_status': _selectedHealthStatus!.name,
        if (_selectedBreedingStatus != null)
          'breeding_status': _selectedBreedingStatus!.name,
        if (breedController.text.trim().isNotEmpty)
          'breed': breedController.text.trim(),
        if (notesController.text.trim().isNotEmpty)
          'notes': notesController.text.trim(),
      };

      final response = await DioClient().dio.post('/cows/', data: cowData);

      final newCow = Cow.fromJson(response.data);
      if (!mounted) return;

      final cowProvider = Provider.of<CowProvider>(context, listen: false);
      cowProvider.addCow(newCow);

      // 토스트 메시지 표시
      Fluttertoast.showToast(
        msg: "${nameController.text.trim()} 젖소 추가가 완료되었습니다!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      
      // 소 목록 페이지로 돌아가기
      Navigator.popUntil(context, (route) => route.isFirst);
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      String message;

      if (detail is String) {
        message = detail;
      } else if (detail is List) {
        // FastAPI 유효성 검사 오류 대응
        message = detail.map((d) => d['msg'] ?? '알 수 없는 오류').join(', ');
      } else {
        message = '소 등록 실패: ${e.message}';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('젖소 등록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '새로운 젖소 정보 등록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // 이표번호 (필수)
            const Text('이표번호 *', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: earTagController,
              decoration: const InputDecoration(
                hintText: 'ABC12345',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 이름 (필수)
            const Text('이름 *', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: '젖소 이름을 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 출생일
            const Text('출생일', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectBirthdate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedBirthdate != null
                          ? '${_selectedBirthdate!.year}-${_selectedBirthdate!.month.toString().padLeft(2, '0')}-${_selectedBirthdate!.day.toString().padLeft(2, '0')}'
                          : '출생일을 선택하세요',
                      style: TextStyle(
                        color: _selectedBirthdate != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 센서 번호
            const Text('센서 번호', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: sensorController,
              decoration: const InputDecoration(
                hintText: '센서 번호를 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 건강 상태
            const Text('건강 상태', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<HealthStatus>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _selectedHealthStatus,
              hint: const Text('건강 상태를 선택하세요'),
              items: HealthStatus.values.map((status) {
                String displayName;
                switch (status) {
                  case HealthStatus.normal:
                    displayName = '양호';
                    break;
                  case HealthStatus.warning:
                    displayName = '경고';
                    break;
                  case HealthStatus.danger:
                    displayName = '위험';
                    break;
                }
                return DropdownMenuItem(
                  value: status,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHealthStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 번식 상태
            const Text('번식 상태', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<BreedingStatus>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              value: _selectedBreedingStatus,
              hint: const Text('번식 상태를 선택하세요'),
              items: BreedingStatus.values.map((status) {
                String displayName;
                switch (status) {
                  case BreedingStatus.calf:
                    displayName = '송아지';
                    break;
                  case BreedingStatus.heifer:
                    displayName = '미경산';
                    break;
                  case BreedingStatus.pregnant:
                    displayName = '임신';
                    break;
                  case BreedingStatus.lactating:
                    displayName = '비유';
                    break;
                  case BreedingStatus.dry:
                    displayName = '건유';
                    break;
                  case BreedingStatus.breeding:
                    displayName = '교배';
                    break;
                }
                return DropdownMenuItem(
                  value: status,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBreedingStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // 품종
            const Text('품종', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: breedController,
              decoration: const InputDecoration(
                hintText: '홀스타인, 저지 등',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 메모
            const Text('메모', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '추가 정보나 특이사항을 입력하세요',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addCow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '등록하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '* 표시된 항목은 필수 입력 항목입니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
