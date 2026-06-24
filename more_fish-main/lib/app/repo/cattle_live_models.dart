class CattleLiveData {
  final String deviceId;
  final String timestamp;
  final double nh3MgL;
  final double temperatureC;
  final int humidityPct;
  final int co2Ppm;
  final double vocMgM3;
  final int noiseDb;
  final int pm25UgM3;
  final int pm10UgM3;

  const CattleLiveData({
    required this.deviceId,
    required this.timestamp,
    required this.nh3MgL,
    required this.temperatureC,
    required this.humidityPct,
    required this.co2Ppm,
    required this.vocMgM3,
    required this.noiseDb,
    required this.pm25UgM3,
    required this.pm10UgM3,
  });

  factory CattleLiveData.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;
    int toInt(dynamic v) => (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    return CattleLiveData(
      deviceId: (json['deviceId'] ?? '').toString(),
      timestamp: (json['timestamp'] ?? '').toString(),
      nh3MgL: toDouble(json['nh3']),
      temperatureC: toDouble(json['temperature']),
      humidityPct: toInt(json['humidity']),
      co2Ppm: toInt(json['co2']),
      vocMgM3: toDouble(json['voc']),
      noiseDb: toInt(json['noise']),
      pm25UgM3: toInt(json['pm25']),
      pm10UgM3: toInt(json['pm10']),
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'timestamp': timestamp,
    'nh3': nh3MgL,
    'temperature': temperatureC,
    'humidity': humidityPct,
    'co2': co2Ppm,
    'voc': vocMgM3,
    'noise': noiseDb,
    'pm25': pm25UgM3,
    'pm10': pm10UgM3,
  };
}

class CattleDevice {
  final String id;
  final String name;

  const CattleDevice({required this.id, required this.name});

  factory CattleDevice.fromJson(Map<String, dynamic> json) {
    return CattleDevice(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}
