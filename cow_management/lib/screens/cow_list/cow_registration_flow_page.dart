import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/models/cow.dart';
import 'package:cow_management/services/livestock_trace_service.dart';
import 'package:cow_management/services/dio_client.dart';
import 'package:logging/logging.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum RegistrationStep {
  inputEarTag,          // 이표번호 입력 단계
  quickInfoLoading,     // 빠른 정보 조회 중
  quickInfoResult,      // 빠른 정보 결과 표시 (사용자 확인)
  detailedInfoLoading,  // 상세 정보 조회 중 (사용자가 이름 입력하는 동안)
  showNotFound,         // 정보 없음 안내 단계
  manualInput,          // 수동 입력 단계
}

class CowRegistrationFlowPage extends StatefulWidget {
  const CowRegistrationFlowPage({super.key});

  @override
  State<CowRegistrationFlowPage> createState() => _CowRegistrationFlowPageState();
}

class _CowRegistrationFlowPageState extends State<CowRegistrationFlowPage> {
  final _logger = Logger('CowRegistrationFlowPage');
  final PageController _pageController = PageController();
  final LivestockTraceService _livestockService = LivestockTraceService();
  
  // 단계 관리
  RegistrationStep _currentStep = RegistrationStep.inputEarTag;
  
  // 컨트롤러들
  final TextEditingController _earTagController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sensorController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // 상태 변수들
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _quickCowInfo;      // 빠른 조회 결과
  Map<String, dynamic>? _detailedCowInfo;   // 상세 조회 결과
  String? _currentEarTag;
  double _loadingProgress = 0.0;            // 로딩 진행률
  String _loadingMessage = '';              // 로딩 메시지
  
  // 수동 입력용 변수들
  DateTime? _selectedBirthdate;
  HealthStatus? _selectedHealthStatus;
  BreedingStatus? _selectedBreedingStatus;

  @override
  void dispose() {
    _pageController.dispose();
    _earTagController.dispose();
    _nameController.dispose();
    _sensorController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // 이표번호 유효성 검사
  bool _validateEarTag(String earTag) {
    if (earTag.length != 12) return false;
    if (!RegExp(r'^\d{12}$').hasMatch(earTag)) return false;
    if (!earTag.startsWith('002')) return false;
    return true;
  }

  // 1단계: 빠른 기본 정보 조회
  Future<void> _searchQuickInfo() async {
    final earTag = _earTagController.text.trim();
    
    if (!_validateEarTag(earTag)) {
      setState(() {
        _errorMessage = '이표번호는 002로 시작하는 12자리 숫자여야 합니다.';
      });
      return;
    }

    setState(() {
      _currentStep = RegistrationStep.quickInfoLoading;
      _isLoading = true;
      _errorMessage = null;
      _currentEarTag = earTag;
      _loadingProgress = 0.0;
      _loadingMessage = '이표번호 확인 중...';
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;
      
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 프로그레스 업데이트
      setState(() {
        _loadingProgress = 0.3;
        _loadingMessage = '등록 상태 확인 중...';
      });

      // 등록 상태 확인
      final registrationStatus = await _livestockService.checkRegistrationStatus(earTag, token);
      
      if (registrationStatus == 'already_registered') {
        setState(() {
          _errorMessage = '이미 등록된 젖소입니다.';
          _currentStep = RegistrationStep.inputEarTag;
          _isLoading = false;
        });
        return;
      }

      // 프로그레스 업데이트
      setState(() {
        _loadingProgress = 0.6;
        _loadingMessage = '기본 정보 조회 중...';
      });

      // 빠른 기본 정보 조회
      final quickInfo = await _livestockService.getQuickCowInfo(earTag, token);
      
      if (quickInfo != null && quickInfo['success'] == true) {
        // 프로그레스 완료
        setState(() {
          _loadingProgress = 1.0;
          _loadingMessage = '정보 조회 완료!';
        });

        // 잠시 대기 후 결과 표시
        await Future.delayed(const Duration(milliseconds: 500));
        
        setState(() {
          _quickCowInfo = quickInfo;
          _currentStep = RegistrationStep.quickInfoResult;
          _isLoading = false;
        });

        // 백그라운드에서 상세 정보 조회 요청
        _requestDetailedInfoInBackground(earTag, token);
        
      } else {
        // 정보 없음
        setState(() {
          _currentStep = RegistrationStep.showNotFound;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '조회 중 오류가 발생했습니다: ${e.toString()}';
        _currentStep = RegistrationStep.inputEarTag;
        _isLoading = false;
      });
    }
  }

  // 백그라운드에서 상세 정보 조회 요청
  void _requestDetailedInfoInBackground(String earTag, String token) {
    _logger.info('백그라운드에서 상세 정보 조회 요청');
    _livestockService.requestDetailedInfo(earTag, token);
  }

  // 상세 정보 조회 상태 확인 및 대기
  Future<void> _waitForDetailedInfo() async {
    if (_currentEarTag == null) return;

    setState(() {
      _currentStep = RegistrationStep.detailedInfoLoading;
      _isLoading = true;
      _loadingProgress = 0.0;
      _loadingMessage = '상세 정보 조회 중...';
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;
      
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 최대 30초 동안 5초마다 상태 확인
      for (int i = 0; i < 6; i++) {
        setState(() {
          _loadingProgress = (i + 1) / 6;
          _loadingMessage = '상세 정보 처리 중... (${i * 5 + 5}초)';
        });

        final statusInfo = await _livestockService.checkDetailedInfoStatus(_currentEarTag!, token);
        
        if (statusInfo != null && statusInfo['status'] == 'completed') {
          _detailedCowInfo = statusInfo['data'];
          break;
        }

        if (i < 5) {
          await Future.delayed(const Duration(seconds: 5));
        }
      }

      // 등록 진행
      await _registerCow();
      
    } catch (e) {
      setState(() {
        _errorMessage = '상세 정보 조회 중 오류가 발생했습니다: ${e.toString()}';
        _currentStep = RegistrationStep.quickInfoResult;
        _isLoading = false;
      });
    }
  }

  // 젖소 등록 실행
  Future<void> _registerCow() async {
    final cowName = _nameController.text.trim();
    
    if (cowName.isEmpty) {
      setState(() {
        _errorMessage = '젖소 이름(별명)을 입력해주세요.';
        _currentStep = RegistrationStep.quickInfoResult;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _loadingMessage = '젖소 등록 중...';
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;
      
      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await _livestockService.registerFromLivestockTraceV2(
        _currentEarTag!,
        cowName,
        token,
      );

      if (response['success'] == true) {
        final cowProvider = Provider.of<CowProvider>(context, listen: false);
        final newCow = Cow.fromJson(response['cow_info']);
        cowProvider.addCow(newCow);

        if (!mounted) return;
        
        // 토스트 메시지 표시
        Fluttertoast.showToast(
          msg: "$cowName 젖소 추가가 완료되었습니다!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        
        // 소 목록 페이지로 돌아가기
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        throw Exception(response['message'] ?? '등록에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '등록 중 오류가 발생했습니다: ${e.toString()}';
        _currentStep = RegistrationStep.quickInfoResult;
        _isLoading = false;
      });
    }
  }

  // 수동 입력 준비
  void _prepareManualInput() {
    if (_currentEarTag != null) {
      _earTagController.text = _currentEarTag!;
    }
    setState(() {
      _currentStep = RegistrationStep.manualInput;
    });
  }



  // 수동 등록
  Future<void> _registerManually() async {
    final earTag = _earTagController.text.trim();
    final cowName = _nameController.text.trim();

    if (!_validateEarTag(earTag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이표번호는 002로 시작하는 12자리 숫자여야 합니다.')),
      );
      return;
    }

    if (cowName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('젖소 이름을 입력해주세요.')),
      );
      return;
    }

    if (_selectedBirthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('출생일을 선택해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cowData = {
        'ear_tag_number': earTag,
        'name': cowName,
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
      
      if (!mounted) return;
      final cowProvider = Provider.of<CowProvider>(context, listen: false);
      cowProvider.addCow(newCow);

      // 토스트 메시지 표시
      Fluttertoast.showToast(
        msg: "$cowName 젖소 추가가 완료되었습니다!",
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

  // 출생일 선택
  Future<void> _selectBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
      helpText: '출생일 선택',
      cancelText: '취소',
      confirmText: '확인',
      fieldLabelText: '출생일',
      fieldHintText: 'yyyy/mm/dd',
      errorFormatText: '올바른 날짜 형식을 입력하세요',
      errorInvalidText: '유효한 날짜를 입력하세요',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
      });
    }
  }

  // 단계별 위젯 빌드
  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case RegistrationStep.inputEarTag:
        return _buildEarTagInputStep();
      case RegistrationStep.quickInfoLoading:
        return _buildQuickInfoLoadingStep();
      case RegistrationStep.quickInfoResult:
        return _buildQuickInfoResultStep();
      case RegistrationStep.detailedInfoLoading:
        return _buildDetailedInfoLoadingStep();
      case RegistrationStep.showNotFound:
        return _buildNotFoundStep();
      case RegistrationStep.manualInput:
        return _buildManualInputStep();
    }
  }

  // 1단계: 이표번호 입력
  Widget _buildEarTagInputStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '젖소 이표번호 입력',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '002로 시작하는 12자리 이표번호를 입력해주세요.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        const Text('이표번호 *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _earTagController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: const InputDecoration(
            hintText: '002123456789',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            if (_errorMessage != null) {
              setState(() => _errorMessage = null);
            }
          },
        ),
        
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _searchQuickInfo,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '조회하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  // 2단계: 빠른 정보 조회 중
  Widget _buildQuickInfoLoadingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '젖소 정보 조회 중...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '축산물이력제에서 정보를 찾고 있습니다. 잠시만 기다려주세요.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        LinearProgressIndicator(
          value: _loadingProgress,
          backgroundColor: Colors.grey.shade200,
          color: Colors.pink,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          _loadingMessage,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // 3단계: 빠른 정보 결과 표시 (사용자 확인)
  Widget _buildQuickInfoResultStep() {
    final basicInfo = _quickCowInfo?['basic_info'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '젖소 정보 확인',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '축산물이력제에서 조회된 정보입니다. 이 젖소가 맞나요?',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        // 조회된 젖소 정보 표시
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이표번호: ${basicInfo?['ear_tag_number'] ?? _currentEarTag}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (basicInfo?['birth_date'] != null)
                Text('출생일: ${basicInfo['birth_date']}'),
              if (basicInfo?['breed'] != null)
                Text('품종: ${basicInfo['breed']}'),
              if (basicInfo?['gender'] != null)
                Text('성별: ${basicInfo['gender']}'),
              if (basicInfo?['age_months'] != null)
                Text('개월령: ${basicInfo['age_months']}개월'),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 이름 입력
        const Text('젖소 이름(별명) *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: '젖소 이름을 입력하세요',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _currentStep = RegistrationStep.inputEarTag;
                    _quickCowInfo = null;
                    _nameController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('이표번호 다시입력'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _waitForDetailedInfo,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '이 젖소로 등록하기',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4단계: 상세 정보 조회 중 (사용자가 이름 입력하는 동안)
  Widget _buildDetailedInfoLoadingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '젖소 정보 조회 중...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '축산물이력제에서 정보를 찾고 있습니다. 잠시만 기다려주세요.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        LinearProgressIndicator(
          value: _loadingProgress,
          backgroundColor: Colors.grey.shade200,
          color: Colors.pink,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          _loadingMessage,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // 정보 없음 안내 단계
  Widget _buildNotFoundStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '축산물이력제 정보 없음',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        
        // 안내 메시지
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이표번호: $_currentEarTag',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '축산물이력제에서 해당 이표번호의 정보를 찾을 수 없습니다.\n아래 중 하나를 선택해주세요.',
                      style: TextStyle(color: Colors.orange.shade700, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // 선택 옵션들
        Column(
          children: [
            // 이표번호 다시 입력
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep = RegistrationStep.inputEarTag;
                    _errorMessage = null;
                    _earTagController.clear();
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.blue),
                label: const Text(
                  '이표번호 다시 입력하기',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 직접 입력하여 등록
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep = RegistrationStep.manualInput;
                    _errorMessage = null;
                  });
                  _prepareManualInput();
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  '젖소 정보 직접 입력하여 젖소 추가하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // 추가 안내
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '이표번호를 다시 확인하거나, 축산물이력제에 등록되지 않은 젖소의 경우 직접 정보를 입력하여 등록할 수 있습니다.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3단계: 수동 입력
  Widget _buildManualInputStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '젖소 정보 직접 입력',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        
        const Text(
          '젖소 정보를 직접 입력하여 등록할 수 있습니다.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // 이표번호 (필수)
        const Text('이표번호 *', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _earTagController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          decoration: const InputDecoration(
            hintText: '002123456789',
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
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: '젖소 이름을 입력하세요',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // 출생일 (필수)
        const Text('출생일 *', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectBirthdate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _selectedBirthdate == null ? Colors.red.shade300 : Colors.grey,
                width: _selectedBirthdate == null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedBirthdate != null
                      ? '${_selectedBirthdate!.year}년 ${_selectedBirthdate!.month}월 ${_selectedBirthdate!.day}일'
                      : '출생일을 선택하세요 *',
                  style: TextStyle(
                    color: _selectedBirthdate != null ? Colors.black : Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.calendar_today, 
                  color: _selectedBirthdate == null ? Colors.red.shade300 : Colors.grey,
                ),
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
          controller: _breedController,
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

        // 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _currentStep = RegistrationStep.inputEarTag;
                    _errorMessage = null;
                    _nameController.clear();
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('이표번호 다시입력'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerManually,
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
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '등록하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '* 표시된 항목은 필수 입력 항목입니다.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('젖소 등록 (신버전)'),
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
        child: _buildCurrentStep(),
      ),
    );
  }
}