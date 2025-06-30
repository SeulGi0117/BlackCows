class PriceTrend {
  final String month;
  final int colostrumFemale;
  final int colostrumMale;
  final int formulaFemale;
  final int formulaMale;
  final int insemination;
  final int firstPregnant;
  final int firstCow;
  final int multiCow;
  final int oldCow;

  PriceTrend({
    required this.month,
    required this.colostrumFemale,
    required this.colostrumMale,
    required this.formulaFemale,
    required this.formulaMale,
    required this.insemination,
    required this.firstPregnant,
    required this.firstCow,
    required this.multiCow,
    required this.oldCow,
  });

  factory PriceTrend.fromJson(Map<String, dynamic> json) {
    return PriceTrend(
      month: json['월'] as String,
      colostrumFemale: json['초유떼기_암'] as int,
      colostrumMale: json['초유떼기_수'] as int,
      formulaFemale: json['분유떼기_암'] as int,
      formulaMale: json['분유떼기_수'] as int,
      insemination: json['수정단계'] as int,
      firstPregnant: json['초임만삭'] as int,
      firstCow: json['초산우'] as int,
      multiCow: json['다산우'] as int,
      oldCow: json['노폐우'] as int,
    );
  }
} 