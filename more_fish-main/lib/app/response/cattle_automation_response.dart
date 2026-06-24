import 'dart:convert';

class CattleAutomationResponse {
  bool? success;
  String? message;
  CattleAutomationData? data;

  CattleAutomationResponse({this.success, this.message, this.data});

  factory CattleAutomationResponse.fromRawJson(String str) =>
      CattleAutomationResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CattleAutomationResponse.fromJson(Map<String, dynamic> json) =>
      CattleAutomationResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : CattleAutomationData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class CattleAutomationData {
  int? id;
  int? farm;
  bool? isEnabled;
  double? fanTempMin;
  double? fanTempMax;
  double? foggerHumidityMin;
  List<LightSchedule>? lightSchedules;
  DateTime? updatedAt;

  CattleAutomationData({
    this.id,
    this.farm,
    this.isEnabled,
    this.fanTempMin,
    this.fanTempMax,
    this.foggerHumidityMin,
    this.lightSchedules,
    this.updatedAt,
  });

  factory CattleAutomationData.fromRawJson(String str) =>
      CattleAutomationData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CattleAutomationData.fromJson(Map<String, dynamic> json) =>
      CattleAutomationData(
        id: json["id"],
        farm: json["farm"],
        isEnabled: json["is_enabled"],
        fanTempMin: json["fan_temp_min"]?.toDouble(),
        fanTempMax: json["fan_temp_max"]?.toDouble(),
        foggerHumidityMin: json["fogger_humidity_min"]?.toDouble(),
        lightSchedules: json["light_schedules"] == null
            ? []
            : List<LightSchedule>.from(
                json["light_schedules"]!.map((x) => LightSchedule.fromJson(x)),
              ),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "farm": farm,
    "is_enabled": isEnabled,
    "fan_temp_min": fanTempMin,
    "fan_temp_max": fanTempMax,
    "fogger_humidity_min": foggerHumidityMin,
    "light_schedules": lightSchedules == null
        ? []
        : List<dynamic>.from(lightSchedules!.map((x) => x.toJson())),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class LightSchedule {
  int? id;
  String? startTime;
  String? endTime;

  LightSchedule({this.id, this.startTime, this.endTime});

  factory LightSchedule.fromRawJson(String str) =>
      LightSchedule.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LightSchedule.fromJson(Map<String, dynamic> json) => LightSchedule(
    id: json["id"],
    startTime: json["start_time"],
    endTime: json["end_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "start_time": startTime,
    "end_time": endTime,
  };
}
