import 'package:flutter/material.dart';
import 'package:cow_management/screens/cow_list/cow_registration_flow_page.dart';
import 'package:cow_management/screens/cow_list/cow_add_page.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:cow_management/widgets/modern_card.dart';
import 'package:cow_management/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:cow_management/models/cow.dart';
import 'package:logging/logging.dart';
import 'package:cow_management/utils/error_utils.dart';

class CowListPage extends StatefulWidget {
  const CowListPage({super.key});

  @override
  State<CowListPage> createState() => _CowListPageState();
}

class _CowListPageState extends State<CowListPage>
    with TickerProviderStateMixin {
  final _logger = Logger('CowListPage');
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  bool _isLoading = false;
  bool _cowsLoadedOnce = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _statusFilters = ['전체', '정상', '주의', '이상'];

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

    final cowProvider = Provider.of<CowProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!_cowsLoadedOnce &&
        cowProvider.cows.isEmpty &&
        userProvider.isLoggedIn &&
        userProvider.accessToken != null) {
      _cowsLoadedOnce = true;
      cowProvider
          .fetchCowsFromBackend(userProvider.accessToken!,
              forceRefresh: true, userProvider: userProvider)
          .catchError((error) {
        _cowsLoadedOnce = false;
        print('소 목록 페이지에서 초기 로딩 실패: $error');
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: ModernAppBar(
        title: '내 소 목록',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  _refreshCowList();
                  break;
                case 'sort':
                  _showSortBottomSheet();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Color(0xFF4CAF50)),
                    SizedBox(width: 8),
                    Text('새로고침'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: Row(
                  children: [
                    Icon(Icons.sort, color: Color(0xFF4CAF50)),
                    SizedBox(width: 8),
                    Text('정렬'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildHeader(),
            _buildStatusFilter(),
            Expanded(child: _buildCowList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCowOptions(context),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('소 등록'),
        elevation: 4,
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<CowProvider>(
      builder: (context, cowProvider, child) {
        final filteredCows = _getFilteredCows(cowProvider.cows);

        return ModernCard(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '총 ${cowProvider.cows.length}마리',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A59),
                          ),
                        ),
                        Text(
                          '현재 ${filteredCows.length}마리 표시 중',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Color(0xFF4CAF50),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${cowProvider.favorites.length}',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final status = _statusFilters[index];
          final isSelected = _selectedStatus == status ||
              (_selectedStatus == null && status == '전체');

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = status == '전체' ? null : status;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF4CAF50).withOpacity(0.1),
              checkmarkColor: const Color(0xFF4CAF50),
              labelStyle: TextStyle(
                color:
                    isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCowList() {
    return Consumer<CowProvider>(
      builder: (context, cowProvider, child) {
        if (_isLoading && cowProvider.cows.isEmpty) {
          return const ModernLoadingWidget(message: '소 목록을 불러오는 중...');
        }

        final filteredCows = _getFilteredCows(cowProvider.cows);

        if (filteredCows.isEmpty) {
          return ModernEmptyWidget(
            title: cowProvider.cows.isEmpty ? '등록된 소가 없습니다' : '해당 조건의 소가 없습니다',
            description:
                cowProvider.cows.isEmpty ? '첫 번째 소를 등록해보세요!' : '다른 조건으로 검색해보세요',
            icon: Icons.pets,
            action: cowProvider.cows.isEmpty
                ? ModernButton(
                    text: '소 등록하기',
                    onPressed: () => _showAddCowOptions(context),
                    icon: const Icon(Icons.add, size: 20),
                  )
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshCowList,
          color: const Color(0xFF4CAF50),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredCows.length,
            itemBuilder: (context, index) {
              final cow = filteredCows[index];
              return _buildCowCard(cow);
            },
          ),
        );
      },
    );
  }

  Widget _buildCowCard(Cow cow) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: () => Navigator.pushNamed(
        context,
        '/cows/detail',
        arguments: cow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(cow.status),
                      _getStatusColor(cow.status).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            cow.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3A59),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Consumer<CowProvider>(
                          builder: (context, cowProvider, child) {
                            return IconButton(
                              icon: Icon(
                                cow.isFavorite ? Icons.star : Icons.star_border,
                                color: cow.isFavorite
                                    ? Colors.amber
                                    : Colors.grey.shade400,
                                size: 24,
                              ),
                              onPressed: () => _toggleFavorite(cow),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '품종: ${cow.breed}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.event,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getAgeString(cow.birthdate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(cow.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(cow.status).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getStatusIcon(cow.status),
                        color: _getStatusColor(cow.status),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cow.status,
                        style: TextStyle(
                          color: _getStatusColor(cow.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tag,
                      size: 16,
                      color: Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cow.earTagNumber,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Cow> _getFilteredCows(List<Cow> cows) {
    List<Cow> filtered = cows;

    // 상태 필터
    if (_selectedStatus != null) {
      filtered =
          filtered.where((cow) => cow.status == _selectedStatus).toList();
    }

    // 검색 필터
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((cow) =>
              cow.name.toLowerCase().contains(query) ||
              (cow.breed?.toLowerCase() ?? '').contains(query) ||
              cow.earTagNumber.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  Color _getStatusColor(String healthStatus) {
    switch (healthStatus) {
      case '양호':
        return const Color(0xFF4CAF50); // 초록
      case '경고':
        return const Color.fromARGB(255, 255, 137, 2); //주황
      case '위험':
        return const Color(0xFFE53935); // 빨강

      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case '건강':
        return Icons.favorite;
      case '치료중':
        return Icons.medical_services;
      case '임신':
        return Icons.pregnant_woman;
      case '건유':
        return Icons.pause_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getAgeString(DateTime? birthDate) {
    if (birthDate == null) {
      return '생년월일 정보 없음';
    }

    try {
      return '${birthDate.year}년 ${birthDate.month.toString().padLeft(2, '0')}월 ${birthDate.day.toString().padLeft(2, '0')}일생';
    } catch (e) {
      return '생년월일 정보 오류';
    }
  }

  Future<void> _toggleFavorite(Cow cow) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final cowProvider = Provider.of<CowProvider>(context, listen: false);

    if (userProvider.accessToken == null) {
      _showErrorSnackBar('로그인이 필요합니다.');
      return;
    }

    try {
      await cowProvider.toggleFavorite(cow, userProvider.accessToken!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                cow.isFavorite ? Icons.star : Icons.star_border,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                cow.isFavorite
                    ? '${cow.name}을(를) 즐겨찾기에 추가했습니다'
                    : '${cow.name}을(를) 즐겨찾기에서 제거했습니다',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('즐겨찾기 변경에 실패했습니다: $e');
    }
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '소 검색',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 20),
            ModernTextField(
              hint: '소 이름, 품종, 이표번호로 검색',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: '초기화',
                    type: ButtonType.secondary,
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernButton(
                    text: '검색',
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '상태별 필터',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['전체', '건강', '치료중', '임신', '건유'].map((status) {
                final isSelected = _selectedStatus == status ||
                    (_selectedStatus == null && status == '전체');
                return FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = status == '전체' ? null : status;
                    });
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF4CAF50).withOpacity(0.1),
                  checkmarkColor: const Color(0xFF4CAF50),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade300,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '정렬 방식',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3A59),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.sort_by_alpha, color: Color(0xFF4CAF50)),
              title: const Text('이름순'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: Color(0xFF4CAF50)),
              title: const Text('등록일순'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.health_and_safety, color: Color(0xFF4CAF50)),
              title: const Text('상태별'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCowOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '소 등록 방법 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
              ),
              const SizedBox(height: 24),
              ModernCard(
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CowRegistrationFlowPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified,
                        color: Color(0xFF2196F3),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '축산물이력제 연동',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3A59),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '추천',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '이표번호만 입력하면 자동으로 정보 조회',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ModernCard(
                padding: const EdgeInsets.all(16),
                margin: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CowAddPage(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFFFF9800),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '직접 입력',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3A59),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '모든 정보를 직접 입력해서 등록',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF4CAF50),
                      size: 16,
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _refreshCowList() async {
    setState(() => _isLoading = true);

    try {
      await _fetchCowsFromBackend();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchCowsFromBackend() async {
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
        _showErrorSnackBar('소 목록을 불러오는데 실패했습니다: $e');
      }
    }
  }
}
