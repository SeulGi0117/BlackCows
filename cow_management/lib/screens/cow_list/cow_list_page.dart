import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cow_management/screens/cow_list/cow_add_page.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:cow_management/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:cow_management/models/cow.dart';

class CowListPage extends StatefulWidget {
  const CowListPage({super.key});

  @override
  State<CowListPage> createState() => _CowListPageState();
}

class _CowListPageState extends State<CowListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus; // 문자열 상태 필터

  @override
  void initState() {
    super.initState();
    _fetchCowsFromBackend();
  }

  Future<void> _fetchCowsFromBackend() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final apiUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

    if (apiUrl.isEmpty) {
      print('API 주소가 없습니다');
      return;
    }

    if (!userProvider.isLoggedIn || userProvider.accessToken == null) {
      print('로그인이 필요합니다');
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
        print('API URL: $apiUrl');
        print('❌ 요청 실패: ${response.statusCode}');
        print('응답 내용: ${utf8.decode(response.bodyBytes)}');
      }
    } catch (e) {
      print('🐞 요청 중 오류 발생: $e');
    }
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
      final matchSearch = cow.name.toLowerCase().contains(searchText);
      return matchStatus && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('젖소 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 12),
            Expanded(
              child: cows.isEmpty
                  ? const Center(
                      child: Text(
                        '소가 없습니다.\n소를 추가해주세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView(
                      children: cows.map(_buildCowCard).toList(),
                    ),
            ),
          ],
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
              hintText: '이름 검색',
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CowAddPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          icon: const Icon(Icons.add),
          label: const Text('추가'),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = {
      '전체': null,
      '양호': '양호',
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
      onTap: () {
        Navigator.pushNamed(
          context,
          '/cows/detail',
          arguments: cow,
        );
        // 추후 상세 페이지 연결
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                cowProvider.toggleFavoriteByName(cow.name);
                setState(() {});
              },
            ),
            const SizedBox(width: 12),
            const Text('🐄', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cow.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                      '출생일 - ${cow.birthdate?.toIso8601String().split('T')[0] ?? '미등록'}'),
                  Text('품종 - ${cow.breed}'),
                  Text('센서 - ${cow.sensor}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    cow.status,
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 6),
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
}
