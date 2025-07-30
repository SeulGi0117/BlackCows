import 'package:flutter/material.dart';

class AnalysisTab {
  final String id;
  final String label;
  final String description;
  final String icon;
  final Color color;
  final List<String> requiredFields;
  final bool isPremium;
  final String? subtitle;

  const AnalysisTab({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredFields,
    this.isPremium = false,
    this.subtitle,
  });
}

const List<AnalysisTab> analysisTabs = [
  AnalysisTab(
    id: 'milk_yield',
    label: '착유량 예측',
    description: '착유 횟수, 사료 섭취량, 환경 온도 등을 분석하여 향후 착유량을 정확히 예측합니다',
    icon: '🥛',
    color: Color(0xFF4CAF50),
    requiredFields: ['착유횟수', '전도율', '온도', '유지방비율', '유단백비율', '농후사료섭취량', '착유기측정월', '착유기측정요일'],
  ),
  AnalysisTab(
    id: 'mastitis_risk',
    label: '유방염 위험도',
    description: '체세포수 데이터 또는 다양한 생체 지표를 통해 유방염 위험도를 단계별로 예측합니다',
    icon: '⚠️',
    color: Color(0xFFFF9800),
    requiredFields: ['착유량', '전도율_유방염', '유지방비율_유방염', '유단백비율_유방염', '산차수'],
    subtitle: '체세포수 유무에 따른 2가지 분석 모드',
  ),
  AnalysisTab(
    id: 'milk_quality',
    label: '유성분 품질 예측',
    description: '개발중...',
    icon: '🔬',
    color: Color(0xFF2196F3),
    requiredFields: [],
  ),
  AnalysisTab(
    id: 'feed_efficiency',
    label: '사료 효율 분석',
    description: '사료 대비 착유량 효율을 분석하여 경제적인 사료 급여 방안을 제시합니다',
    icon: '📊',
    color: Color(0xFF9C27B0),
    requiredFields: [],
  ),
  AnalysisTab(
    id: 'calving_prediction',
    label: '분만 예측',
    description: '개발중...',
    icon: '🐄',
    color: Color(0xFF795548),
    requiredFields: [],
  ),
  AnalysisTab(
    id: 'breeding_timing',
    label: '교배 타이밍 추천',
    description: '개발중...',
    icon: '❤️',
    color: Color(0xFFE91E63),
    requiredFields: [],
  ),
  AnalysisTab(
    id: 'lumpy_skin_detection',
    label: '럼피스킨병 AI 진단',
    // description: '개발중...',
    description: '소의 피부 이미지를 업로드하여 럼피스킨병 감염 여부를 AI로 진단합니다',
    icon: '🔍',
    color: Color(0xFFFF5722),
    requiredFields: ['소 피부 이미지'],
    isPremium: true,
  ),
];