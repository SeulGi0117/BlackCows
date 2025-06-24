import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cow_management/screens/cow_list/cow_registration_flow_page.dart';
import 'package:cow_management/screens/cow_list/cow_add_page.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cow_management/models/cow.dart';
import 'package:logging/logging.dart';

class CowListPage extends StatefulWidget {
  const CowListPage({super.key});

  @override
  State<CowListPage> createState() => _CowListPageState();
}

class _CowListPageState extends State<CowListPage> {
  final _logger = Logger('CowListPage');
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCowsFromBackend();
  }

  Future<void> _fetchCowsFromBackend() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    if (apiUrl.isEmpty) {
      _logger.warning('API 주소가 없습니다');
      setState(() => _isLoading = false);
      return;
    }

    if (!userProvider.isLoggedIn || userProvider.accessToken == null) {
      _logger.warning('로그인이 필요합니다');
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiUrl/cows/?sortDirection=DESCENDING'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userProvider.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(decoded);
        final List<Cow> cows =
            jsonList.map((json) => Cow.fromJson(json)).toList();

        if (mounted) {
          final cowProvider = Provider.of<CowProvider>(context, listen: false);
          cowProvider.setCows(cows);
        }
      } else {
        _logger.severe('API 요청 실패: ${response.statusCode}');
        _logger.severe('API URL: $apiUrl');
        _logger.severe('응답 내용: ${utf8.decode(response.bodyBytes)}');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('젖소 목록을 불러오는데 실패했습니다: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      _logger.severe('요청 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네트워크 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshCowList() async {
    await _fetchCowsFromBackend();
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
          padding: const EdgeInsets.all(20),
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
                '젖소 등록 방법 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // 신버전 (축산물이력제 연동)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.verified, color: Colors.blue.shade700),
                ),
                title: const Text(
                  '젖소 추가 (신버전)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  '축산물이력제 연동으로 간편하게 등록\n이표번호만 입력하면 자동으로 정보 조회',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '추천',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CowRegistrationFlowPage(),
                    ),
                  ).then((_) => _refreshCowList());
                },
              ),
              
              const Divider(),
              
              // 구버전 (수동 입력)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, color: Colors.grey.shade700),
                ),
                title: const Text(
                  '젖소 추가 (구버전)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  '모든 정보를 직접 입력하여 등록\n축산물이력제 정보가 없는 경우 사용',
                  style: TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CowAddPage(),
                    ),
                  ).then((_) => _refreshCowList());
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cowProvider = Provider.of<CowProvider>(context);
    final searchText = _searchController.text.toLowerCase();

    final cows = cowProvider.cows.where((cow) {
      final matchStatus =
          _selectedStatus == null || cow.status == _selectedStatus;
      final matchSearch = cow.name.toLowerCase().contains(searchText) ||
          cow.earTagNumber.toLowerCase().contains(searchText);
      return matchStatus && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('젖소 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshCowList,
            tooltip: '새로고침',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCowOptions(context),
            tooltip: '젖소 등록',
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: _refreshCowList,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildFilterChips(),
              const SizedBox(height: 12),
              if (_isLoading && cows.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('젖소 목록을 불러오는 중...'),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: cows.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.pets,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '등록된 젖소가 없습니다.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '새로운 젖소를 등록해보세요!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => _showAddCowOptions(context),
                                icon: const Icon(Icons.add),
                                label: const Text('젖소 등록하기'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pink,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: cows.length,
                          itemBuilder: (context, index) => _buildCowCard(cows[index]),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '이름 또는 이표번호 검색',
              prefixIcon: const Icon(Icons.search),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => _showAddCowOptions(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.add),
          label: const Text('등록'),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = {
      '전체': null,
      '정상': '정상',
      '경고': '경고',
      '위험': '위험',
    };

    return Wrap(
      spacing: 10,
      children: filters.entries.map((entry) {
        final label = entry.key;
        final status = entry.value;
        final selected = _selectedStatus == status;

        return FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (bool value) {
            setState(() {
              _selectedStatus = value ? status : null;
            });
          },
          selectedColor: Colors.pink.shade100,
          checkmarkColor: Colors.pink,
          backgroundColor: Colors.grey.shade200,
          shape: StadiumBorder(
            side: BorderSide(color: Colors.pink.shade200),
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        );
      }).toList(),
    );
  }

  Widget _buildCowCard(Cow cow) {
    final cowProvider = Provider.of<CowProvider>(context, listen: false);
    final isFavorite = cowProvider.isFavoriteByName(cow.name);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
          context,
          '/cows/detail',
          arguments: cow,
        );
        if (result == true) {
          // 삭제되었을 경우 목록 다시 불러오기
          _refreshCowList();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () async {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final cowProvider =
                    Provider.of<CowProvider>(context, listen: false);

                if (userProvider.accessToken == null) return;

                try {
                  await cowProvider.toggleFavoriteByName(
                      cow.name, userProvider.accessToken!);
                  setState(() {});
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('즐겨찾기 실패: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🐄', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (cow.registeredFromLivestockTrace == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '축산물이력제',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('이표번호: ${cow.earTagNumber}'),
                  Text('출생일: ${cow.birthdate?.toIso8601String().split('T')[0] ?? '미등록'}'),
                  Text('품종: ${cow.breed ?? '미등록'}'),
                  if (cow.sensor.isNotEmpty) Text('센서: ${cow.sensor}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _getStatusColor(cow.status),
                  ),
                  child: Text(
                    cow.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (cow.milk.isNotEmpty)
                  Text(
                    cow.milk,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '양호':
        return Colors.green;
      case '보통':
        return Colors.orange;
      case '병환':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}