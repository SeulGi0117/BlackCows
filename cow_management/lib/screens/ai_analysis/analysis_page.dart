import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'analysis_tab_controller.dart';
import 'analysis_input_mode_toggle.dart';
import 'analysis_form_autofill.dart';
import 'analysis_form_manual.dart';
import 'analysis_result_card.dart';
import 'package:cow_management/services/ai_prediction_api.dart'; // API import 추가

// 착유량 분석 결과 모델 추가
class MilkYieldAnalysisResult {
  final double? predictedYield;
  final double? confidence; // AI 확신 정도

  MilkYieldAnalysisResult({this.predictedYield, this.confidence});
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with TickerProviderStateMixin {
  String selectedServiceId = 'milk_yield';
  // inputMode 및 관련 상태 제거
  bool isLoading = false;
  bool hasResult = false;
  String mastitisMode = 'with_scc'; // 'with_scc' or 'without_scc'
  bool isMastitisModeWithSCC = true; // 체세포수 모드 (true: 체세포수 있음, false: 체세포수 없음)
  File? selectedImage;
  Map<String, dynamic> resultData = {};
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _predict(String? temperature, String? milkVolume, [String? confidence]) async {
    setState(() {
      isLoading = true;
      hasResult = false;
    });

    if (selectedServiceId == 'milk_yield') {
      final predictedYield = double.tryParse(milkVolume ?? '');
      final confidenceValue = double.tryParse(confidence ?? '');
      if (predictedYield != null) {
        setState(() {
          isLoading = false;
          hasResult = true;
          resultData = {
            'prediction': '${predictedYield.toStringAsFixed(2)}L',
            'confidence': confidenceValue != null ? '${confidenceValue.toStringAsFixed(1)}%' : 'N/A',
            'predictedYield': predictedYield,
            'confidenceValue': confidenceValue,
            'trend': 'stable',
            'details': {
              '예측 착유량': '${predictedYield.toStringAsFixed(2)}L',
              'AI 확신도': confidenceValue != null ? '${confidenceValue.toStringAsFixed(1)}%' : 'N/A',
              'AI 정확도': '82%'
            },
            // 권장사항 안내 제거
          };
        });
      } else {
        setState(() {
          isLoading = false;
          hasResult = false;
        });
      }
    } else {
      // 기존 더미 결과 데이터 생성 (다른 서비스)
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
          hasResult = true;
          resultData = _generateDummyResult();
        });
      });
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('AI 분석이 완료되었습니다!'),
          ],
        ),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Map<String, dynamic> _generateDummyResult() {
    switch (selectedServiceId) {
      case 'milk_yield':
        return {
          'prediction': '24.5L',
          'confidence': '92%',
          'trend': 'stable',
          'details': {
            '예측 착유량': '24.5L (±1.5L)',
            '전일 대비': '+0.8L (↑3.4%)',
            '평균 대비': '+1.2L (↑5.1%)',
            '신뢰도': '92.1%'
          },
          'recommendations': [
            '현재 사료 배합이 적절합니다',
            '온도 관리를 지속해주세요',
            '정기적인 건강 검진 권장'
          ]
        };
      case 'mastitis_risk':
        if (mastitisMode == 'with_scc') {
          return {
            'prediction': '정상',
            'confidence': '95%',
            'level': 1,
            'details': {
              '위험도': '정상 범위',
              '체세포수': '185,000 cells/mL',
              '정상범위': '< 200,000 cells/mL',
              '신뢰도': '95.2%'
            },
            'recommendations': [
              '체세포수가 정상 범위 내입니다',
              '현재 관리 방법을 유지하세요',
              '정기적인 검사 계속 권장'
            ]
          };
        } else {
          return {
            'prediction': '관찰',
            'confidence': '78%',
            'level': 2,
            'details': {
              '위험도': '관찰 필요',
              '전도율': '보통',
              '유지방비율': '정상',
              '신뢰도': '78.3%'
            },
            'recommendations': [
              '체세포수 검사를 권장합니다',
              '유방 청결 관리 강화',
              '1주일 후 재검사 권장'
            ]
          };
        }
      case 'milk_quality':
        return {
          'prediction': '양호',
          'confidence': '88%',
          'grade': 'B',
          'details': {
            '품질 등급': 'B등급',
            '유지방': '3.5%',
            '유단백': '3.1%',
            '유당': '4.7%'
          },
          'recommendations': [
            '사료 배합을 조정해보세요',
            '온도 관리를 개선하세요',
            '정기적인 품질 검사 권장'
          ]
        };
      case 'feed_efficiency':
        return {
          'prediction': '82.1%',
          'confidence': '89%',
          'efficiency': 'medium',
          'details': {
            '사료 효율': '82.1%',
            '사료 대비 착유량': '1.28L/kg',
            '경제성 지수': '보통',
            '개선 여지': '17.9%'
          },
          'recommendations': [
            '사료 효율 개선이 필요합니다',
            '체형점수 관리를 강화하세요',
            '운동량 증가를 권장합니다'
          ]
        };
      case 'calving_prediction':
        return {
          'prediction': '14일 후',
          'confidence': '85%',
          'date': '2024-02-22',
          'details': {
            '예상 분만일': '2024년 2월 22일',
            '현재 임신일': '266일',
            '분만 확률': '85.2%',
            '건강 상태': '양호'
          },
          'recommendations': [
            '분만실 준비를 시작하세요',
            '24시간 관찰 체계 구축',
            '수의사 연락처 준비'
          ]
        };
      case 'breeding_timing':
        return {
          'prediction': '관찰 필요',
          'confidence': '75%',
          'timing': 'monitoring',
          'details': {
            '발정 상태': '관찰 중',
            '발정 강도': '약함',
            '성공 확률': '75.3%',
            '다음 관찰': '6시간 후'
          },
          'recommendations': [
            '발정 관찰을 지속하세요',
            '6시간 후 재검사 권장',
            '수정사 연락 준비'
          ]
        };
      case 'lumpy_skin_detection':
        // 이미지가 있을 때와 없을 때 다른 결과 반환
        if (selectedImage != null) {
          // 이미지가 있을 때는 실제 분석 결과 시뮬레이션
          return {
            'prediction': '정상',
            'confidence': '96%',
            'detected_areas': 0,
            'details': {
              '진단 결과': '정상',
              '감염 부위': '없음',
              '심각도': '없음',
              '신뢰도': '96.1%'
            },
            'recommendations': [
              '현재 상태가 정상입니다',
              '정기적인 건강 관찰 지속',
              '예방 접종 일정 확인'
            ],
            'warning': false
          };
        } else {
          // 이미지가 없을 때는 기본 메시지
          return {
            'prediction': '이미지 필요',
            'confidence': '0%',
            'detected_areas': 0,
            'details': {
              '진단 결과': '이미지 업로드 필요',
              '감염 부위': '분석 불가',
              '심각도': '분석 불가',
              '신뢰도': '0%'
            },
            'recommendations': [
              '소의 피부 상태를 촬영한 사진을 업로드해주세요',
              '명확한 사진일수록 정확한 진단이 가능합니다',
              '여러 각도에서 촬영하면 더 정확합니다'
            ],
            'warning': false
          };
        }
      default:
        return {};
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedService =
        analysisTabs.firstWhere((s) => s.id == selectedServiceId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('AI 분석 센터'),
        elevation: 0,
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 섹션
                _buildHeaderSection(selectedService),
                const SizedBox(height: 24),

                // AI 서비스 선택 카드
                _buildServiceSelectionCard(),
                const SizedBox(height: 24),

                // 유방염 모드 선택
                if (selectedServiceId == 'mastitis_risk') ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings, color: Colors.grey.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              '분석 모드 선택',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildMastitisToggleOption(
                                  '체세포수 있음',
                                  Icons.check_circle,
                                  '정확도 높음',
                                  mastitisMode == 'with_scc',
                                  () => setState(() {
                                    mastitisMode = 'with_scc';
                                    isMastitisModeWithSCC = true;
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMastitisToggleOption(
                                  '체세포수 없음',
                                  Icons.help_outline,
                                  '추정 분석',
                                  mastitisMode == 'without_scc',
                                  () => setState(() {
                                    mastitisMode = 'without_scc';
                                    isMastitisModeWithSCC = false;
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mastitisMode == 'with_scc' 
                              ? '* 체세포수 데이터를 기반으로 정확한 위험도를 4단계로 분석합니다.'
                              : '* 다양한 생체 지표를 기반으로 염증 가능성을 3단계로 추정합니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // AI 확신도/정확도 안내 섹션
                if (selectedServiceId == 'milk_yield') ...[
                  _buildAIInfoSection(),
                  const SizedBox(height: 24),
                ],

                // 입력 방식 선택 및 토글 제거
                // 입력 폼 (직접 입력만)
                if (selectedServiceId != 'lumpy_skin_detection') ...[
                  _buildInputForm(),
                  const SizedBox(height: 24),
                ],

                // 럼피스킨병 이미지 업로드 섹션
                if (selectedServiceId == 'lumpy_skin_detection') ...[
                  const SizedBox(height: 24),
                  _buildLumpySkinImageSection(),
                  const SizedBox(height: 24),
                ],

                // 로딩 섹션
                if (isLoading) _buildLoadingSection(),

                // 결과 섹션
                if (hasResult) _buildResultSection(selectedService),
                
                // 하단 패딩 (키보드 대응)
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AnalysisTab selectedService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf3f3f3), Color(0xFFf3f3f3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  selectedService.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          selectedService.label,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        if (selectedService.isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.black, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedService.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                    if (selectedService.subtitle != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          selectedService.subtitle!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text(
                '분석 서비스 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: analysisTabs.map((service) {
              final isSelected = selectedServiceId == service.id;
              final isPremium = service.isPremium;
              return GestureDetector(
                onTap: () {
                  if (service.id == 'milk_yield' || service.id == 'mastitis_risk') {
                    setState(() => selectedServiceId = service.id);
                  } else {
                    // 안내 팝업 (SnackBar)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('아직 기능 준비 중입니다.'),
                        backgroundColor: Colors.grey.shade800,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFFf3f3f3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF4caf50)
                          : Colors.grey.shade300,
                      width: 2,
                    ),                  
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPremium) ...[
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        service.icon,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        service.label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.black // 일반 서비스는 검은색
                              : Colors.black, // 일반 서비스는 검은색
                        ),
                      ),
                      if (isPremium && !isSelected) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFED7D79),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI 모델 성능 지표',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // AI 확신도
          _buildInfoRow(
            '🤖 AI 확신도',
            '이번 예측에 대한 AI의 확신 정도',
            '100개 AI모델이 모두 비슷한 답을 하면 확신도가 높고, 제각각 다른 답을 하면 확신도가 낮습니다.',
            '확신도가 높아도 실제와 다를 수 있어요. 참고용으로만 활용하세요.',
          ),
          
          const SizedBox(height: 12),
          
          // AI 정확도
          _buildInfoRow(
            '🎯 AI 정확도',
            '모델의 전체적인 성능',
            '수천 개 학습 데이터로 테스트한 결과, 평균 82% 정확도를 보입니다.',
            '개별 예측은 이와 다를 수 있어요.',
          ),
          
          const SizedBox(height: 12),
          
          // 모델 성능 지표
          _buildModelPerformanceRow(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String subtitle, String description, String warning) {
    return GestureDetector(
      onTap: () => _showInfoDialog(title, subtitle, description, warning),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildModelPerformanceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'AI 모델 성능 지표',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 모델 성능 지표
          _buildModelPerformanceRow(),
        ],
      ),
    );
  }

  Widget _buildModelPerformanceRow() {
    return GestureDetector(
      onTap: () => _showModelPerformanceDialog(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📈 모델 성능 지표',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MAE 3.41 / RMSE 4.94 / R² 0.821',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }



  void _showInfoDialog(String title, String subtitle, String description, String warning) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 12),
            Text(
              warning,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('알겠어요'),
          ),
        ],
      ),
    );
  }

  void _showModelPerformanceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📈 회귀 모델 성능 지표 해석'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MAE 3.41 / RMSE 4.94 / R² 0.821',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '이 모델의 예측 성능을 아래와 같이 해석할 수 있습니다:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              
              // MAE
              _buildPerformanceItem(
                '1. MAE (Mean Absolute Error) = 3.41',
                '평균적으로 실제 값과 예측 값 사이의 절대 오차가 3.41입니다.',
                '예: 착유량이 30L인 소의 예측값이 33.4L 또는 26.6L 정도로 오차가 발생할 수 있다는 의미입니다.',
                '해석: 오차의 평균 크기가 작을수록 좋은 성능. 3.41은 상대적으로 양호한 수준입니다.',
              ),
              
              const SizedBox(height: 16),
              
              // RMSE
              _buildPerformanceItem(
                '2. RMSE (Root Mean Squared Error) = 4.94',
                '큰 오차에 더 민감하게 반응하는 지표.',
                '오차를 제곱해서 평균 후 루트를 씌우므로 MAE보다 항상 크거나 같습니다.',
                '해석: 큰 오차가 일부 존재하지만, 평균적으로도 오차가 5 이하로 유지되고 있다는 점에서 꽤 안정적인 모델입니다.',
              ),
              
              const SizedBox(height: 16),
              
              // R²
              _buildPerformanceItem(
                '3. R² (결정계수) = 0.821',
                '모델이 전체 데이터의 분산 중 82.1%를 설명하고 있다는 의미입니다.',
                '0.0이면 아무 설명 못함, 1.0이면 완벽한 예측.',
                '해석: 입력 변수들이 종속 변수(예: 착유량)를 잘 설명하고 있고, 모델도 해당 패턴을 잘 학습한 상태입니다.',
              ),
              
              const SizedBox(height: 16),
              
              // 종합 해석
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '종합 해석:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '전반적으로 설명력(R²)이 높고, MAE, RMSE도 안정적입니다.',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '일부 예측에서 5~6 정도의 오차가 있을 수 있으나, 일반적인 착유 예측 모델 수준에서는 우수한 성능으로 평가할 수 있습니다.',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '단, "착유량의 단위"가 L이고, 평균 착유량이 예를 들어 30~40L이라면, 이 수준의 오차는 실제 착유량 적용에도 충분히 가능한 모델일 가능성이 높습니다.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('알겠어요'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String title, String description, String example, String interpretation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          example,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          interpretation,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text(
                '분석 데이터 입력',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 오직 직접 입력만 사용
          AnalysisFormManual(
            onPredict: _predict,
            selectedServiceId: selectedServiceId,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'AI가 분석 중입니다...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(AnalysisTab selectedService) {
    final isWarning = resultData['warning'] == true;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 럼피스킨병 경고 메시지
          if (selectedServiceId == 'lumpy_skin_detection') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dangerous, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '럼피스킨병 주의사항',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '럼피스킨병은 소에게 발생하는 제1종 가축전염병으로, 치사율은 낮지만 전파력이 강하고 가축 피해가 커서 중요합니다. 특히 젖소에게는 치명적이며, 유량 감소, 고기 및 가죽 손상 등의 피해를 유발할 수 있습니다.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '럼피스킨병의 중요성:\n'
                    '• 가축 전염병: 럼피스킨병은 가축 전염병 예방법상 제1종 가축전염병으로 지정되어 있으며, 발생 시 세계동물보건기구(WOAH)에 보고해야 합니다.\n'
                    '• 전염력 강함: 럼피스킨병은 흡혈 곤충 (파리, 모기, 진드기 등)을 통해 빠르게 전파되며, 감염 소의 이동으로 인해 원거리 전파도 가능합니다.\n'
                    '• 경제적 피해: 럼피스킨병은 소의 유량 감소, 육질 및 가죽 손상 등 심각한 경제적 피해를 초래할 수 있습니다.\n'
                    '• 치명적인 질병: 특히 젖소의 경우 럼피스킨병 발병 시 유량 생산성이 급격히 감소하여 농가에 큰 경제적 타격을 줄 수 있습니다.\n'
                    '• 백신 접종 필요: 럼피스킨병 예방을 위해 백신 접종이 필수적이며, 백신 접종 후 약 3주 정도가 지나야 면역력이 형성됩니다.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '럼피스킨병 예방 및 관리:\n'
                    '• 백신 접종: 럼피스킨병 예방을 위해 농가에서는 백신 접종을 실시해야 합니다.\n'
                    '• 방역 관리: 백신 접종 후에도 흡혈 곤충 등에 의한 감염 가능성이 있으므로, 철저한 방역 관리가 필요합니다.\n'
                    '• 발생 시 즉각 신고: 럼피스킨병 발생 시 즉시 방역 당국에 신고하여 확산 방지에 힘써야 합니다.\n'
                    '• 농장 소독: 농장 내 소독 및 위생 관리를 철저히 해야 합니다.\n'
                    '• 감염 의심 소 격리: 감염이 의심되는 소는 즉시 격리하여 다른 소들에게 전파되는 것을 막아야 합니다.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• 즉시 방역 당국(1588-9060)에 신고\n• 감염 의심 소 즉시 격리\n• 농장 전체 소독 실시\n• 백신 접종 및 방역 관리 강화',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // 럼피스킨병 특별 결과 표시
          if (selectedServiceId == 'lumpy_skin_detection') ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.orange.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'AI 이미지 진단 결과',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 이미지 업로드 섹션
                  if (selectedImage == null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '이미지를 업로드해주세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '소의 피부 상태를 촬영한 사진을 업로드하면\nAI가 럼피스킨병 감염 여부를 분석합니다',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.upload),
                            label: const Text('이미지 선택'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // 이미지 분석 결과 표시
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '원본 이미지',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImage!,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AI 분석 결과',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange, width: 2),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(
                                        selectedImage!,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    // 바운딩박스 시뮬레이션 (정상일 때는 표시하지 않음)
                                    if (resultData['prediction'] == '럼피스킨병 의심') ...[
                                      Positioned(
                                        top: 30,
                                        left: 20,
                                        child: Container(
                                          width: 80,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.red, width: 3),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.8),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              '감염부위 1',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.refresh),
                            label: const Text('이미지 변경'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
          
          // 일반 서비스 결과 표시 (럼피스킨병이 아닐 때만)
          if (selectedServiceId != 'lumpy_skin_detection') ...[
            _buildServiceSpecificResult(selectedService),
          ],
          
          // 상세 정보 (null 체크 추가)
          if (resultData['details'] != null && resultData['details'] is Map) ...[
            const SizedBox(height: 20),
            const Text(
              '상세 분석',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(resultData['details'] as Map<String, dynamic>).entries.map<Widget>((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          const SizedBox(height: 20),
          
          // 권장사항 (null 체크 추가)
          if (resultData['recommendations'] != null && resultData['recommendations'] is List) ...[
            const Text(
              '권장사항',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(resultData['recommendations'] as List).map<Widget>((recommendation) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isWarning ? Colors.red.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: isWarning ? Border.all(color: Colors.red.shade200) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isWarning ? Icons.warning : Icons.lightbulb_outline,
                      color: isWarning ? Colors.red : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recommendation.toString(),
                        style: TextStyle(
                          color: isWarning ? Colors.red.shade700 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMastitisToggleOption(String label, IconData icon, String sublabel, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade400 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey.shade500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSpecificResult(AnalysisTab selectedService) {
    switch (selectedServiceId) {
      case 'milk_yield':
        return _buildMilkYieldResult(selectedService);
      case 'mastitis_risk':
        return _buildMastitisResult(selectedService);
      case 'milk_quality':
        return _buildMilkQualityResult(selectedService);
      case 'feed_efficiency':
        return _buildFeedEfficiencyResult(selectedService);
      case 'calving_prediction':
        return _buildCalvingResult(selectedService);
      case 'breeding_timing':
        return _buildBreedingResult(selectedService);
      default:
        return _buildDefaultResult(selectedService);
    }
  }

  Widget _buildMilkYieldResult(AnalysisTab selectedService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                '착유량 예측 결과',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('예측 착유량:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(
                    resultData['prediction'] ?? '',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('AI 확신도:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Text(
                    resultData['confidence'] ?? '',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('AI 정확도:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  const Text(
                    '82%',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMastitisResult(AnalysisTab selectedService) {
    final level = resultData['level'] ?? 1;
    final levelTexts = ['정상', '주의', '염증 가능성'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                '유방염 위험도 분석',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text(
                  levelTexts[level - 1],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '신뢰도: ${resultData['confidence'] ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...resultData['details'].entries.map<Widget>((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDetailItem(entry.key, entry.value.toString()),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMilkQualityResult(AnalysisTab selectedService) {
    final grade = resultData['grade'] ?? 'B';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                '우유 품질 분석',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${grade}등급',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        resultData['prediction'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('유지방', resultData['details']['유지방'] ?? ''),
                    const SizedBox(height: 8),
                    _buildDetailItem('유단백', resultData['details']['유단백'] ?? ''),
                    const SizedBox(height: 8),
                    _buildDetailItem('유당', resultData['details']['유당'] ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedEfficiencyResult(AnalysisTab selectedService) {
    final efficiency = resultData['efficiency'] ?? 'medium';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                '사료 효율 분석',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text(
                  resultData['prediction'] ?? '',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '효율성: ${efficiency == 'high' ? '높음' : efficiency == 'medium' ? '보통' : '낮음'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('사료 대비 착유량', resultData['details']['사료 대비 착유량'] ?? ''),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem('개선 여지', resultData['details']['개선 여지'] ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalvingResult(AnalysisTab selectedService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pregnant_woman, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                '분만 예측 결과',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text(
                  resultData['prediction'] ?? '',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '예상 분만일: ${resultData['details']['예상 분만일'] ?? ''}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('현재 임신일', resultData['details']['현재 임신일'] ?? ''),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem('분만 확률', resultData['details']['분만 확률'] ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreedingResult(AnalysisTab selectedService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                '수정 시점 분석',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text(
                  resultData['prediction'] ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '성공 확률: ${resultData['details']['성공 확률'] ?? ''}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('발정 강도', resultData['details']['발정 강도'] ?? ''),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem('다음 관찰', resultData['details']['다음 관찰'] ?? ''),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultResult(AnalysisTab selectedService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                '분석 결과',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Text(
                  resultData['prediction'] ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '신뢰도: ${resultData['confidence'] ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLumpySkinImageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              const Text(
                '이미지 업로드',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '소의 피부 상태를 촬영한 사진을 업로드하면\nAI가 럼피스킨병 감염 여부를 분석합니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          
          // 이미지 업로드 영역
          if (selectedImage == null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '이미지를 업로드해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '소의 피부 상태를 촬영한 사진을 업로드하면\nAI가 럼피스킨병 감염 여부를 분석합니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload),
                    label: const Text('이미지 선택'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 이미지가 있을 때
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('이미지 변경'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.grey.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              hasResult = false;
                            });
                            
                            // 더미 분석 실행
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                  hasResult = true;
                                  resultData = _generateDummyResult();
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.psychology),
                          label: const Text('분석 시작'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5722),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
} 