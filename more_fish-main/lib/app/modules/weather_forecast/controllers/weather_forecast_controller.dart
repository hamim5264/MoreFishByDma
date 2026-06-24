import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../service/service.dart';

class WeatherForecastController extends GetxController {
  final String apiKey = ApiService.apiKey;
  var weatherData = {}.obs;
  var forecastData = <dynamic>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final List<String> locations = [
    'Bagerhat',
    'Bandarban',
    'Barguna',
    'Barisal',
    'Bhola',
    'Bogra',
    'Brahmanbaria',
    'Chandpur',
    'Chapai Nawabganj',
    'Chittagong',
    'Chuadanga',
    'Comilla',
    'Cox\'s Bazar',
    'Dhaka',
    'Dinajpur',
    'Faridpur',
    'Feni',
    'Gaibandha',
    'Gazipur',
    'Gopalganj',
    'Habiganj',
    'Jamalpur',
    'Jessore',
    'Jhalokati',
    'Jhenaidah',
    'Joypurhat',
    'Khagrachhari',
    'Khulna',
    'Kishoreganj',
    'Kurigram',
    'Kushtia',
    'Lakshmipur',
    'Lalmonirhat',
    'Madaripur',
    'Magura',
    'Manikganj',
    'Meherpur',
    'Moulvibazar',
    'Munshiganj',
    'Mymensingh',
    'Naogaon',
    'Narail',
    'Narayanganj',
    'Narsingdi',
    'Natore',
    'Netrokona',
    'Nilphamari',
    'Noakhali',
    'Pabna',
    'Panchagarh',
    'Patuakhali',
    'Pirojpur',
    'Rajbari',
    'Rajshahi',
    'Rangamati',
    'Rangpur',
    'Satkhira',
    'Shariatpur',
    'Sherpur',
    'Sirajganj',
    'Sunamganj',
    'Sylhet',
    'Tangail',
    'Thakurgaon',
  ];

  var selectedLocation = 'Dhaka'.obs;
  static const String _storageKey = 'last_selected_district';

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null && locations.contains(saved)) {
      selectedLocation.value = saved;
    }
    fetchWeatherData(selectedLocation.value);
  }

  Future<void> _saveLocation(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, city);
  }

  Future<void> fetchWeatherData(String city) async {
    isLoading.value = true;
    errorMessage.value = '';
    weatherData.clear();
    forecastData.clear();

    try {
      String queryCity = city;
      if (city.toLowerCase().contains('chapainawabganj') ||
          city.toLowerCase().contains('chapai nawabganj')) {
        queryCity = "Nawabganj";
      }

      var weatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$queryCity,BD&appid=$apiKey&units=metric',
      );
      var weatherResponse = await http.get(weatherUrl);

      if (weatherResponse.statusCode != 200 && queryCity != city) {
        queryCity = city;
        weatherUrl = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$queryCity,BD&appid=$apiKey&units=metric',
        );
        weatherResponse = await http.get(weatherUrl);
      }

      final forecastUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$queryCity,BD&appid=$apiKey&units=metric',
      );
      final forecastResponse = await http.get(forecastUrl);

      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        weatherData.value = json.decode(weatherResponse.body);
        var forecastJson = json.decode(forecastResponse.body);
        forecastData.value = forecastJson['list'] ?? [];
        _saveLocation(city);
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
