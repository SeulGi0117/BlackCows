/*
 * 해당 파일은 현재 사용하지 않습니다.
 * 추후 사용자에게 등록된 소 정보로 자동 채우기를 할 때 사용하세요.
 * 
 * 현재는 analysis_form_manual.dart만 사용하고 있습니다.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'analysis_tab_controller.dart';
import 'package:cow_management/services/ai_prediction_api.dart'; // 올바른 경로

class AnalysisFormAutofill extends StatefulWidget {
  final void Function(String? temp, String? milk, String? confidence) onPredict;
  final String selectedServiceId;
  final String? mastitisMode;

  const AnalysisFormAutofill({
    required this.onPredict, 
    required this.selectedServiceId,
    this.mastitisMode,
    super.key
  });

  @override
  State<AnalysisFormAutofill> createState() => _AnalysisFormAutofillState();
}

class _AnalysisFormAutofillState extends State<AnalysisFormAutofill> {
  final Map<String, TextEditingController> _controllers = {};

  // 필드 매핑
  final Map<String, Map<String, dynamic>> _fieldMapping = {
    // 착유량 예측 필드 (8개)
    '착유횟수': {'key': 'milkingFreq_milk', 'label': '착유횟수 (회/일)', 'hint': '2', 'icon': Icons.schedule},
    '전도율': {'key': 'conductivity_milk', 'label': '전도율 (mS/cm)', 'hint': '4.2', 'icon': Icons.electric_bolt},
    '온도': {'key': 'temperature_milk', 'label': '환경온도 (°C)', 'hint': '20', 'icon': Icons.thermostat},
    '유지방비율': {'key': 'fatRatio_milk', 'label': '유지방비율 (%)', 'hint': '3.8', 'icon': Icons.opacity},
    '유단백비율': {'key': 'proteinRatio_milk', 'label': '유단백비율 (%)', 'hint': '3.2', 'icon': Icons.science},
    '농후사료섭취량': {'key': 'feedIntake_milk', 'label': '사료섭취량 (kg)', 'hint': '25.0', 'icon': Icons.grass},
    '착유기측정월': {'key': 'milkDateMonth_milk', 'label': '착유기측정월', 'hint': '1', 'icon': Icons.calendar_today},
    '착유기측정요일': {'key': 'milkDateDay_milk', 'label': '착유기측정요일', 'hint': '수', 'icon': Icons.calendar_today},
    
    // 유방염 위험도 예측 필드
    '체세포수': {'key': 'somatic_cell_count', 'label': '체세포수 (cells/mL)', 'hint': '200000', 'icon': Icons.biotech},
    '착유량': {'key': 'milkVolume_mastitis', 'label': '착유량 (L)', 'hint': '18.5', 'icon': Icons.water_drop},
    '전도율_유방염': {'key': 'conductivity_mastitis', 'label': '전도율 (mS/cm)', 'hint': '4.2', 'icon': Icons.electric_bolt},
    '유지방비율_유방염': {'key': 'fatRatio_mastitis', 'label': '유지방비율 (%)', 'hint': '3.8', 'icon': Icons.opacity},
    '유단백비율_유방염': {'key': 'proteinRatio_mastitis', 'label': '유단백비율 (%)', 'hint': '3.2', 'icon': Icons.science},
    '산차수': {'key': 'parity_mastitis', 'label': '산차수', 'hint': '2', 'icon': Icons.child_care},
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(AnalysisFormAutofill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedServiceId != widget.selectedServiceId || 
        oldWidget.mastitisMode != widget.mastitisMode) {
      _controllers.clear();
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    final selectedService = analysisTabs.firstWhere((s) => s.id == widget.selectedServiceId);
    
    // 유방염 서비스인 경우 모드에 따라 필드 변경
    List<String> fields = selectedService.requiredFields;
    if (widget.selectedServiceId == 'mastitis_risk') {
      if (widget.mastitisMode == 'with_scc') {
        fields = ['체세포수'];
              } else {
          fields = ['착유량', '전도율_유방염', '유지방비율_유방염', '유단백비율_유방염', '산차수'];
        }
    }
    
    for (final field in fields) {
      final fieldInfo = _fieldMapping[field];
      if (fieldInfo != null) {
        _controllers[fieldInfo['key']] = TextEditingController();
      }
    }
  }



  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 데이터 입력 섹션
        _buildDataInputSection(),
        const SizedBox(height: 24),

        // 분석 버튼
        _buildAnalysisButton(),
      ],
    );
  }



  Widget _buildDataInputSection() {
    final selectedService = analysisTabs.firstWhere((s) => s.id == widget.selectedServiceId);
    
    // 유방염 서비스인 경우 모드에 따라 필드 변경
    List<String> fields = selectedService.requiredFields;
    if (widget.selectedServiceId == 'mastitis_risk') {
      if (widget.mastitisMode == 'with_scc') {
        fields = ['체세포수'];
      } else {
        fields = ['착유량', '전도율_유방염', '유지방비율_유방염', '유단백비율_유방염', '산차수'];
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, color: Colors.grey.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              "필수 입력 데이터",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "${selectedService.label}에 필요한 데이터를 입력하세요",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        if (widget.selectedServiceId == 'mastitis_risk') ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.mastitisMode == 'with_scc' 
                        ? '체세포수 데이터를 기반으로 염증 가능성을 3단계로 분석합니다.'
                        : '다양한 생체 지표를 기반으로 염증 가능성을 3단계로 분석합니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        
        // 동적으로 필드 생성
        ...List.generate((fields.length / 2).ceil(), (index) {
          final startIndex = index * 2;
          final endIndex = (startIndex + 1 < fields.length) ? startIndex + 1 : startIndex;
          
          if (startIndex == endIndex) {
            // 마지막 필드가 홀수개일 때
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildInputFieldFromName(fields[startIndex]),
            );
          } else {
            // 두 개씩 나란히
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(child: _buildInputFieldFromName(fields[startIndex])),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInputFieldFromName(fields[endIndex])),
                ],
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildInputFieldFromName(String fieldName) {
    final fieldInfo = _fieldMapping[fieldName];
    if (fieldInfo == null) {
      return Container(); // 매핑되지 않은 필드는 빈 컨테이너
    }
    
    final controller = _controllers[fieldInfo['key']];
    if (controller == null) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: fieldInfo['key'] == 'diseaseHistory' || 
                     fieldInfo['key'] == 'breedingMethod' ||
                     fieldInfo['key'] == 'mastitisHistory' ||
                     fieldInfo['key'] == 'activity'
            ? TextInputType.text
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: fieldInfo['key'] == 'diseaseHistory' || 
                        fieldInfo['key'] == 'breedingMethod' ||
                        fieldInfo['key'] == 'mastitisHistory' ||
                        fieldInfo['key'] == 'activity'
            ? null
            : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        decoration: InputDecoration(
          labelText: fieldInfo['label'],
          hintText: fieldInfo['hint'],
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(fieldInfo['icon'], size: 16, color: Colors.grey.shade600),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAnalysisButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (widget.selectedServiceId == 'milk_yield') {
            // 착유량 예측 입력값 추출
            final milking_frequency = int.tryParse(_controllers['milkingFreq_milk']?.text ?? '') ?? 0;
            final conductivity = double.tryParse(_controllers['conductivity_milk']?.text ?? '') ?? 0.0;
            final temperature = double.tryParse(_controllers['temperature_milk']?.text ?? '') ?? 0.0;
            final fat_percentage = double.tryParse(_controllers['fatRatio_milk']?.text ?? '') ?? 0.0;
            final protein_percentage = double.tryParse(_controllers['proteinRatio_milk']?.text ?? '') ?? 0.0;
            final concentrate_intake = double.tryParse(_controllers['feedIntake_milk']?.text ?? '') ?? 0.0;
            final milking_month = int.tryParse(_controllers['milkDateMonth_milk']?.text ?? '') ?? 0;
            final milking_day_of_week = _convertDayToInt(_controllers['milkDateDay_milk']?.text ?? '');

            // 단일 예측 API 호출
            final result = await milkYieldPrediction(
              milking_frequency: milking_frequency,
              conductivity: conductivity,
              temperature: temperature,
              fat_percentage: fat_percentage,
              protein_percentage: protein_percentage,
              concentrate_intake: concentrate_intake,
              milking_month: milking_month,
              milking_day_of_week: milking_day_of_week,
            );

            if (result.isSuccess) {
              // 성공 시 결과를 analysis_page.dart로 전달 (예측값, 신뢰도)
              widget.onPredict(
                result.predictedYield?.toStringAsFixed(2) ?? '',
                result.confidence?.toStringAsFixed(1) ?? '',
                null, // 모델 버전 (착유량 예측에서는 사용하지 않음)
              );
            } else {
              // 실패 시 에러 메시지 표시
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            result.errorMessage ?? '알 수 없는 오류가 발생했습니다.',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: '확인',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            }
          } else if (widget.selectedServiceId == 'mastitis_risk') {
            // 유방염 예측
            if (widget.mastitisMode == 'with_scc') {
              // 체세포수 기반 유방염 예측
              final somatic_cell_count = int.tryParse(_controllers['somatic_cell_count']?.text ?? '') ?? 0;
              
              final result = await sccMastitisPrediction(
                somatic_cell_count: somatic_cell_count,
              );

              if (result.isSuccess) {
                // 성공 시 결과를 analysis_page.dart로 전달
                final predictionLabel = result.predictionClassLabel ?? '알 수 없음';
                final confidence = result.confidence ?? 0.0;
                widget.onPredict(
                  predictionLabel,
                  confidence.toStringAsFixed(1),
                  '', // modelVersion 제거됨
                );
              } else {
                // 실패 시 에러 메시지 표시
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.errorMessage ?? '알 수 없는 오류가 발생했습니다.',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: '확인',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              }
                          } else {
                // 유방염 예측
                final milk_yield = double.tryParse(_controllers['milkVolume_mastitis']?.text ?? '') ?? 0.0;
                final conductivity = double.tryParse(_controllers['conductivity_mastitis']?.text ?? '') ?? 0.0;
                final fat_percentage = double.tryParse(_controllers['fatRatio_mastitis']?.text ?? '') ?? 0.0;
                final protein_percentage = double.tryParse(_controllers['proteinRatio_mastitis']?.text ?? '') ?? 0.0;
                final lactation_number = int.tryParse(_controllers['parity_mastitis']?.text ?? '') ?? 0;
                
                              final result = await mastitisPrediction(
                milk_yield: milk_yield,
                conductivity: conductivity,
                fat_percentage: fat_percentage,
                protein_percentage: protein_percentage,
                lactation_number: lactation_number,
              );

              if (result.isSuccess) {
                // 성공 시 결과를 analysis_page.dart로 전달
                final predictionLabel = result.predictionClassLabel ?? '알 수 없음';
                final confidence = result.confidence ?? 0.0;
                widget.onPredict(
                  predictionLabel,
                  confidence.toStringAsFixed(1),
                  '', // modelVersion 제거됨
                );
              } else {
                // 실패 시 에러 메시지 표시
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.errorMessage ?? '알 수 없는 오류가 발생했습니다.',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: '확인',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              }
            }
          } else {
            // 기존 방식 유지 (다른 서비스)
            final firstValue = _controllers.values.isNotEmpty ? _controllers.values.first.text : '';
            final secondValue = _controllers.values.length > 1 ? _controllers.values.elementAt(1).text : '';
            widget.onPredict(firstValue, secondValue, null);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 20),
            const SizedBox(width: 8),
            const Text(
              'AI 분석 시작',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 요일 한글 → 숫자 변환 함수 수정 (월요일=0부터 시작)
  int _convertDayToInt(String day) {
    switch (day) {
      case '월': return 0;
      case '화': return 1;
      case '수': return 2;
      case '목': return 3;
      case '금': return 4;
      case '토': return 5;
      case '일': return 6;
      default: return 0; // 기본값으로 0 반환
    }
  }
}