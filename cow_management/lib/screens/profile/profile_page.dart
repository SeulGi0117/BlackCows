import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/screens/accounts/login.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        backgroundColor: Colors.pink,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 프로필 카드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.pink,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? '알 수 없음',  // 사용자 이름/실명
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '아이디: ${user?.userId ?? '알 수 없음'}', // 로그인용 아이디
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '이메일 없음',  // 이메일
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (user?.farmNickname != null)  // 목장 별명
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🏡 ${user!.farmNickname}',
                              style: const TextStyle(
                                color: Colors.pink,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 계정 정보 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '계정 정보',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('이름', user?.username ?? '정보 없음'),
                  _buildInfoRow('로그인 아이디', user?.userId ?? '정보 없음'),
                  _buildInfoRow('이메일', user?.email ?? '정보 없음'),
                  _buildInfoRow('목장', user?.farmNickname ?? '정보 없음'),
                  _buildInfoRow('가입일', user?.createdAt != null 
                    ? user!.createdAt!.split('T')[0] 
                    : '정보 없음'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 기능 버튼들
            Column(
              children: [
                // 목장 이름 수정 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showEditFarmNameDialog(context, userProvider);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('목장 이름 수정'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // 로그아웃 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showLogoutConfirmDialog(context, userProvider);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('로그아웃'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // 회원 탈퇴 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showDeleteAccountDialog(context, userProvider);
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('회원 탈퇴'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // 80에서 100으로 증가
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8), // 라벨과 값 사이 간격 추가
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditFarmNameDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController farmNameController = TextEditingController();
    farmNameController.text = userProvider.currentUser?.farmNickname ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('목장 이름 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('새로운 목장 이름을 입력해주세요.'),
              const SizedBox(height: 16),
              TextField(
                controller: farmNameController,
                decoration: const InputDecoration(
                  labelText: '목장 이름',
                  hintText: '예: 행복한 목장',
                  border: OutlineInputBorder(),
                ),
                maxLength: 20,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                final newFarmName = farmNameController.text.trim();
                if (newFarmName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('목장 이름을 입력해주세요.')),
                  );
                  return;
                }
                Navigator.pop(context);
                _updateFarmName(context, userProvider, newFarmName);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('수정', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _updateFarmName(BuildContext context, UserProvider userProvider, String newFarmName) async {
    // 간단한 로딩 표시 (스낵바 사용)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('목장 이름을 "$newFarmName"으로 변경 중...'),
          ],
        ),
        duration: const Duration(seconds: 5), // 충분한 시간 설정
        backgroundColor: Colors.blue,
      ),
    );

    try {
      // 타임아웃 설정 (5초로 단축)
      final success = await userProvider.updateFarmName(newFarmName).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('목장 이름 수정 타임아웃 발생');
          return false;
        },
      );
      
      if (context.mounted) {
        // 기존 스낵바 숨기기
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('목장 이름이 "$newFarmName"으로 변경되었습니다!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('목장 이름 수정에 실패했습니다.'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('목장 이름 수정 예외 발생: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('네트워크 오류: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '회원 탈퇴',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '정말로 회원 탈퇴하시겠습니까?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• 모든 젖소 데이터가 삭제됩니다\n• 계정 복구가 불가능합니다\n• 즐겨찾기 및 기록이 모두 삭제됩니다',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text('비밀번호를 입력해주세요:'),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '현재 비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호를 입력해주세요.')),
                  );
                  return;
                }
                Navigator.pop(context);
                _deleteAccount(context, userProvider, password);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('탈퇴하기', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context, UserProvider userProvider, String password) async {
    // 간단한 로딩 표시 (스낵바 사용)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('회원 탈퇴 처리 중...'),
          ],
        ),
        duration: Duration(seconds: 10), // 충분한 시간 설정
        backgroundColor: Colors.red,
      ),
    );

    try {
      final success = await userProvider.deleteAccount(password);
      
      if (context.mounted) {
        // 기존 스낵바 숨기기
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('회원 탈퇴가 완료되었습니다.'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // 잠시 후 로그인 페이지로 이동
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('회원 탈퇴에 실패했습니다. 비밀번호를 확인해주세요.'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('오류가 발생했습니다: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showLogoutConfirmDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                userProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}