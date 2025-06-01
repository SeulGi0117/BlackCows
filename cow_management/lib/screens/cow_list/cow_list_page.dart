import 'package:flutter/material.dart';
import 'package:cow_management/screens/cow_list/cow_add_page.dart';
import 'package:cow_management/providers/cow_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class CowListPage extends StatefulWidget {
  const CowListPage({super.key});

  @override
  State<CowListPage> createState() => _CowListPageState();
}

class _CowListPageState extends State<CowListPage> {
  late List<Map<String, String>> filteredCows;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cows = Provider.of<CowProvider>(context).cows;

    filteredCows = cows
        .map((cow) => {
              'name': cow.cow_name,
              'date': cow.birthdate.toIso8601String(), // DateTime → 문자열
              'status': describeEnum(cow.status), // enum → 문자열
              'breed': cow.breed,
            })
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dangerCows = [
      {'name': '꽃분이 젖소', 'reason': '심박수 비정상'},
      {'name': '정숙 젖소', 'reason': '체온 급상승'},
    ];
    final List<Map<String, String>> fertileCows = [
      {'name': '점박이 젖소', 'reason': '배란 예측 D-1'},
      {'name': '육즙 젖소', 'reason': '배란 예측 D-2'},
    ];

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
            _buildSearchBar(context),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 12),
            Expanded(
              child: filteredCows.isEmpty
                  ? const Center(
                      child: Text(
                        '검색 결과가 없습니다.\n다시 시도해주세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView(
                      children: [
                        ...filteredCows.map(_buildCowCard),
                        const SizedBox(height: 20),
                        _buildSummarySection(
                          title: '건강상태 위험한 젖소',
                          icon: Icons.warning_amber,
                          color: Colors.red,
                          data: dangerCows,
                        ),
                        _buildSummarySection(
                          title: '번식 적기인 젖소',
                          icon: Icons.favorite,
                          color: Colors.orange,
                          data: fertileCows,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '개체번호, 이름 검색',
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
    final List<String> filters = ['양호', '위험'];

    return Wrap(
      spacing: 10,
      children: filters.map((label) {
        return FilterChip(
          label: Text(label),
          selected: false,
          onSelected: (bool selected) {},
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

  Widget _buildCowCard(Map<String, String> cow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Text('\uD83D\uDC04', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cow['name'] ?? '이름 없음',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('개체번호 - ${cow['id'] ?? '미지정'}'),
                Text(cow['sensor'] ?? ''),
                Text(cow['date'] ?? ''),
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
                  cow['status'] ?? '',
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                cow['milk'] ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, String>> data,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...data.map((cow) => Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text('• ${cow['name']} - ${cow['reason']}',
                    style: const TextStyle(fontSize: 14)),
              )),
        ],
      ),
    );
  }
}
