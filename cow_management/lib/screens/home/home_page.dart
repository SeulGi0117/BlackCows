import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/widgets/modern_card.dart';
import 'package:cow_management/widgets/loading_widget.dart';
import 'package:cow_management/screens/notifications/notification_list_page.dart';
import 'package:cow_management/screens/todo/todo_page.dart';
import 'package:cow_management/screens/cow_list/cow_registration_flow_page.dart';
import 'package:cow_management/screens/ai_chatbot/chatbot_history_page.dart';
import 'package:cow_management/screens/home/price_trend_detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int countByStatus(List cows, String status) {
    return cows.where((cow) => cow.status == status).length;
  }

  bool _favoritesLoaded = false;
  bool _cowsLoadedOnce = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final cowProvider = Provider.of<CowProvider>(context, listen: false);

    if (userProvider.isLoggedIn && userProvider.accessToken != null) {
      if (cowProvider.cows.isEmpty && !_cowsLoadedOnce) {
        _cowsLoadedOnce = true;

        cowProvider
            .fetchCowsFromBackend(userProvider.accessToken!,
                forceRefresh: true, userProvider: userProvider)
            .then((_) {
          if (!_favoritesLoaded &&
              userProvider.isLoggedIn &&
              userProvider.accessToken != null) {
            cowProvider.syncFavoritesFromServer(userProvider.accessToken!);
            _favoritesLoaded = true;
          }
        }).catchError((error) {
          _cowsLoadedOnce = false;
          print('홈 화면에서 소 목록 로딩 실패: $error');
        });
      } else if (!_favoritesLoaded) {
        cowProvider.syncFavoritesFromServer(userProvider.accessToken!);
        _favoritesLoaded = true;
      }
    }

    if (userProvider.shouldShowWelcome && userProvider.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeSnackBar(userProvider);
      });
    }
  }

  void _showWelcomeSnackBar(UserProvider userProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_emotions,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${userProvider.currentUser!.username}님 환영합니다!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
    userProvider.markWelcomeShown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF4CAF50),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildModernHeader(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildCowStatusOverview(),
                  const SizedBox(height: 24),
                  _buildFavoriteCows(),
                  const SizedBox(height: 24),
                  _buildRecentActivities(),
                  const SizedBox(height: 100), // Bottom padding for navigation
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        final currentHour = DateTime.now().hour;
        String greeting;

        if (currentHour < 12) {
          greeting = '좋은 아침이에요';
        } else if (currentHour < 18) {
          greeting = '좋은 오후에요';
        } else {
          greeting = '좋은 저녁이에요';
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.username ?? '농장주',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.home_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user?.farmNickname ?? '소담소담 농장',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.add_circle_outline,
        'title': '소 등록',
        'color': const Color(0xFF4CAF50),
        'onTap': () => _showCowRegistrationDialog(context),
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'AI 분석',
        'color': const Color(0xFF2196F3),
        'onTap': () => Navigator.pushNamed(context, '/analysis'),
      },
      {
        'icon': Icons.list_alt_rounded,
        'title': '소 목록',
        'color': const Color(0xFFFF9800),
        'onTap': () => Navigator.pushNamed(context, '/cows'),
      },
      {
        'icon': Icons.chat_bubble_outline,
        'title': 'AI 챗봇',
        'color': const Color(0xFF9C27B0),
        'onTap': () => Navigator.pushNamed(context, '/chatbot'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '빠른 작업',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A59),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: actions.length + 1, // +1: 할 일 전체 보기
            itemBuilder: (context, index) {
              if (index < actions.length) {
                final action = actions[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: ModernCard(
                    padding: const EdgeInsets.all(12),
                    margin: EdgeInsets.zero,
                    onTap: action['onTap'] as void Function(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (action['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action['title'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E3A59),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // 마지막 카드: 할 일 전체 보기
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: ModernCard(
                    padding: const EdgeInsets.all(12),
                    margin: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pushNamed(context, '/todo'); // 라우트 이름 확인 필요
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.view_list,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '할 일 관리',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E3A59),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _showCowRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('소 등록 방법 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sync, color: Color(0xFF4CAF50)),
              ),
              title: const Text('축산물 이력제 연동'),
              subtitle: const Text('이력제에 등록된 소를 가져옵니다'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CowRegistrationFlowPage(
                      initialMethod: CowRegistrationMethod.traceSync,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit, color: Color(0xFF2196F3)),
              ),
              title: const Text('직접 입력'),
              subtitle: const Text('소의 정보를 직접 입력합니다'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CowRegistrationFlowPage(
                      initialMethod: CowRegistrationMethod.manual,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCowStatusOverview() {
    return Consumer<CowProvider>(
      builder: (context, cowProvider, child) {
        final cows = cowProvider.cows;
        final healthyCount = countByStatus(cows, '건강');
        final treatmentCount = countByStatus(cows, '치료중');
        final pregnantCount = countByStatus(cows, '임신');
        final dryCount = countByStatus(cows, '건유');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '농장 현황',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 소 상태 요약 카드
            _buildHealthSummaryCard(cows),
            const SizedBox(height: 16),
            ModernCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '전체 소 현황',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3A59),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '총 ${cows.length}마리',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatusCard('건강', healthyCount,
                              const Color(0xFF4CAF50), Icons.favorite)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatusCard('치료중', treatmentCount,
                              const Color(0xFFFF5722), Icons.medical_services)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatusCard('임신', pregnantCount,
                              const Color(0xFF2196F3), Icons.pregnant_woman)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildStatusCard('건유', dryCount,
                              const Color(0xFFFF9800), Icons.pause_circle)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHealthSummaryCard(List<dynamic> cows) {
    // 상태별 카운트 계산
    int normalCount = 0;
    int warningCount = 0;
    int dangerCount = 0;

    for (var cow in cows) {
      String status = cow.status.toLowerCase();
      if (status.contains('건강') ||
          status.contains('정상') ||
          status.contains('양호')) {
        normalCount++;
      } else if (status.contains('주의') ||
          status.contains('경고') ||
          status.contains('건유')) {
        warningCount++;
      } else if (status.contains('위험') ||
          status.contains('치료') ||
          status.contains('이상')) {
        dangerCount++;
      } else {
        // 알 수 없는 상태는 주의로 분류
        warningCount++;
      }
    }

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                '소 상태 요약',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHealthStatusCard('정상', normalCount,
                    const Color(0xFF4CAF50), Icons.check_circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthStatusCard(
                    '주의', warningCount, const Color(0xFFFF9800), Icons.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHealthStatusCard(
                    '이상', dangerCount, const Color(0xFFE53935), Icons.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatusCard(
      String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCows() {
    return Consumer<CowProvider>(
      builder: (context, cowProvider, child) {
        final favoriteCows = cowProvider.favorites;

        if (favoriteCows.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    '즐겨찾기 소',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3A59),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/cows'),
                    child: const Text(
                      '전체보기',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: favoriteCows.length,
                itemBuilder: (context, index) {
                  final cow = favoriteCows[index];
                  return Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 12),
                    child: ModernCard(
                      padding: const EdgeInsets.all(8),
                      margin: EdgeInsets.zero,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/cows/detail',
                        arguments: cow,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cow.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3A59),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  _getStatusColor(cow.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cow.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(cow.status),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cow.earTagNumber,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '젖소 산지 가격 동향',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3A59),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const PriceTrendChartView(initialType: '초유떼기'),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3A59),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
    );
  }

  StatusType _getStatusType(String status) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case '건강':
        return const Color(0xFF2E7D32);
      case '치료중':
        return const Color(0xFFC62828);
      case '임신':
        return const Color(0xFF1565C0);
      case '건유':
        return const Color(0xFFEF6C00);
      default:
        return const Color(0xFF616161);
    }
  }

  Future<void> _refreshData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final cowProvider = Provider.of<CowProvider>(context, listen: false);

    if (userProvider.accessToken != null) {
      try {
        await cowProvider.fetchCowsFromBackend(
          userProvider.accessToken!,
          forceRefresh: true,
          userProvider: userProvider,
        );
        await cowProvider.syncFavoritesFromServer(userProvider.accessToken!);
      } catch (e) {
        print('데이터 새로고침 실패: $e');
      }
    }
  }
}
