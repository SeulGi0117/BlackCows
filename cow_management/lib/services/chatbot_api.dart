import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cow_management/services/dio_client.dart';

// DioClient 사용하도록 변경
final Dio _dio = DioClient().dio;

// 채팅방 생성
Future<String?> createChatRoom(String userId) async {
  try {
    print('🔥 채팅방 생성 시도: userId=$userId');
    final response = await _dio.post('/chatbot/rooms', data: {
      'user_id': userId,
    });
    print('🔥 채팅방 생성 응답: ${response.data}');
    return response.data['chats'][0]['chat_id'];
  } catch (e) {
    print('❌ 채팅방 생성 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return null;
  }
}

// 질문 전송
Future<String?> sendChatbotMessage({
  required String userId,
  required String chatId,
  required String question,
}) async {
  try {
    final response = await _dio.post('/chatbot/ask', data: {
      'user_id': userId,
      'chat_id': chatId,
      'question': question,
    });
    return response.data['answer'];
  } catch (e) {
    print('❌ 챗봇 질문 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return "답변을 불러올 수 없습니다.";
  }
}

// 더미 채팅방 목록
final List<Map<String, dynamic>> dummyChatRooms = [
  {
    'chat_id': '1',
    'name': '행복소 발정징후',
    'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
  },
  {
    'chat_id': '2',
    'name': '착유량 늘리는 방법',
    'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  },
  {
    'chat_id': '3',
    'name': '유방염 의심증상',
    'created_at': DateTime.now().toIso8601String(),
  },
];

// 더미 채팅 기록
final Map<String, List<Map<String, dynamic>>> dummyChatHistory = {
  '1': [
    {
      'role': 'user',
      'content': '행복소가 요즘 자꾸 울고 주변을 계속 돌던데, 발정일까요?',
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 2)).toIso8601String(),
    },
    {
      'role': 'assistant',
      'content': '네, 울음이 많아지고 주변을 맴도는 행동은 발정 초기 징후일 수 있습니다.\n다른 소의 등에 올라타려 하거나 꼬리를 자주 드는 모습이 보이면 가능성이 더 높습니다.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 2)).add(const Duration(minutes: 3)).toIso8601String(),
    },
    {
      'role': 'user',
      'content': '활동량이나 체온도 같이 보면 더 정확할까요?',
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 1)).toIso8601String(),
    },
    {
      'role': 'assistant',
      'content': "맞습니다. 발정 시에는 보통 체온이 0.5도 정도 오르거나 활동량이 증가하는 경우가 많습니다.\n목걸이 센서나 걸음 수 측정 장비가 있다면 함께 확인해 보셔도 좋겠습니다.\n혹시 참고용으로 '교배 타이밍 추천' 서비스를 사용해보셔도 도움이 될 수 있습니다.",
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 1)).add(const Duration(minutes: 3)).toIso8601String(),
    },
  ],
  '2': [
    {
      'role': 'user',
      'content': '요즘 착유량이 점점 줄고 있어요. 특별히 바뀐 건 없는데 왜 그럴까요?',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
    },
    {
      'role': 'assistant',
      'content': '착유량이 줄어드는 원인은 다양합니다.\n사료 섭취량이 부족하거나 수분 섭취가 원활하지 않은 경우,\n또는 스트레스(소음, 환경 변화 등)나 착유 시간 불규칙도 영향을 줄 수 있습니다.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)).add(const Duration(minutes: 3)).toIso8601String(),
    },
    {
      'role': 'user',
      'content': '사료는 잘 먹는 것 같아요. 스트레스 때문일까요?',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
    },
    {
      'role': 'assistant',
      'content': "환경적인 요인도 무시할 수 없습니다.\n소가 편안함을 느낄 수 있는 조용하고 일정한 환경이 중요합니다.\n필요하시면 '착유량 예측'이나 '사료 효율 분석' 같은 AI 분석도 참고용으로 확인해보실 수 있습니다.",
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 2)).add(const Duration(minutes: 3)).toIso8601String(),
    },
  ],
  '3': [
    {
      'role': 'user',
      'content': '오늘 착유한 우유에 덩어리 같은 게 보였는데, 유방염일 수도 있나요?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
    },
    {
      'role': 'assistant',
      'content': '네, 우유에서 덩어리가 보이거나 착유 중 소가 통증 반응을 보인다면 유방염을 의심해볼 수 있습니다.\n특히 핏기가 돌거나 우유 색이 탁해지는 경우에는 더 주의가 필요합니다.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)).add(const Duration(minutes: 3)).toIso8601String(),
    },
    {
      'role': 'user',
      'content': '지켜보다가 자연스럽게 나아질 수도 있나요?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
    },
    {
      'role': 'assistant',
      'content': "경미한 경우는 호전되기도 하지만, 유방염은 조기 치료가 중요합니다.\n가급적이면 수의사 선생님의 진료를 받으시는 걸 권장드립니다.\n혹시 도움이 필요하시면 '유방염 위험도 예측' 서비스를 참고하셔도 좋습니다.",
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)).add(const Duration(minutes: 3)).toIso8601String(),
    },
  ],
};

// 채팅방 목록 조회 (더미 데이터 우선)
Future<List<Map<String, dynamic>>> getChatRoomList(String userId) async {
  // 실제 서버 연동 전에는 더미 데이터 반환
  return dummyChatRooms;
}

// 채팅 기록 불러오기 (더미 데이터 우선)
Future<List<Map<String, dynamic>>> getChatHistory(String chatId) async {
  // 실제 서버 연동 전에는 더미 데이터 반환
  return dummyChatHistory[chatId] ?? [];
}

// 채팅방 삭제
Future<bool> deleteChatRoom(String chatId) async {
  try {
    await _dio.delete('/chatbot/rooms/$chatId');
    return true;
  } catch (e) {
    print('❌ 채팅방 삭제 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return false;
  }
}

// 채팅방 이름 변경
Future<bool> updateChatRoomName(String chatId, String name) async {
  try {
    print('🔥 채팅방 이름 변경 시도: chatId=$chatId, name=$name');
    final response = await _dio.put('/chatbot/rooms/$chatId/name', data: {
      'name': name,
    });
    print('🔥 채팅방 이름 변경 응답: ${response.data}');
    return true;
  } catch (e) {
    print('❌ 채팅방 이름 변경 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return false;
  }
}