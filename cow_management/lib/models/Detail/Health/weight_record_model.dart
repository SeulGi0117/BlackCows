class WeightRecord {
  final String? id;
  final String cowId;
  final String recordDate;
  final String? measurementTime;
  final double? weight;
  final String? measurementMethod;
  final double? bodyConditionScore;
  final double? heightWithers;
  final double? bodyLength;
  final double? chestGirth;
  final double? growthRate;
  final double? targetWeight;
  final String? weightCategory;
  final String? measurer;
  final String? notes;

  WeightRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.measurementTime,
    this.weight,
    this.measurementMethod,
    this.bodyConditionScore,
    this.heightWithers,
    this.bodyLength,
    this.chestGirth,
    this.growthRate,
    this.targetWeight,
    this.weightCategory,
    this.measurer,
    this.notes,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanValue);
    }
    return null;
  }

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    // 안전한 타입 캐스팅
    final Map<String, dynamic> safeJson = Map<String, dynamic>.from(json);
    
    // 데이터 소스 우선순위: record_data > key_values > 기본 json
    Map<String, dynamic> data = {};
    
    // 기본 json 데이터 추가
    data.addAll(safeJson);
    
    // key_values가 있고 비어있지 않으면 사용 (서버 응답 형태)
    if (safeJson['key_values'] != null && safeJson['key_values'] is Map) {
      final keyValues = Map<String, dynamic>.from(safeJson['key_values']);
      
      // key_values가 비어있지 않은 경우에만 매핑
      if (keyValues.isNotEmpty) {
        // key_values에서 필드 매핑
        if (keyValues.containsKey('weight')) {
          data['weight'] = keyValues['weight'];
        }
        if (keyValues.containsKey('measurement_method')) {
          data['measurement_method'] = keyValues['measurement_method'];
        }
        if (keyValues.containsKey('body_condition_score')) {
          data['body_condition_score'] = keyValues['body_condition_score'];
        }
      }
    }
    
    // record_data가 있으면 우선적으로 사용 (실제 데이터가 저장된 곳)
    if (safeJson['record_data'] != null) {
      final recordData = Map<String, dynamic>.from(safeJson['record_data']);
      data.addAll(recordData);
      print('🔍 record_data에서 체중 데이터 발견: ${recordData['weight']}');
    }

    String recordDateStr;
    final recordDateRaw = safeJson['record_date'] ?? data['record_date'];
    if (recordDateRaw is int) {
      recordDateStr = DateTime.fromMillisecondsSinceEpoch(recordDateRaw * 1000)
          .toIso8601String()
          .split('T')[0];
    } else {
      recordDateStr = recordDateRaw?.toString() ?? '';
    }

    // 디버그 로그 추가
    print('🔍 WeightRecord 파싱 디버그:');
    print('   - safeJson: $safeJson');
    print('   - data: $data');
    print('   - weight: ${data['weight']} (${data['weight'].runtimeType})');

    return WeightRecord(
      id: safeJson['id']?.toString(),
      cowId: safeJson['cow_id']?.toString() ?? data['cow_id']?.toString() ?? '',
      recordDate: recordDateStr,
      measurementTime: data['measurement_time']?.toString(),
      weight: _parseDouble(data['weight']),
      measurementMethod: data['measurement_method']?.toString(),
      bodyConditionScore: _parseDouble(data['body_condition_score']),
      heightWithers: _parseDouble(data['height_withers']),
      bodyLength: _parseDouble(data['body_length']),
      chestGirth: _parseDouble(data['chest_girth']),
      growthRate: _parseDouble(data['growth_rate']),
      targetWeight: _parseDouble(data['target_weight']),
      weightCategory: data['weight_category']?.toString(),
      measurer: data['measurer']?.toString(),
      notes: data['notes']?.toString() ?? safeJson['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cow_id': cowId,
      'record_date': recordDate,
      if (measurementTime != null) 'measurement_time': measurementTime,
      if (weight != null) 'weight': weight,
      if (measurementMethod != null) 'measurement_method': measurementMethod,
      if (bodyConditionScore != null)
        'body_condition_score': bodyConditionScore,
      if (heightWithers != null) 'height_withers': heightWithers,
      if (bodyLength != null) 'body_length': bodyLength,
      if (chestGirth != null) 'chest_girth': chestGirth,
      if (growthRate != null) 'growth_rate': growthRate,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (weightCategory != null) 'weight_category': weightCategory,
      if (measurer != null) 'measurer': measurer,
      if (notes != null) 'notes': notes,
    };
  }

  Map<String, dynamic> toRecordDataJson() {
    return {
      if (measurementTime != null) 'measurement_time': measurementTime,
      if (weight != null) 'weight': weight,
      if (measurementMethod != null) 'measurement_method': measurementMethod,
      if (bodyConditionScore != null)
        'body_condition_score': bodyConditionScore,
      if (heightWithers != null) 'height_withers': heightWithers,
      if (bodyLength != null) 'body_length': bodyLength,
      if (chestGirth != null) 'chest_girth': chestGirth,
      if (growthRate != null) 'growth_rate': growthRate,
      if (targetWeight != null) 'target_weight': targetWeight,
      if (weightCategory != null) 'weight_category': weightCategory,
      if (measurer != null) 'measurer': measurer,
      if (notes != null) 'notes': notes,
    };
  }
}
