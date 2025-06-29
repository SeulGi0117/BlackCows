import 'package:flutter/material.dart';
import 'package:cow_management/models/cow.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CowDetailedRecordsPage extends StatefulWidget {
  final Cow cow;

  const CowDetailedRecordsPage({
    super.key,
    required this.cow,
  });

  @override
  State<CowDetailedRecordsPage> createState() => _CowDetailedRecordsPageState();
}

class _CowDetailedRecordsPageState extends State<CowDetailedRecordsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _detailedRecords = [];
  bool _isLoading = false;
  late String _baseUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    _fetchDetailedRecords();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetailedRecords() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;

      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/records/cow/${widget.cow.id}/all-records'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _detailedRecords = data['records'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('기록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error fetching detailed records: $e');
      }
    }
  }

  Future<void> _updateRecord(
      String recordId, Map<String, dynamic> updateData) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;

      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/records/$recordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        // 성공적으로 업데이트된 경우 목록 새로고침
        await _fetchDetailedRecords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기록이 성공적으로 수정되었습니다.'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        throw Exception('기록 수정에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.accessToken;

      if (token == null) {
        throw Exception('로그인이 필요합니다.');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/records/$recordId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // 성공적으로 삭제된 경우 목록 새로고침
        await _fetchDetailedRecords();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('기록이 성공적으로 삭제되었습니다.'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      } else {
        throw Exception('기록 삭제에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: ModernAppBar(
        title: '${widget.cow.name} 상세 기록',
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4CAF50),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF4CAF50),
              indicatorWeight: 3,
              tabs: const [
                Tab(icon: Icon(Icons.health_and_safety), text: '건강'),
                Tab(icon: Icon(Icons.pregnant_woman), text: '번식'),
                Tab(icon: Icon(Icons.rice_bowl), text: '사료/착유'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const ModernLoadingWidget(message: '기록을 불러오는 중...')
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHealthTab(),
                      _buildBreedingTab(),
                      _buildFeedingTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecordCard(
            title: '건강검진 기록',
            icon: Icons.health_and_safety,
            color: Colors.blue,
            emoji: '🏥',
            description: '정기 건강검진 및 체크업 기록',
            onViewPressed: () => _navigateToList('/health-check/list'),
            onAddPressed: () => _navigateToAdd('/health-check/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '백신접종 기록',
            icon: Icons.vaccines,
            color: Colors.green,
            emoji: '💉',
            description: '백신 접종 일정 및 이력 관리',
            onViewPressed: () => _navigateToList('/vaccination/list'),
            onAddPressed: () => _navigateToAdd('/vaccination/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '체중측정 기록',
            icon: Icons.monitor_weight,
            color: Colors.orange,
            emoji: '⚖️',
            description: '체중 변화 추이 및 성장 기록',
            onViewPressed: () => _navigateToList('/weight/list'),
            onAddPressed: () => _navigateToAdd('/weight/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '치료 기록',
            icon: Icons.medical_services,
            color: Colors.red,
            emoji: '🩺',
            description: '질병 치료 및 처방 기록',
            onViewPressed: () => _navigateToList('/treatment/list'),
            onAddPressed: () => _navigateToAdd('/treatment/add'),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecordCard(
            title: '발정 기록',
            icon: Icons.waves,
            color: Colors.pink,
            emoji: '💕',
            description: '발정 주기 및 행동 관찰 기록',
            onViewPressed: () => _navigateToList('/estrus-record/list'),
            onAddPressed: () => _navigateToAdd('/estrus-record/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '인공수정 기록',
            icon: Icons.medical_services_outlined,
            color: Colors.blue,
            emoji: '🎯',
            description: '인공수정 실시 및 결과 기록',
            onViewPressed: () => _navigateToList('/insemination-record/list'),
            onAddPressed: () => _navigateToAdd('/insemination-record/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '임신감정 기록',
            icon: Icons.search,
            color: Colors.purple,
            emoji: '🤱',
            description: '임신 확인 및 감정 결과',
            onViewPressed: () => _navigateToList('/pregnancy-check/list'),
            onAddPressed: () => _navigateToAdd('/pregnancy-check/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '분만 기록',
            icon: Icons.child_care,
            color: Colors.teal,
            emoji: '👶',
            description: '분만 과정 및 송아지 정보',
            onViewPressed: () => _navigateToList('/calving-record/list'),
            onAddPressed: () => _navigateToAdd('/calving-record/add'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRecordCard(
            title: '사료급여 기록',
            icon: Icons.rice_bowl,
            color: Colors.brown,
            emoji: '🌾',
            description: '사료 종류, 급여량 및 시간 기록',
            onViewPressed: () => _navigateToList('/feeding-record/list'),
            onAddPressed: () => _navigateToAdd('/feeding-record/add'),
          ),
          const SizedBox(height: 16),
          _buildRecordCard(
            title: '착유 기록',
            icon: Icons.local_drink,
            color: Colors.indigo,
            emoji: '🥛',
            description: '착유량, 유성분 및 품질 기록',
            onViewPressed: () => _navigateToList('/milking-records'),
            onAddPressed: () => _navigateToAdd('/milking-record-add'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard({
    required String title,
    required IconData icon,
    required Color color,
    required String emoji,
    required String description,
    required VoidCallback onViewPressed,
    required VoidCallback onAddPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 카드 모서리 둥글게 설정
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Container 모서리 둥글게 설정
          color: Colors.white, // 배경 색상
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8), // 아이콘 부분 둥글게 설정
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
                    onPressed: onViewPressed,
                    icon: const Icon(Icons.list, size: 18),
                    label: const Text('기록 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // 버튼 모서리 둥글게 설정
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAddPressed,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('기록 추가'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // 버튼 모서리 둥글게 설정
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

  void _navigateToList(String route) {
    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'cowId': widget.cow.id,
        'cowName': widget.cow.name,
      },
    );
  }

  void _navigateToAdd(String route) {
    Navigator.pushNamed(
      context,
      route,
      arguments: {
        'cowId': widget.cow.id,
        'cowName': widget.cow.name,
      },
    );
  }
}
