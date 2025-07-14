import 'package:flutter/material.dart';
import 'package:cow_management/models/price_trend.dart';

class PriceTrendDetailPage extends StatefulWidget {
  final String initialType; // 'dairy', 'hanwoo', 'wholesale' 등
  const PriceTrendDetailPage({super.key, required this.initialType});

  @override
  State<PriceTrendDetailPage> createState() => _PriceTrendDetailPageState();
}

class _PriceTrendDetailPageState extends State<PriceTrendDetailPage> {
  int selectedIndex = 0;
  final priceTypeKeyMap = {
    '초유떼기': ['초유떼기_암', '초유떼기_수'],
    '분유떼기': ['분유떼기_암', '분유떼기_수'],
    '수정단계': ['수정단계', ''],
    '초임만삭': ['초임만삭', ''],
    '초산우': ['초산우', ''],
    '다산우': ['다산우', ''],
    '노폐우': ['노폐우', ''],
  };
  @override
  void initState() {
    super.initState();
    // 홈에서 진입 시 기본 탭(초유떼기) 선택
    selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('젖소 산지 가격 상세'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(priceTypeKeyMap.length, (idx) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(priceTypeKeyMap.keys.elementAt(idx)),
                        selected: selectedIndex == idx,
                        onSelected: (_) {
                          setState(() => selectedIndex = idx);
                        },
                        selectedColor: const Color(0xFF4CAF50),
                        labelStyle: TextStyle(
                          color: selectedIndex == idx
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildChartAndTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartAndTable() {
    // 2025년 젖소 가격동향 표 데이터
    final List<Map<String, dynamic>> tableData = [
      {
        '월': '1월',
        '초유떼기_암': 24,
        '초유떼기_수': 65,
        '분유떼기_암': 194,
        '분유떼기_수': 440,
        '수정단계': 1339,
        '초임만삭': 3505,
        '초산우': 3560,
        '다산우': 2749,
        '노폐우': 1113
      },
      {
        '월': '2월',
        '초유떼기_암': 22,
        '초유떼기_수': 72,
        '분유떼기_암': 185,
        '분유떼기_수': 477,
        '수정단계': 1366,
        '초임만삭': 3520,
        '초산우': 3613,
        '다산우': 2811,
        '노폐우': 1069
      },
      {
        '월': '3월',
        '초유떼기_암': 24,
        '초유떼기_수': 74,
        '분유떼기_암': 183,
        '분유떼기_수': 479,
        '수정단계': 1330,
        '초임만삭': 3460,
        '초산우': 3539,
        '다산우': 2811,
        '노폐우': 1042
      },
      {
        '월': '4월',
        '초유떼기_암': 27,
        '초유떼기_수': 92,
        '분유떼기_암': 184,
        '분유떼기_수': 482,
        '수정단계': 1378,
        '초임만삭': 3495,
        '초산우': 3600,
        '다산우': 2795,
        '노폐우': 1283
      },
      {
        '월': '5월',
        '초유떼기_암': 30,
        '초유떼기_수': 108,
        '분유떼기_암': 192,
        '분유떼기_수': 498,
        '수정단계': 1364,
        '초임만삭': 3441,
        '초산우': 3555,
        '다산우': 2743,
        '노폐우': 1071
      },
    ];
    final months = tableData.map((e) => e['월'] as String).toList();
    final colostrumFemale = tableData.map((e) => e['초유떼기_암'] as int).toList();
    final colostrumMale = tableData.map((e) => e['초유떼기_수'] as int).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Text('2025년 젖소 산지 가격동향',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('단위: 천원/두',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 2),
          const Text('출처: 농협 축산정보센터',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: 140,
                  width: 340,
                  child: CustomPaint(
                    painter: _ColostrumLineChartPainter(
                        colostrumFemale, colostrumMale, months),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 16, height: 4, color: const Color(0xFF4CAF50)),
              const SizedBox(width: 4),
              const Text('초유떼기 암', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 16),
              Container(width: 16, height: 4, color: const Color(0xFF2196F3)),
              const SizedBox(width: 4),
              const Text('초유떼기 수', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFE8F5E9)),
                  columns: const [
                    DataColumn(
                        label: Text('월',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('초유떼기\n암',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('초유떼기\n수',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('분유떼기\n암',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('분유떼기\n수',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('수정단계',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('초임만삭',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('초산우',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('다산우(4산)',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('노폐우',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('1월')),
                      DataCell(Text('24')),
                      DataCell(Text('65')),
                      DataCell(Text('194')),
                      DataCell(Text('440')),
                      DataCell(Text('1339')),
                      DataCell(Text('3505')),
                      DataCell(Text('3560')),
                      DataCell(Text('2749')),
                      DataCell(Text('1113')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('2월')),
                      DataCell(Text('22')),
                      DataCell(Text('72')),
                      DataCell(Text('185')),
                      DataCell(Text('477')),
                      DataCell(Text('1366')),
                      DataCell(Text('3520')),
                      DataCell(Text('3613')),
                      DataCell(Text('2811')),
                      DataCell(Text('1069')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('3월')),
                      DataCell(Text('24')),
                      DataCell(Text('74')),
                      DataCell(Text('183')),
                      DataCell(Text('479')),
                      DataCell(Text('1330')),
                      DataCell(Text('3460')),
                      DataCell(Text('3539')),
                      DataCell(Text('2811')),
                      DataCell(Text('1042')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('4월')),
                      DataCell(Text('27')),
                      DataCell(Text('92')),
                      DataCell(Text('184')),
                      DataCell(Text('482')),
                      DataCell(Text('1378')),
                      DataCell(Text('3495')),
                      DataCell(Text('3600')),
                      DataCell(Text('2795')),
                      DataCell(Text('1283')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('5월')),
                      DataCell(Text('30')),
                      DataCell(Text('108')),
                      DataCell(Text('192')),
                      DataCell(Text('498')),
                      DataCell(Text('1364')),
                      DataCell(Text('3441')),
                      DataCell(Text('3555')),
                      DataCell(Text('2743')),
                      DataCell(Text('1071')),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColostrumLineChartPainter extends CustomPainter {
  final List<int> female;
  final List<int> male;
  final List<String> months;
  _ColostrumLineChartPainter(this.female, this.male, this.months);

  @override
  void paint(Canvas canvas, Size size) {
    if (female.isEmpty || male.isEmpty) return;
    final minY = [
      ...female,
      ...male,
    ].reduce((a, b) => a < b ? a : b).toDouble();
    final maxY = [
      ...female,
      ...male,
    ].reduce((a, b) => a > b ? a : b).toDouble();
    final dx = size.width / (female.length - 1);
    final dy = (maxY - minY).abs() < 1e-6 ? 1 : (maxY - minY);
    final pointsFemale = <Offset>[];
    final pointsMale = <Offset>[];
    for (int i = 0; i < female.length; i++) {
      final x = dx * i;
      final yF =
          size.height - 20 - ((female[i] - minY) / dy * (size.height - 30));
      final yM =
          size.height - 20 - ((male[i] - minY) / dy * (size.height - 30));
      pointsFemale.add(Offset(x, yF));
      pointsMale.add(Offset(x, yM));
    }
    final linePaintF = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final linePaintM = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final dotPaintF = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    final dotPaintM = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;
    // Draw lines
    for (int i = 0; i < pointsFemale.length - 1; i++) {
      canvas.drawLine(pointsFemale[i], pointsFemale[i + 1], linePaintF);
      canvas.drawLine(pointsMale[i], pointsMale[i + 1], linePaintM);
    }
    // Draw dots
    for (final p in pointsFemale) {
      canvas.drawCircle(p, 3, dotPaintF);
    }
    for (final p in pointsMale) {
      canvas.drawCircle(p, 3, dotPaintM);
    }
    // Draw x labels
    const textStyle = TextStyle(fontSize: 11, color: Colors.black);
    for (int i = 0; i < months.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: months[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = pointsFemale[i].dx - tp.width / 2;
      final y = size.height - tp.height + 2;
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _YAxisLabels extends StatelessWidget {
  final List<int> values;
  const _YAxisLabels({required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox(width: 32);
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final midY = ((minY + maxY) / 2).round();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$maxY', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text('$midY', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text('$minY', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Text('단위', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  final List<int> values;
  _SimpleLineChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final minY = values.reduce((a, b) => a < b ? a : b).toDouble();
    final maxY = values.reduce((a, b) => a > b ? a : b).toDouble();
    final dx = size.width / (values.length - 1);
    final dy = maxY == minY ? 1 : (maxY - minY);
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = size.height - ((values[i] - minY) / dy * size.height);
      points.add(Offset(x, y));
    }
    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final dotPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }
    // Draw dots
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
    // Draw x labels
    const textStyle = TextStyle(fontSize: 12, color: Colors.black);
    for (int i = 0; i < values.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: '${i + 1}월', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = points[i].dx - tp.width / 2;
      final y = size.height + 2;
      tp.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
