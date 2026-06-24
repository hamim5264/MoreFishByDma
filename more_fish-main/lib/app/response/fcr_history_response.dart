import 'dart:convert';

class FcrHistoryResponse {
  final bool success;
  final int statusCode;
  final List<FcrRecord> data;

  FcrHistoryResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory FcrHistoryResponse.fromRawJson(String str) =>
      FcrHistoryResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FcrHistoryResponse.fromJson(Map<String, dynamic> json) =>
      FcrHistoryResponse(
        success: json["success"] ?? false,
        statusCode: json["status_code"] ?? 0,
        data: json["data"] == null
            ? []
            : List<FcrRecord>.from(
                json["data"].map((x) => FcrRecord.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FcrRecord {
  final int? id;
  final int? assetId;
  final String? assetName;
  final String? feedWeightKg;
  final String? weightGainedKg;
  final double? fcr;
  final DateTime? calculatedAt;
  final String? notes;

  FcrRecord({
    this.id,
    this.assetId,
    this.assetName,
    this.feedWeightKg,
    this.weightGainedKg,
    this.fcr,
    this.calculatedAt,
    this.notes,
  });

  factory FcrRecord.fromJson(Map<String, dynamic> json) => FcrRecord(
    id: json["id"],
    assetId: json["asset_id"],
    assetName: json["asset_name"],
    feedWeightKg: json["feed_weight_kg"]?.toString(),
    weightGainedKg: json["weight_gained_kg"]?.toString(),
    fcr: json["fcr"]?.toDouble(),
    calculatedAt: json["calculated_at"] == null
        ? null
        : DateTime.parse(json["calculated_at"]),
    notes: json["notes"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "asset_id": assetId,
    "asset_name": assetName,
    "feed_weight_kg": feedWeightKg,
    "weight_gained_kg": weightGainedKg,
    "fcr": fcr,
    "calculated_at": calculatedAt?.toIso8601String(),
    "notes": notes,
  };
}
