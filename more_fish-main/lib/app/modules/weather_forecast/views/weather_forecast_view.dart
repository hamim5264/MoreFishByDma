import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import '../../../common_widgets/common_text.dart';
import '../controllers/weather_forecast_controller.dart';

class WeatherForecastView extends GetView<WeatherForecastController> {
  const WeatherForecastView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffcbffff),
        title: const Text(
          'Weather Forecast',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffddf1fb), Colors.white],
          ),
        ),
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchableDropdown(context, textEditingController),
                const SizedBox(height: 20),
                if (controller.isLoading.value)
                  const Center(child: CircularProgressIndicator())
                else if (controller.errorMessage.isNotEmpty)
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 10),
                        CommonText(
                          controller.errorMessage.value,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                        ElevatedButton(
                          onPressed: () => controller.fetchWeatherData(
                            controller.selectedLocation.value,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (controller.weatherData.isNotEmpty)
                  _buildWeatherContent()
                else
                  const Center(child: Text('No data available')),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchableDropdown(
    BuildContext context,
    TextEditingController textEditingController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Select District',
            style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor),
          ),
          items: controller.locations
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 16)),
                ),
              )
              .toList(),
          value: controller.selectedLocation.value,
          onChanged: (value) {
            if (value != null) {
              controller.selectedLocation.value = value;
              controller.fetchWeatherData(value);
            }
          },
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 50,
            width: double.infinity,
          ),
          dropdownStyleData: const DropdownStyleData(maxHeight: 400),
          menuItemStyleData: const MenuItemStyleData(height: 45),
          dropdownSearchData: DropdownSearchData(
            searchController: textEditingController,
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Container(
              height: 50,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                expands: true,
                maxLines: null,
                controller: textEditingController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  hintText: 'Search for a district...',
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return item.value.toString().toLowerCase().contains(
                searchValue.toLowerCase(),
              );
            },
          ),
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              textEditingController.clear();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final weather = controller.weatherData;
    final temp = weather['main']['temp'].toDouble();
    final humidity = weather['main']['humidity'];
    final windSpeed = weather['wind']['speed'];
    final pressure = weather['main']['pressure'];
    final description = weather['weather'][0]['description'];
    final icon = weather['weather'][0]['icon'];
    final city = weather['name'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        glassCard(
          child: Column(
            children: [
              CommonText(
                city,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xff87CEEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.network(
                  "https://openweathermap.org/img/wn/$icon@4x.png",
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.wb_sunny,
                    size: 60,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CommonText(
                "$temp°C",
                fontSize: 44,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              const SizedBox(height: 6),
              CommonText(
                description.toString().capitalizeFirst ?? '',
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const CommonText(
          "Hourly Forecast",
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.forecastData.length > 8
                ? 8
                : controller.forecastData.length,
            itemBuilder: (context, index) {
              final forecast = controller.forecastData[index];
              final fTemp = forecast['main']['temp'].toDouble();
              final fIcon = forecast['weather'][0]['icon'];
              final fTime = DateTime.parse(forecast['dt_txt']);
              final formattedTime = DateFormat('ha').format(fTime);

              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonText(
                      formattedTime,
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Image.network(
                      "https://openweathermap.org/img/wn/$fIcon.png",
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.wb_cloudy, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    CommonText(
                      "$fTemp°C",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            infoCard("Humidity", "$humidity%", Icons.water_drop),
            infoCard("Wind", "$windSpeed m/s", Icons.air),
            infoCard("Pressure", "$pressure hPa", Icons.speed),
          ],
        ),
      ],
    );
  }

  Widget glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget infoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.blueAccent),
            const SizedBox(height: 10),
            CommonText(
              value,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 4),
            CommonText(label, fontSize: 14, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
