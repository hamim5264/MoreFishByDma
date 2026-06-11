import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../service/service.dart';


class WeatherForecastController extends GetxController {
  final String apiKey = ApiService.apiKey;
  var weatherData = {}.obs;
  var forecastData = <dynamic>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final List<String> locations = [
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Rangpur',
    'Mymensingh',
    'Gazipur',
    'Narayanganj',
    'Comilla',
  ];

  var selectedLocation = 'Dhaka'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData(selectedLocation.value);
  }

  Future<void> fetchWeatherData(String city) async {
    isLoading.value = true;
    errorMessage.value = '';
    weatherData.clear();
    forecastData.clear();

    try {
      // Fetch Current Weather
      final weatherUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric');
      final weatherResponse = await http.get(weatherUrl);

      // Fetch 5-day / 3-hour Forecast
      final forecastUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric');
      final forecastResponse = await http.get(forecastUrl);

      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        weatherData.value = json.decode(weatherResponse.body);
        var forecastJson = json.decode(forecastResponse.body);
        forecastData.value = forecastJson['list'] ?? [];
      } else {
        errorMessage.value = 'Failed to load weather data';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Check your internet.';
    } finally {
      isLoading.value = false;
    }
  }





}
