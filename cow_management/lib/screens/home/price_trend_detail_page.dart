import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// 🎨 색상 팔레트
class PriceTrendColors {
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color buttonInactive = Color(0xFFF3F4F6);
  static const Color redLine = Color(0xFFEF4444);
  static const Color blueLine = Color(0xFF3B82F6);
}

/// 젖소 산지 가격동향 메인 페이지
class PriceTrendDetailPage extends StatefulWidget {
  final String? initialCategory;
  
  const PriceTrendDetailPage({
    super.key,
    this.initialCategory,
  });

  @override
  State<PriceTrendDetailPage> createState() => _PriceTrendDetailPageState();
}

class _PriceTrendDetailPageState extends State<PriceTrendDetailPage> {
  int selectedCategoryIndex = 0;
  
  // 카테고리 목록
  final List<String> categories = [
    '초유떼기',
    '분유떼기', 
    '수정단계',
    '초임만삭',
    '초산우',
    '다산우(4산)',
    '노폐우'
  ];
  
     // 📊 실제 데이터 (출처: 농협 축산정보센터)
   final List<Map<String, dynamic>> sampleData = [
     {
       'month': '1월',
       '초유떼기암': 24,
       '초유떼기수': 65,
       '분유떼기암': 194,
       '분유떼기수': 440,
       '수정단계': 1339,
       '초임만삭': 3505,
       '초산우': 3560,
       '다산우(4산)': 2749,
       '노폐우': 1113
     },
     {
       'month': '2월',
       '초유떼기암': 22,
       '초유떼기수': 72,
       '분유떼기암': 185,
       '분유떼기수': 477,
       '수정단계': 1366,
       '초임만삭': 3520,
       '초산우': 3613,
       '다산우(4산)': 2811,
       '노폐우': 1069
     },
     {
       'month': '3월',
       '초유떼기암': 24,
       '초유떼기수': 74,
       '분유떼기암': 183,
       '분유떼기수': 479,
       '수정단계': 1330,
       '초임만삭': 3460,
       '초산우': 3539,
       '다산우(4산)': 2811,
       '노폐우': 1042
     },
     {
       'month': '4월',
       '초유떼기암': 27,
       '초유떼기수': 92,
       '분유떼기암': 184,
       '분유떼기수': 482,
       '수정단계': 1378,
       '초임만삭': 3495,
       '초산우': 3600,
       '다산우(4산)': 2795,
       '노폐우': 1283
     },
     {
       'month': '5월',
       '초유떼기암': 30,
       '초유떼기수': 108,
       '분유떼기암': 192,
       '분유떼기수': 498,
       '수정단계': 1364,
       '초임만삭': 3441,
       '초산우': 3555,
       '다산우(4산)': 2743,
       '노폐우': 1071
     },
     {
       'month': '6월',
       '초유떼기암': 30,
       '초유떼기수': 114,
       '분유떼기암': 199,
       '분유떼기수': 509,
       '수정단계': 1358,
       '초임만삭': 3423,
       '초산우': 3543,
       '다산우(4산)': 2716,
       '노폐우': 1093
     },
   ];

  @override
  void initState() {
    super.initState();
    // 초기 카테고리 설정
    if (widget.initialCategory != null) {
      final index = categories.indexOf(widget.initialCategory!);
      if (index != -1) {
        selectedCategoryIndex = index;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PriceTrendColors.backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategorySelector(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildChartSection(),
                    _buildPriceTableSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 헤더 섹션
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: PriceTrendColors.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PriceTrendColors.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: PriceTrendColors.textPrimary,
          ),
          const SizedBox(width: 8),
          const Text(
            '젖소 산지 가격 동향',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: PriceTrendColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 카테고리 선택 버튼 섹션
  Widget _buildCategorySelector() {
    return Container(
      color: PriceTrendColors.cardBackground,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PriceTrendColors.borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = selectedCategoryIndex == index;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedCategoryIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PriceTrendColors.primaryGreen
                          : PriceTrendColors.buttonInactive,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: PriceTrendColors.primaryGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : PriceTrendColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 📊 그래프 섹션
  Widget _buildChartSection() {
    final selectedCategory = categories[selectedCategoryIndex];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: PriceTrendColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: PriceTrendColors.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '2025년 $selectedCategory 가격동향',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PriceTrendColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '단위: 천원/두',
                  style: TextStyle(
                    fontSize: 14,
                    color: PriceTrendColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '출처: 농협 축산정보센터',
                  style: TextStyle(
                    fontSize: 12,
                    color: PriceTrendColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // 그래프
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            child: _buildLineChart(),
          ),
        ],
      ),
    );
  }

  /// 📈 LineChart 위젯
  Widget _buildLineChart() {
    final selectedCategory = categories[selectedCategoryIndex];
    final chartData = _getChartData(selectedCategory);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) => FlLine(
            color: PriceTrendColors.borderColor,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: PriceTrendColors.borderColor,
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['1월', '2월', '3월', '4월', '5월', '6월'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[value.toInt()],
                      style: const TextStyle(
                        fontSize: 12,
                        color: PriceTrendColors.textSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    NumberFormat('#,###').format(value.toInt()),
                    style: const TextStyle(
                      fontSize: 10,
                      color: PriceTrendColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: PriceTrendColors.borderColor,
            width: 1,
          ),
        ),
        lineBarsData: chartData,
        minX: 0,
        maxX: 5,
                 lineTouchData: LineTouchData(
           touchTooltipData: LineTouchTooltipData(
             tooltipBgColor: PriceTrendColors.cardBackground,
             getTooltipItems: (touchedSpots) {
               return touchedSpots.map((spot) {
                 final monthIndex = spot.x.toInt();
                 final months = ['1월', '2월', '3월', '4월', '5월', '6월'];
                 final month = months[monthIndex];
                 final value = NumberFormat('#,###').format(spot.y.toInt());
                 
                 return LineTooltipItem(
                   '$month\n$value천원',
                   const TextStyle(
                     color: PriceTrendColors.textPrimary,
                     fontSize: 12,
                     fontWeight: FontWeight.w600,
                   ),
                 );
               }).toList();
             },
           ),
         ),
      ),
    );
  }

  /// 차트 데이터 생성
  List<LineChartBarData> _getChartData(String category) {
    final List<LineChartBarData> lines = [];
    
    if (category == '초유떼기' || category == '분유떼기') {
      // 암수 두 개의 선
      final femaleKey = '${category}암';
      final maleKey = '${category}수';
      
      // 암컷 데이터
      final femaleSpots = sampleData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value[femaleKey]?.toDouble() ?? 0);
      }).toList();
      
      // 수컷 데이터
      final maleSpots = sampleData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value[maleKey]?.toDouble() ?? 0);
      }).toList();
      
      lines.add(
        LineChartBarData(
          spots: femaleSpots,
          isCurved: true,
          color: PriceTrendColors.redLine,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
      
      lines.add(
        LineChartBarData(
          spots: maleSpots,
          isCurved: true,
          color: PriceTrendColors.blueLine,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
    } else {
      // 단일 선
      final spots = sampleData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value[category]?.toDouble() ?? 0);
      }).toList();
      
      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _getCategoryColor(category),
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      );
    }
    
    return lines;
  }

  /// 카테고리별 색상 반환
  Color _getCategoryColor(String category) {
    switch (category) {
      case '수정단계':
        return const Color(0xFF8B5CF6);
      case '초임만삭':
        return const Color(0xFF06B6D4);
      case '초산우':
        return const Color(0xFFF59E0B);
      case '다산우(4산)':
        return const Color(0xFFEC4899);
      case '노폐우':
        return const Color(0xFF84CC16);
      default:
        return PriceTrendColors.primaryGreen;
    }
  }

  /// 📋 가격표 섹션
  Widget _buildPriceTableSection() {
    final selectedCategory = categories[selectedCategoryIndex];
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: PriceTrendColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: PriceTrendColors.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$selectedCategory 가격표',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PriceTrendColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '단위: 천원/두',
                  style: TextStyle(
                    fontSize: 14,
                    color: PriceTrendColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 테이블
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildDataTable(selectedCategory),
          ),
        ],
      ),
    );
  }

  /// 데이터 테이블 생성
  Widget _buildDataTable(String category) {
    List<String> columns = ['월'];
    
    if (category == '초유떼기' || category == '분유떼기') {
      columns.addAll(['암', '수']);
    } else {
      columns.add('가격');
    }
    
    return DataTable(
      columnSpacing: 24,
      headingRowHeight: 48,
      dataRowMinHeight: 40,
      dataRowMaxHeight: 48,
      headingRowColor: MaterialStateProperty.all(
        const Color(0xFFF9FAFB),
      ),
      columns: columns.map((column) {
        return DataColumn(
          label: Text(
            column,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: PriceTrendColors.textPrimary,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
      rows: sampleData.map((data) {
        List<DataCell> cells = [
          DataCell(
            Text(
              data['month'],
              style: const TextStyle(
                color: PriceTrendColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ];
        
        if (category == '초유떼기' || category == '분유떼기') {
          cells.addAll([
            DataCell(
              Text(
                NumberFormat('#,###').format(data['${category}암'] ?? 0),
                style: const TextStyle(
                  color: PriceTrendColors.textPrimary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            DataCell(
              Text(
                NumberFormat('#,###').format(data['${category}수'] ?? 0),
                style: const TextStyle(
                  color: PriceTrendColors.textPrimary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ]);
        } else {
          cells.add(
            DataCell(
              Text(
                NumberFormat('#,###').format(data[category] ?? 0),
                style: const TextStyle(
                  color: PriceTrendColors.textPrimary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        
        return DataRow(cells: cells);
      }).toList(),
    );
  }
}

/// 기존 PriceTrendChartView 위젯 (하위 호환성을 위해 유지)
class PriceTrendChartView extends StatefulWidget {
  final String initialType;
  
  const PriceTrendChartView({super.key, required this.initialType});

  @override
  State<PriceTrendChartView> createState() => _PriceTrendChartViewState();
}

class _PriceTrendChartViewState extends State<PriceTrendChartView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PriceTrendDetailPage(
              initialCategory: widget.initialType,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: PriceTrendColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.initialType} 가격동향',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PriceTrendColors.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: PriceTrendColors.textMuted,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '자세한 가격동향을 확인하려면 탭하세요',
              style: TextStyle(
                fontSize: 14,
                color: PriceTrendColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
