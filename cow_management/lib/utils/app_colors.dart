import 'package:flutter/material.dart';

// 참고: https://api.flutter.dev/flutter/material/Colors-class.html

/// 앱 전체에서 사용되는 색상 테마
class AppColors {
  // Primary Colors (메인 색상)
  static const Color primary = Color(0xFF4CAF50);      // Colors.green[500]
  static const Color primaryLight = Color(0xFF66BB6A);  // Colors.green[400]
  static const Color primaryDark = Color(0xFF2E7D32);   // Colors.green[800]
  
  // Secondary Colors (보조 색상)
  static const Color secondary = Color(0xFF9C27B0);      // Colors.purple[500]      
  static const Color secondaryLight = Color(0xFFBA68C8); // Colors.purple[300]
  static const Color secondaryDark = Color(0xFF7B1FA2);  // Colors.purple[700]
  
  // Background Colors (배경 색상)
  static const Color background = Color(0xFFF8F9FA);   // Colors.grey[50]과 비슷. 배경색으로 사용
  static const Color white = Color(0xFFFFFFFF);     // Colors.white
  
  // Text Colors (텍스트 색상)
  static const Color textPrimary = Color(0xFF2E3A59);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textLight = Color(0xFF9E9E9E);
  
  // Status Colors (상태 색상)
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFEF6C00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);
  static const Color neutral = Color(0xFF616161);
  
  // Chat Colors (챗봇 색상)
  static const Color chatUserBubble = Color(0xFFFCE4EC); // Colors.pink.shade50
  static const Color chatUserBorder = Color(0xFFF8BBD9); // Colors.pink.shade100
  static const Color chatBotBubble = Color(0xFFF5F5F5); // Colors.grey.shade100
  static const Color chatBotBorder = Color(0xFFE0E0E0); // Colors.grey.shade300
  static const Color chatUserAvatar = Color(0xFFF48FB1); // Colors.pink.shade200
  
  // Button Colors (버튼 색상)
  static const Color buttonPrimary = Color(0xFF4CAF50);
  static const Color buttonSecondary = Color(0xFF9C27B0);
  static const Color buttonSuccess = Color(0xFF2E7D32);
  static const Color buttonWarning = Color(0xFFEF6C00);
  static const Color buttonError = Color(0xFFC62828);
  
  // Border Colors (테두리 색상)
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF9E9E9E);
  
  // Shadow Colors (그림자 색상)
  static const Color shadowLight = Color(0x1A000000); // 10% opacity
  static const Color shadowMedium = Color(0x40000000); // 25% opacity
  static const Color shadowDark = Color(0x66000000); // 40% opacity
  
  // Gradient Colors (그라데이션 색상)
  static const List<Color> primaryGradient = [primary, primaryLight];
  static const List<Color> secondaryGradient = [secondary, secondaryLight];
  
  // Opacity Helpers (투명도 헬퍼)
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Status Color Helpers (상태 색상 헬퍼)
  static Color getStatusColor(String status) {
    switch (status) {
      case '건강':
        return success;
      case '치료중':
        return error;
      case '임신':
        return info;
      case '건유':
        return warning;
      default:
        return neutral;
    }
  }
  
  // Status Type Enum
  static StatusType getStatusType(String status) {
    switch (status) {
      case '건강':
        return StatusType.healthy;
      case '치료중':
        return StatusType.danger;
      case '임신':
        return StatusType.info;
      case '건유':
        return StatusType.warning;
      default:
        return StatusType.neutral;
    }
  }
}

/// 상태 타입 열거형
enum StatusType {
  healthy,
  danger,
  info,
  warning,
  neutral,
} 