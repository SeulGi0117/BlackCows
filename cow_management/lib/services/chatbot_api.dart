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
    
    // API 문서에 따른 응답 구조: chats: [{chat_id, created_at}]
    if (response.data['chats'] != null && response.data['chats'].isNotEmpty) {
      return response.data['chats'][0]['chat_id'];
    }
    return null;
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
      
      // 서버 에러 상세 분석
      if (e.response?.statusCode == 500) {
        final errorDetail = e.response?.data?['detail']?.toString() ?? '';
        if (errorDetail.contains('protobuf') || errorDetail.contains('Descriptors')) {
          return "서버에서 일시적인 문제가 발생했습니다.\n잠시 후 다시 시도해주세요.";
        }
        return "서버 오류가 발생했습니다.\n관리자에게 문의해주세요.";
      }
    }
    return "네트워크 연결을 확인해주세요.";
  }
}

// 사용자 채팅방 목록 조회
Future<List<Map<String, dynamic>>> getChatRoomList(String userId) async {
  try {
    final response = await _dio.get('/chatbot/rooms/$userId');
    
    if (response.data['chats'] != null) {
      return List<Map<String, dynamic>>.from(response.data['chats']); //chats: List[ChatRoom] - chat_id, name, created_at
    }
    return [];
  } catch (e) {
    print('❌ 채팅방 목록 조회 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return [];
  }
}

// 채팅방 대화 이력 조회
Future<List<Map<String, dynamic>>> getChatHistory(String chatId) async {
  try {
    final response = await _dio.get('/chatbot/history/$chatId');
    
    // API 문서에 따른 응답 구조: chat_id, messages: [{role, content, timestamp}]
    if (response.data['messages'] != null) {
      return List<Map<String, dynamic>>.from(response.data['messages']);
    }
    return [];
  } catch (e) {
    print('❌ 채팅 기록 조회 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return [];
  }
}

// 채팅방 삭제
Future<bool> deleteChatRoom(String chatId) async {
  try {
    print('🔥 채팅방 삭제: chatId=$chatId');
    final response = await _dio.delete('/chatbot/rooms/$chatId');
    print('🔥 채팅방 삭제 응답: ${response.data}');
    return true;
  } catch (e) {
    print('❌ 채팅방 삭제 실패: $e');
    if (e is DioException) {
      print('❌ Dio 에러 상세: ${e.response?.data}');
    }
    return false;
  }
}

// 14일 이상된 채팅방 자동 삭제
Future<bool> deleteExpiredChatRooms() async {
  try {
    print('🔥 만료된 채팅방 자동 삭제 시도');
    final response = await _dio.delete('/chatbot/rooms/expired/auto');
    print('🔥 만료된 채팅방 삭제 응답: ${response.data}');
    return true;
  } catch (e) {
    print('❌ 만료된 채팅방 삭제 실패: $e');
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