class FeedingRecord {
  final String id;
  final String cowId;
  final String feedingDate;
  final String feedType;
  final double amount;
  final String feedTime;
  final String? notes;

  FeedingRecord({
    required this.id,
    required this.cowId,
    required this.feedingDate,
    required this.feedType,
    required this.amount,
    required this.feedTime,
    this.notes,
  });

  factory FeedingRecord.fromJson(Map<String, dynamic> json) {
    final kv = json['key_values'] ?? {};
    return FeedingRecord(
      id: json['id'],
      cowId: json['cow_id'],
      feedingDate:
          json['record_date'], // 서버는 'feeding_date' 대신 'record_date' 사용
      feedType: kv['feed_type'] ?? '',
      amount: (kv['amount'] ?? 0).toDouble(),
      feedTime: kv['feed_time'] ?? '',
      notes: kv['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'record_type': 'feed',
      'cow_id': cowId,
      'record_date': feedingDate,
      'title': '사료 기록',
      'key_values': {
        'feed_type': feedType,
        'amount': amount,
        'feed_time': feedTime,
        'notes': notes,
      },
    };
  }
}
