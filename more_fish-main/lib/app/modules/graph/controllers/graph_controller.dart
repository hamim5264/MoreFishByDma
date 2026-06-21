import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:more_fish/app/service/local_storage.dart';
import 'package:more_fish/app/response/graph_response.dart';
import '../../../repo/devices_repo.dart';
import '../../../service/service.dart';

class GraphController extends GetxController {
  static const String _fallbackPoultryToken =
      '21067c389d5d27d6ecfd22dc13e0ccb792714ad6';

  DevicesRepository devicesRepository = DevicesRepository();
  final graphResponse = Rxn<GraphResponse>();

  var sensorValues = <double>[].obs;
  var timeLabels = <String>[].obs;
  final isLoading = false.obs;
  final hasLoaded = false.obs;
  final error = ''.obs;

  var comId;
  var assetId;
  var sensorId;
  var type;
  int? farmId;
  String sensorKey = '';
  String sensorName = '';
  String sensorUnit = '';
  bool isPoultryFlow = false;
  bool isCattleFlow = false;
  bool isPharmaFlow = false;

  var selectedPeriod = 'Daily'.obs;

  String get graphTitle {
    if (isPoultryFlow || isCattleFlow) {
      if (sensorName.trim().isNotEmpty) {
        return sensorName;
      }
      if (sensorKey.trim().isNotEmpty) {
        return _toTitleCase(sensorKey);
      }
      return 'Graph';
    }

    final id = sensorId?.toString();
    if (id == '1') return 'pH';
    if (id == '2') return 'Temperature';
    if (id == '3') return 'DO';
    if (id == '4') return 'TDS';
    if (id == '5') return 'NH3';
    if (id == '6') return 'Salinity';
    return 'Graph';
  }

  @override
  void onInit() {
    super.onInit();
    _readArguments();
    graphData();
  }

  Future<void> graphData({String? type}) async {
    final requestedType = (type ?? _initialType()).toLowerCase();
    selectedPeriod.value = _capitalize(requestedType);
    isLoading.value = true;
    error.value = '';

    // loader removed
    debugPrint(
      'Graph loading start: flow=${isPoultryFlow ? 'poultry' : 'default'} type=$requestedType',
    );

    try {
      if (isPoultryFlow) {
        await _loadPoultryGraph(type: requestedType);
      } else if (isCattleFlow) {
        await _loadCattleGraph(type: requestedType);
      } else {
        await _loadDefaultGraph(type: requestedType);
      }
      hasLoaded.value = true;
    } catch (e) {
      error.value = e.toString();
      debugPrint('Graph loading error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _readArguments() {
    final args = Get.arguments;
    debugPrint('GraphController args: $args');
    if (args is! Map) {
      return;
    }

    final map = Map<String, dynamic>.from(args);
    final flow = map['flow']?.toString().toLowerCase();
    isPoultryFlow = flow == 'poultry';
    isCattleFlow = flow == 'cattle';
    isPharmaFlow = flow == 'pharma';

    if (isPoultryFlow || isCattleFlow) {
      farmId = int.tryParse('${map['farmId']}');
      sensorKey = (map['sensorKey'] ?? '').toString().trim();
      sensorName = (map['sensorName'] ?? '').toString().trim();
      sensorUnit = (map['unit'] ?? '').toString().trim();
      type = (map['type'] ?? 'daily').toString().trim().toLowerCase();
      return;
    }

    if (isPharmaFlow) {
      comId = map['comId'] ?? map['companyId'] ?? 39;
      assetId = map['assetId']?.toString() ?? map['assst_id']?.toString();
      sensorId = map['sensorId']?.toString() ?? map['sensor_id']?.toString();
      type = (map['type'] ?? 'daily')?.toString();
      debugPrint(
        'GraphController normalized pharma -> comId:$comId assetId:$assetId sensorId:$sensorId type:$type',
      );
      return;
    }

    // Normalize argument names and types
    comId = map['comId'] ?? map['companyId'] ?? 39;
    assetId = map['assetId']?.toString() ?? map['assst_id']?.toString();
    sensorId = map['sensorId']?.toString() ?? map['sensor_id']?.toString();
    type = (map['type'] ?? 'daily')?.toString();
    debugPrint(
      'GraphController normalized -> comId:$comId assetId:$assetId sensorId:$sensorId type:$type',
    );
  }

  String _initialType() {
    final fromArgs = type?.toString().trim().toLowerCase();
    if (fromArgs == 'daily' ||
        fromArgs == 'weekly' ||
        fromArgs == 'monthly' ||
        fromArgs == 'yearly') {
      return fromArgs!;
    }
    return 'daily';
  }

  Future<void> _loadDefaultGraph({required String type}) async {
    debugPrint('====================================');
    debugPrint('API CALL: GET Graph Data (More Fish/Pharma)');
    debugPrint('Asset ID: $assetId');
    debugPrint('Sensor ID: $sensorId');
    debugPrint('Period Type: $type');
    debugPrint('====================================');

    final response = await devicesRepository.getGraphData(
      comId: comId ?? 39,
      assetId: assetId,
      sensorId: sensorId,
      type: type,
      isPharmaFlow: isPharmaFlow,
    );

    response.fold(
      (l) {
        debugPrint('GRAPH API ERROR: ${l.message}');
        error.value = 'Failed to fetch graph: ${l.message}';
        debugPrint('Graph repo failure: ${l.message}');
        sensorValues.clear();
        timeLabels.clear();
      },
      (r) {
        debugPrint('GRAPH API SUCCESS');
        debugPrint('RESPONSE BODY: ${r.toRawJson()}');
        graphResponse.value = r;
        _applyChartData(r);
      },
    );
  }

  Future<void> _loadPoultryGraph({required String type}) async {
    if (farmId == null || sensorKey.isEmpty) {
      throw Exception('Missing farm_id or sensor_key for poultry graph.');
    }

    final token = _getPoultryToken();
    final uri = Uri.parse(
      '${ApiService.poultryBaseUrl}/poultry_care/data/graph/?farm_id=$farmId&sensor_key=$sensorKey&type=$type',
    );

    await _fetchGraphAndApply(uri, token, 'Poultry');
  }

  Future<void> _loadCattleGraph({required String type}) async {
    if (farmId == null || sensorKey.isEmpty) {
      throw Exception('Missing farm_id or sensor_key for cattle graph.');
    }

    final token = _getCattleToken();
    final uri = Uri.parse(
      '${ApiService.baseUrl}/cattle_care/data/graph/?farm_id=$farmId&sensor_key=$sensorKey&type=$type',
    );

    await _fetchGraphAndApply(uri, token, 'Cattle');
  }

  Future<void> _fetchGraphAndApply(Uri uri, String token, String flowName) async {
    debugPrint('====================================');
    debugPrint('API CALL: GET $flowName Graph Data');
    debugPrint('URL: $uri');
    debugPrint('====================================');

    final client = http.Client();
    try {
      const int maxAttempts = 2;
      int attempt = 0;
      http.Response? response;

      while (attempt < maxAttempts) {
        attempt++;
        try {
          response = await client.get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ).timeout(const Duration(seconds: 20));
          break;
        } catch (e) {
          debugPrint('$flowName graph request error (attempt $attempt): $e');
          if (attempt >= maxAttempts) rethrow;
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (response == null) {
        throw Exception('No response from $flowName graph API');
      }

      debugPrint('$flowName graph status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('$flowName graph error body: ${response.body}');
        throw Exception(
          '$flowName graph API failed with status ${response.statusCode}',
        );
      }

      debugPrint('$flowName GRAPH API SUCCESS');
      debugPrint('RESPONSE BODY: ${response.body}');

      final parsed = GraphResponse.fromRawJson(response.body);
      graphResponse.value = parsed;
      _applyChartData(parsed);
    } finally {
      client.close();
    }
  }

  String _getPoultryToken() {
    if (Get.isRegistered<LoginTokenStorage>()) {
      final token = Get.find<LoginTokenStorage>().getPoultryToken();
      final normalized = token?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return _fallbackPoultryToken;
  }

  String _getCattleToken() {
    if (Get.isRegistered<LoginTokenStorage>()) {
      final token = Get.find<LoginTokenStorage>().getCattleToken();
      final normalized = token?.trim();
      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }
    return _fallbackPoultryToken; // Using poultry fallback as a generic one if cattle fails
  }

  void _applyChartData(GraphResponse response) {
    final dataList = response.data;
    if (dataList == null || dataList.isEmpty) {
      sensorValues.clear();
      timeLabels.clear();
      return;
    }

    final firstItem = dataList.first;
    final sensorVal = firstItem.sensorVal ?? const <String>[];
    final time = firstItem.time ?? const <String>[];

    sensorValues.value = sensorVal
        .map((e) => double.tryParse(e) ?? 0.0)
        .toList();
    timeLabels.value = List<String>.from(time);

    if ((isPoultryFlow || isCattleFlow) && sensorName.isEmpty) {
      sensorName = (firstItem.sensorName ?? '').toString();
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _toTitleCase(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }
}
