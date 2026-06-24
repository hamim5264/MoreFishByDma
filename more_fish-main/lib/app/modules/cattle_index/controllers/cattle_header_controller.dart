import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../service/service.dart';
import '../../../response/cattle_farrm_dashboard_response.dart';
import '../../../service/local_storage.dart';

class CattleHeaderController extends GetxController {
  final formattedDate = ''.obs;
  final formattedTime = ''.obs;

  final tempText = ''.obs;
  final humidityText = ''.obs;
  final district = 'Dhaka'.obs;
  final description = ''.obs;
  final sunlight = ''.obs;

  final isLoadingWeather = false.obs;
  final weatherError = ''.obs;
  final isUsingBackendData = false.obs;

  Timer? _timer;
  String _lastRoute = '';

  // Track the active "dashboard" module (Cattle, Poultry, MoreFish, Pharma)
  final activeModule = 'more_fish'.obs; // Default

  // Cache to prevent flickering and excessive OWM calls
  String _lastCityFetched = '';
  DateTime? _lastOWMFetch;

  final String _apiKey = ApiService.apiKey;
  final String city = 'dhaka';

  @override
  void onInit() {
    super.onInit();

    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    Future.delayed(const Duration(milliseconds: 300), () {
      refreshWeather();
    });
  }

  void _tick() {
    final now = DateTime.now();
    formattedDate.value = DateFormat('d-MMM-yyyy').format(now);
    formattedTime.value = DateFormat('h:mm:ss a').format(now);

    final currentRoute = Get.currentRoute.toLowerCase();
    if (currentRoute != _lastRoute) {
      log(
        "Route changed from '$_lastRoute' to '$currentRoute'. Refreshing weather...",
      );

      if (currentRoute.contains('cattle')) {
        activeModule.value = 'cattle';
      } else if (currentRoute.contains('poultry')) {
        activeModule.value = 'poultry';
      } else if (currentRoute.contains('pharma') ||
          currentRoute.contains('clean_air')) {
        activeModule.value = 'pharma';
      } else if (currentRoute.contains('more_fish') ||
          currentRoute.contains('index') ||
          currentRoute.contains('home')) {
        activeModule.value = 'more_fish';
      }

      _lastRoute = currentRoute;
      refreshWeather();
    }
  }

  void updateFromDashboard(Weather? weather) {
    final route = Get.currentRoute.toLowerCase();
    if (!route.contains('cattle')) {
      return;
    }

    if (weather == null) {
      if (isUsingBackendData.value) {
        log("Cattle Dashboard weather is null. Falling back to Dhaka default.");
        fetchWeatherData(city);
      }
      return;
    }

    final newDistrict = weather.weatherDistrict?.district ?? 'Dhaka';
    final newTemp = "${weather.weatherTemperature}°C";

    if (district.value != newDistrict || tempText.value != newTemp) {
      isUsingBackendData.value = true;
      district.value = newDistrict;
      description.value = weather.weatherDescription ?? '';
      sunlight.value = weather.sunlightLevel ?? '';
      tempText.value = newTemp;
      humidityText.value = "${weather.weatherHumidity}%";
      log(
        "Header updated from Cattle Dashboard: ${district.value}, ${tempText.value}",
      );
    }
  }

  Future<void> refreshWeather({String? overrideId}) async {
    final storage = Get.find<LoginTokenStorage>();

    bool loggedIn =
        storage.hasValidCattleToken() ||
        storage.hasValidPoultryToken() ||
        storage.hasValidMoreFishToken() ||
        storage.hasValidPharmaToken();

    storage.isCattleLoggedIn.value = loggedIn;

    if (!loggedIn) {
      log("NO-LOGIN: Using Dhaka defaults.");
      await fetchWeatherData(city);
      return;
    }

    final route = Get.currentRoute.toLowerCase();
    String? listUrl;
    String? dashboardUrlPrefix;
    String? token;

    if (route.contains('cattle')) {
      token = storage.getCattleToken();
      if (token != null) {
        listUrl = "${ApiService.baseUrl}/cattle_care/farms/list/";
        dashboardUrlPrefix =
            "${ApiService.baseUrl}/cattle_care/farms/dashboard/?farm_id=";
      }
    } else if (route.contains('poultry')) {
      token = storage.getPoultryToken();
      if (token != null) {
        listUrl = "${ApiService.baseUrl}/poultry_care/farms/list/";
        dashboardUrlPrefix =
            "${ApiService.baseUrl}/poultry_care/farms/dashboard/?farm_id=";
      }
    } else if (route.contains('more') ||
        route.contains('pharma') ||
        route.contains('index') ||
        route.contains('pond') ||
        route.contains('water')) {
      final bool isPharma = route.contains('pharma');
      token = isPharma ? storage.getPharmaToken() : storage.getMoreFishToken();
      if (token != null) {
        listUrl = "${ApiService.baseUrl}/devices/data/pond/list";
        dashboardUrlPrefix =
            "${ApiService.baseUrl}/devices/data/pond/data?asset_id=";
      }
    }

    if (token != null && dashboardUrlPrefix != null) {
      if (overrideId != null) {
        log("Fetching backend weather with override ID: $overrideId");
        await _fetchBackendWeather("$dashboardUrlPrefix$overrideId", token);
      } else if (listUrl != null) {
        log("Refreshing backend weather from list: $listUrl");
        await _fetchFromList(listUrl, dashboardUrlPrefix, token);
      }
    } else {
      log(
        "Route '$route' not mapped to weather backend. Falling back to Dhaka.",
      );
      await fetchWeatherData(city);
    }
  }

  Future<void> _fetchFromList(
    String listUrl,
    String dashboardUrlPrefix,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(listUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        final List? dataList = jsonMap['data'];

        if (dataList != null && dataList.isNotEmpty) {
          final id = dataList[0]['id'];
          await _fetchBackendWeather("$dashboardUrlPrefix$id", token);
          return;
        }
      }
    } catch (e) {
      log("List API Error: $e");
    }

    isUsingBackendData.value = false;
    await fetchWeatherData(city);
  }

  Future<void> _fetchBackendWeather(String url, String token) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        final data = jsonMap['data'];
        final weatherData = data != null ? data['weather'] : null;

        if (weatherData != null) {
          isUsingBackendData.value = true;
          district.value =
              weatherData['weather_district']?['district'] ?? 'Dhaka';
          description.value = weatherData['weather_description'] ?? '';
          sunlight.value = weatherData['sunlight_level'] ?? '';

          final temp = weatherData['weather_temperature'];
          final hum = weatherData['weather_humidity'];

          tempText.value = temp != null ? "$temp°C" : "";
          humidityText.value = hum != null ? "$hum%" : "";
          log("Weather Updated: ${district.value}, ${tempText.value}");
          return;
        } else {
          log("Backend weather node is null. Falling back to Dhaka.");
        }
      }
    } catch (e) {
      log("Backend weather error: $e");
    }

    isUsingBackendData.value = false;
    await fetchWeatherData(city);
  }

  Future<void> fetchWeatherData(String city) async {
    if (_lastCityFetched == city && _lastOWMFetch != null) {
      if (DateTime.now().difference(_lastOWMFetch!) <
          const Duration(minutes: 5)) {
        return;
      }
    }

    isLoadingWeather.value = true;
    weatherError.value = '';
    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body) as Map<String, dynamic>;
        final main = (jsonMap['main'] as Map?) ?? {};
        final weatherArr = (jsonMap['weather'] as List?) ?? [];

        final t = main['temp'];
        final h = main['humidity'];

        tempText.value = t == null ? '' : '${(t as num).toStringAsFixed(2)}°C';
        humidityText.value = h == null ? '' : '${h.toString()}%';

        if (weatherArr.isNotEmpty) {
          description.value = weatherArr[0]['description'] ?? '';
        } else {
          description.value = '';
        }
        district.value = city.capitalizeFirst ?? city;
        sunlight.value = '';
        isUsingBackendData.value = false;

        _lastCityFetched = city;
        _lastOWMFetch = DateTime.now();
        log("OWM Fallback Success: $city, ${tempText.value}");
      }
    } catch (e) {
      log("OWM Error: $e");
    } finally {
      isLoadingWeather.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
