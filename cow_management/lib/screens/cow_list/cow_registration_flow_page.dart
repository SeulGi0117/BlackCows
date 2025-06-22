import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/models/cow.dart';
import 'package:cow_management/services/livestock_trace_service.dart';
import 'package:cow_management/services/dio_client.dart';
import 'package:cow_management/screens/cow_list/cow_add_done_page.dart';
import 'package:logging/logging.dart';

class CowRegistrationFlowPage extends StatefulWidget {
  const CowRegistrationFlowPage({super.key});

  @override
  State<CowRegistrationFlowPage> createState() => _CowRegistrationFlowPageState();
}

class _CowRegistrationFlowPageState extends State<CowRegistrationFlowPage> {
  final _logger = Logger('CowRegistrationFlowPage');
  final PageController _pageController = PageController();
  final LivestockTraceService _livestockService = LivestockTraceService();
  
  // 1단계: 이표번호 입력
  final TextEditingController _earTagController = TextEditingController();
  
  // 2단계: 축산물이력제 정보 확인
  final TextEditingController _nameController = TextEditingController();
  
  // 3단계: 수동 입력
  final TextEditingController _manualNameController = TextEditingController();
  final TextEditingController _sensorController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String _registrationStatus = '';
  Map<String, dynamic>? _livestockData;
  bool _isLoading = false;
  
  DateTime? _selectedBirthdate;
  HealthStatus? _selectedHealthStatus;
  BreedingStatus? _selectedBreedingStatus;

  @override
  void dispose() {
    _pageController.dispose();
    _earTagController.dispose();
    _nameController.dispose();
    _manualNameController.dispose();
    _sensorController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _checkRegistrationStatus() async {
    final earTag = _earTagController.text.trim();
    
    if (earTag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이표번호를 입력해주세요.')),
      );
      return;
    }

    if (earTag.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이표번호는 12자리 숫자여야 합니다.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;
      
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      final status = await _livestockService.checkRegistrationStatus(earTag, token);
      
      setState(() {
        _registrationStatus = status;
      });

      if (status == 'already_registered') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 등록된 젖소입니다.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      } else if (status == 'livestock_trace_available') {
        // 축산물이력제에서 정보 가져오기
        await _getLivestockTraceData();
        _goToNextStep();
      } else if (status == 'manual_registration_required') {
        // 축산물이력제에 정보가 없는 경우 에러 다이얼로그 표시
        _showLivestockTraceErrorDialog();
      } else {
        // 기타 상황에서도 에러 다이얼로그 표시
        _showLivestockTraceErrorDialog();
      }
    } catch (e) {
      _logger.severe('등록 상태 확인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getLivestockTraceData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken!;
      
      final data = await _livestockService.quickCheck(_earTagController.text.trim(), token);
      
      if (data != null && data['basic_info'] != null) {
        setState(() {
          _livestockData = data;
          // 기본 정보에서 이름 제안
          final basicInfo = data['basic_info'];
          if (basicInfo['cattle_no'] != null) {
            _nameController.text = '${basicInfo['cattle_no']}번 소';
          }
        });
      }
    } catch (e) {
      _logger.warning('축산물이력제 정보 조회 실패: $e');
    }
  }

  Future<void> _registerFromLivestockTrace() async {
    final cowName = _nameController.text.trim();
    
    if (cowName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('젖소 이름을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken!;
      
      final result = await _livestockService.registerFromLivestockTrace(
        _earTagController.text.trim(),
        cowName,
        token,
      );

      final newCow = Cow.fromJson(result);
      final cowProvider = Provider.of<CowProvider>(context, listen: false);
      cowProvider.addCow(newCow);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CowAddDonePage(cowName: cowName),
        ),
      );
    } catch (e) {
      _logger.severe('축산물이력제 등록 실패: $e');
      
      // 축산물이력제에서 정보를 찾을 수 없는 경우 에러 처리 페이지로 이동
      if (e.toString().contains('축산물이력제') || 
          e.toString().contains('not found') || 
          e.toString().contains('422') ||
          e.toString().contains('500')) {
        _showLivestockTraceErrorDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLivestockTraceErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('축산물이력제 정보 없음'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이표번호: ${_earTagController.text}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '축산물이력제에서 해당 이표번호의 정보를 찾을 수 없습니다.\n아래 중 하나를 선택해주세요.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            // 이표번호 다시 입력하기
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  // 첫 번째 페이지로 돌아가기
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  // 이표번호 입력 필드 초기화 및 포커스
                  _earTagController.clear();
                  _nameController.clear();
                  setState(() {
                    _registrationStatus = '';
                    _livestockData = null;
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.blue),
                label: const Text(
                  '이표번호 다시 입력하기',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 수동으로 등록하기
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  // 수동 입력 페이지로 이동
                  _goToNextStep();
                  // 이표번호를 수동 입력 페이지에 미리 설정
                  if (_manualNameController.text.isEmpty) {
                    _manualNameController.text = _nameController.text;
                  }
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  '수동으로 입력하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerManually() async {
    final cowName = _manualNameController.text.trim();
    
    if (cowName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('젖소 이름을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cowData = {
        'ear_tag_number': _earTagController.text.trim(),
        'name': cowName,
        if (_selectedBirthdate != null)
          'birthdate': _selectedBirthdate!.toIso8601String().split('T')[0],
        if (_sensorController.text.trim().isNotEmpty)
          'sensor_number': _sensorController.text.trim(),
        if (_selectedHealthStatus != null)
          'health_status': _selectedHealthStatus!.name,
        if (_selectedBreedingStatus != null)
          'breeding_status': _selectedBreedingStatus!.name,
        if (_breedController.text.trim().isNotEmpty)
          'breed': _breedController.text.trim(),
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
      };

      final response = await DioClient().dio.post('/cows/manual', data: cowData);
      final newCow = Cow.fromJson(response.data);
      
      final cowProvider = Provider.of<CowProvider>(context, listen: false);
      cowProvider.addCow(newCow);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CowAddDonePage(cowName: cowName),
        ),
      );
    } catch (e) {
      _logger.severe('수동 등록 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToNextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedBirthdate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('젖소 등록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1(), // 이표번호 입력
          _buildStep2(), // 축산물이력제 정보 확인
          _buildStep3(), // 수동 입력
        ],
      ),
    );
  }

  // 1단계: 이표번호 입력
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search,
            size: 80,
            color: Colors.pink,
          ),
          const SizedBox(height: 24),
          const Text(
            '이표번호를 입력하여\n젖소 정보를 확인합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _earTagController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '이표번호',
              hintText: '002123456789',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
              helperText: '12자리 숫자를 입력해주세요',
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _checkRegistrationStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '등록 상태 확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 2단계: 축산물이력제 정보 확인
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          const Text(
            '축산물이력제에서\n젖소 정보를 찾았습니다!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          if (_livestockData != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '확인된 정보',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_livestockData!['basic_info'] != null) ...[
                    _buildInfoRow('개체번호', _livestockData!['basic_info']['cattle_no']),
                    _buildInfoRow('출생일', _livestockData!['basic_info']['birth_date']),
                    _buildInfoRow('품종', _livestockData!['basic_info']['breed']),
                    _buildInfoRow('성별', _livestockData!['basic_info']['gender']),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '젖소 이름',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.pets),
              helperText: '원하는 이름으로 변경할 수 있습니다',
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerFromLivestockTrace,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '축산물이력제 정보로 등록',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _goToNextStep(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: const BorderSide(color: Colors.grey),
              ),
              child: const Text(
                '수동으로 입력하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3단계: 수동 입력
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(
              Icons.edit,
              size: 80,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '젖소 정보를 직접 입력해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 이름 입력
          const Text('이름 *', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _manualNameController,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                      color: _selectedBirthdate != null ? Colors.black : Colors.grey,
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
            controller: _sensorController,
            decoration: const InputDecoration(
              hintText: '센서 번호를 입력하세요',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // 품종
          const Text('품종', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _breedController,
            decoration: const InputDecoration(
              hintText: '홀스타인, 저지 등',
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
                case HealthStatus.excellent:
                  displayName = '최상';
                  break;
                case HealthStatus.good:
                  displayName = '양호';
                  break;
                case HealthStatus.average:
                  displayName = '보통';
                  break;
                case HealthStatus.poor:
                  displayName = '나쁨';
                  break;
                case HealthStatus.sick:
                  displayName = '병환';
                  break;
              }
              return DropdownMenuItem(
                value: status,
                child: Text(displayName),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedHealthStatus = value),
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
            onChanged: (value) => setState(() => _selectedBreedingStatus = value),
          ),
          const SizedBox(height: 16),

          // 메모
          const Text('메모', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '추가 정보나 특이사항을 입력하세요',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 32),

          // 등록 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registerManually,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      '수동으로 등록하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? '정보 없음'),
          ),
        ],
      ),
    );
  }
}