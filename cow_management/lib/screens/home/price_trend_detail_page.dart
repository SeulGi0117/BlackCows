import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceTrendChartView extends StatefulWidget {
  final String initialType; // '초유떼기', '분유떼기' 등
  const PriceTrendChartView({super.key, required this.initialType});

  @override
  State<PriceTrendChartView> createState() => _PriceTrendChartViewState();
}

class _PriceTrendChartViewState extends State<PriceTrendChartView> {
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
    selectedIndex = priceTypeKeyMap.keys.toList().indexOf(widget.initialType);
    if (selectedIndex == -1) selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Card(
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: IntrinsicWidth(
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
        ),
        const SizedBox(height: 16),
        _buildChartAndTable(),
      ],
    );
  }

  Widget _buildChartAndTable() {
    final selectedKey = priceTypeKeyMap.keys.elementAt(selectedIndex);
    final selectedColumns = priceTypeKeyMap[selectedKey]!;

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
    final data1 =
        tableData.map((e) => e[selectedColumns[0]] ?? 0).cast<int>().toList();
    final data2 = selectedColumns.length > 1 && selectedColumns[1].isNotEmpty
        ? tableData.map((e) => e[selectedColumns[1]] ?? 0).cast<int>().toList()
        : List.filled(tableData.length, 0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Text('2025년 $selectedKey 가격동향',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        data1, data2, months, selectedColumns),
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
              Text(selectedColumns[0], style: const TextStyle(fontSize: 12)),
              if (selectedColumns.length > 1 &&
                  selectedColumns[1].isNotEmpty) ...[
                const SizedBox(width: 16),
                Container(width: 16, height: 4, color: const Color(0xFF2196F3)),
                const SizedBox(width: 4),
                Text(selectedColumns[1], style: const TextStyle(fontSize: 12)),
              ]
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
                  columnSpacing: 30,
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => const Color(0xFFE8F5E9)),
                  columns: [
                    const DataColumn(label: Text('월')),
                    ...selectedColumns.where((c) => c.isNotEmpty).map(
                          (col) => DataColumn(label: Text(col)),
                        ),
                  ],
                  rows: tableData.map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row['월'].toString())),
                      ...selectedColumns.where((c) => c.isNotEmpty).map(
                            (col) =>
                                DataCell(Text(row[col]?.toString() ?? '-')),
                          ),
                    ]);
                  }).toList(),
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
  final List<String> labels;
  _ColostrumLineChartPainter(this.female, this.male, this.months, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    if (female.isEmpty || male.isEmpty) return;

    final minY =
        [...female, ...male].reduce((a, b) => a < b ? a : b).toDouble();
    final maxY =
        [...female, ...male].reduce((a, b) => a > b ? a : b).toDouble();
    final dx = size.width / (female.length - 1);
    final dy = (maxY - minY).abs() < 1e-6 ? 1 : (maxY - minY);

    final pointsFemale = <Offset>[];
    final pointsMale = <Offset>[];

    for (int i = 0; i < female.length; i++) {
      final x = dx * i;
      final yF =
          size.height - 30 - ((female[i] - minY) / dy * (size.height - 50));
      final yM =
          size.height - 30 - ((male[i] - minY) / dy * (size.height - 50));
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

    // Draw dots and values (female)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < pointsFemale.length; i++) {
      canvas.drawCircle(pointsFemale[i], 3, dotPaintF);

      textPainter.text = TextSpan(
        text: female[i].toString(),
        style: const TextStyle(fontSize: 10, color: Color(0xFF4CAF50)),
      );
      textPainter.layout();
      final offset = Offset(
        pointsFemale[i].dx - textPainter.width / 2,
        pointsFemale[i].dy - 14,
      );
      textPainter.paint(canvas, offset);
    }

    // Draw dots and values (male)
    for (int i = 0; i < pointsMale.length; i++) {
      canvas.drawCircle(pointsMale[i], 3, dotPaintM);

      textPainter.text = TextSpan(
        text: male[i].toString(),
        style: const TextStyle(fontSize: 10, color: Color(0xFF2196F3)),
      );
      textPainter.layout();
      final offset = Offset(
        pointsMale[i].dx - textPainter.width / 2,
        pointsMale[i].dy - 14,
      );
      textPainter.paint(canvas, offset);
    }

    // Draw x-axis labels
    const labelStyle = TextStyle(fontSize: 11, color: Colors.black);
    for (int i = 0; i < months.length; i++) {
      final labelPainter = TextPainter(
        text: TextSpan(text: months[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final x = pointsFemale[i].dx - labelPainter.width / 2;
      final y = size.height - labelPainter.height;
      labelPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
