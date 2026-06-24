import 'dart:convert';

class AeratorAutomationResponse {
  bool? success;
  String? message;
  AutomationData? data;

  AeratorAutomationResponse({this.success, this.message, this.data});

  factory AeratorAutomationResponse.fromRawJson(String str) =>
      AeratorAutomationResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AeratorAutomationResponse.fromJson(Map<String, dynamic> json) =>
      AeratorAutomationResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : AutomationData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class AutomationData {
  int? id;
  int? deviceId;
  bool? isEnabled;
  double? doMin;
  double? doMax;

  AutomationData({
    this.id,
    this.deviceId,
    this.isEnabled,
    this.doMin,
    this.doMax,
  });

  factory AutomationData.fromRawJson(String str) =>
      AutomationData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AutomationData.fromJson(Map<String, dynamic> json) => AutomationData(
    id: json["id"],
    deviceId: json["device_id"] is String
        ? int.tryParse(json["device_id"])
        : json["device_id"],
    isEnabled: json["is_enabled"],
    doMin: json["do_min"]?.toDouble(),
    doMax: json["do_max"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "device_id": deviceId,
    "is_enabled": isEnabled,
    "do_min": doMin,
    "do_max": doMax,
  };
}
