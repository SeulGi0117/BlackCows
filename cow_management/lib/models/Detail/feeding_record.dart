// models/Detail/Feeding/feed_record.dart

class FeedRecord {
  final String? id;
  final String cowId;
  final String recordDate;

  final String feedTime;
  final String feedType;
  final double feedAmount;
  final String feedQuality;
  final String supplementType;
  final double supplementAmount;
  final double waterConsumption;
  final String appetiteCondition;
  final double feedEfficiency;
  final double costPerFeed;
  final String fedBy;
  final String notes;

  FeedRecord({
    this.id,
    required this.cowId,
    required this.recordDate,
    this.feedTime = '',
    this.feedType = '',
    this.feedAmount = 0.0,
    this.feedQuality = '',
    this.supplementType = '',
    this.supplementAmount = 0.0,
    this.waterConsumption = 0.0,
    this.appetiteCondition = '',
    this.feedEfficiency = 0.0,
    this.costPerFeed = 0.0,
    this.fedBy = '',
    this.notes = '',
  });

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final clean = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  factory FeedRecord.fromJson(Map<String, dynamic> json) {
    final safeJson = Map<String, dynamic>.from(json);
    Map<String, dynamic> data = {};

    if (safeJson['record_data'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['record_data']));
    }
    if (safeJson['key_values'] != null) {
      data.addAll(Map<String, dynamic>.from(safeJson['key_values']));
    }

    data['cow_id'] = safeJson['cow_id'];
    data['record_date'] = safeJson['record_date'];

    return FeedRecord(
      id: safeJson['id']?.toString(),
      cowId: data['cow_id'] ?? '',
      recordDate: data['record_date'] ?? '',
      feedTime: data['feed_time']?.toString() ?? '',
      feedType: data['feed_type']?.toString() ?? '',
      feedAmount: _parseDouble(data['feed_amount']),
      feedQuality: data['feed_quality']?.toString() ?? '',
      supplementType: data['supplement_type']?.toString() ?? '',
      supplementAmount: _parseDouble(data['supplement_amount']),
      waterConsumption: _parseDouble(data['water_consumption']),
      appetiteCondition: data['appetite_condition']?.toString() ?? '',
      feedEfficiency: _parseDouble(data['feed_efficiency']),
      costPerFeed: _parseDouble(data['cost_per_feed']),
      fedBy: data['fed_by']?.toString() ?? '',
      notes: data['notes']?.toString() ??
          safeJson['description']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cow_id': cowId,
        'record_date': recordDate,
        'title': '사료급여 기록',
        'description': notes.isNotEmpty ? notes : '사료급여 기록 작성',
        'feed_time': feedTime,
        'feed_type': feedType,
        'feed_amount': feedAmount,
        'feed_quality': feedQuality,
        'supplement_type': supplementType,
        'supplement_amount': supplementAmount,
        'water_consumption': waterConsumption,
        'appetite_condition': appetiteCondition,
        'feed_efficiency': feedEfficiency,
        'cost_per_feed': costPerFeed,
        'fed_by': fedBy,
        'notes': notes,
      };
}
