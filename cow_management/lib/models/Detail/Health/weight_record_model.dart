class WeightRecord {
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

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      cowId: json['cow_id'],
      recordDate: json['record_date'],
      measurementTime: json['measurement_time'],
      weight: (json['weight'] as num?)?.toDouble(),
      measurementMethod: json['measurement_method'],
      bodyConditionScore: (json['body_condition_score'] as num?)?.toDouble(),
      heightWithers: (json['height_withers'] as num?)?.toDouble(),
      bodyLength: (json['body_length'] as num?)?.toDouble(),
      chestGirth: (json['chest_girth'] as num?)?.toDouble(),
      growthRate: (json['growth_rate'] as num?)?.toDouble(),
      targetWeight: (json['target_weight'] as num?)?.toDouble(),
      weightCategory: json['weight_category'],
      measurer: json['measurer'],
      notes: json['notes'],
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
