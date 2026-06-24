import 'dart:convert';

class CleanerStatusResponse {
  final bool success;
  final String? cleanerId;
  final bool? isOn;
  final String? lastRunAt;
  final String? message;

  CleanerStatusResponse({
    required this.success,
    this.cleanerId,
    this.isOn,
    this.lastRunAt,
    this.message,
  });

  factory CleanerStatusResponse.fromRawJson(String str) =>
      CleanerStatusResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CleanerStatusResponse.fromJson(Map<String, dynamic> json) =>
      CleanerStatusResponse(
        success: json["success"],
        cleanerId: json["cleaner_id"],
        isOn: json["is_on"],
        lastRunAt: json["last_run_at"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "cleaner_id": cleanerId,
    "is_on": isOn,
    "last_run_at": lastRunAt,
    "message": message,
  };
}
