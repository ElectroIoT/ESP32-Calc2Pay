import 'dart:convert';

/// Mirrors the firmware's `MerchantConfig` JSON shape exactly
/// (../../firmware/src/MerchantConfig.cpp `toJson`/`fromJson`).
class MerchantConfig {
  MerchantConfig({
    required this.vpa,
    required this.businessName,
    required this.gstPercent,
    required this.discountPercent,
  });

  factory MerchantConfig.empty() => MerchantConfig(
        vpa: '',
        businessName: '',
        gstPercent: 0,
        discountPercent: 0,
      );

  factory MerchantConfig.fromJson(Map<String, dynamic> json) {
    return MerchantConfig(
      vpa: json['vpa'] as String? ?? '',
      businessName: json['name'] as String? ?? '',
      gstPercent: (json['gst_percent'] as num?)?.toDouble() ?? 0,
      discountPercent: (json['discount_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  factory MerchantConfig.fromJsonString(String source) {
    return MerchantConfig.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  final String vpa;
  final String businessName;
  final double gstPercent;
  final double discountPercent;

  MerchantConfig copyWith({
    String? vpa,
    String? businessName,
    double? gstPercent,
    double? discountPercent,
  }) {
    return MerchantConfig(
      vpa: vpa ?? this.vpa,
      businessName: businessName ?? this.businessName,
      gstPercent: gstPercent ?? this.gstPercent,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }

  Map<String, dynamic> toJson() => {
        'vpa': vpa,
        'name': businessName,
        'gst_percent': gstPercent,
        'discount_percent': discountPercent,
      };

  String toJsonString() => jsonEncode(toJson());
}
