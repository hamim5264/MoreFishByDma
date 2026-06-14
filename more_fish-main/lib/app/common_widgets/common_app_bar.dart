import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/cattle_index/controllers/cattle_header_controller.dart';
import '../service/local_storage.dart';
import 'common_text.dart';

class CommonAppBar extends StatelessWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    required this.cityName,
    this.logoAssetPath,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.date,
    this.time,
    this.humidity,
    this.temp,
    this.actions,
    this.leading,
    this.tempLabel,
    this.humidityLabel,
  });

  final String title;
  final String cityName;
  final String? logoAssetPath;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final String? date;
  final String? time;
  final String? temp;
  final String? humidity;
  final String? tempLabel;
  final String? humidityLabel;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<LoginTokenStorage>();

    return Obx(() {
      final bool loggedIn = storage.isCattleLoggedIn.value;

      String finalCityName = cityName;
      String? finalTemp = temp;
      String? finalHumidity = humidity;
      String? finalDescription;
      String? finalSunlight;

      if (loggedIn && Get.isRegistered<CattleHeaderController>()) {
        final cattleHeader = Get.find<CattleHeaderController>();
        if (cattleHeader.isUsingBackendData.value) {
          finalCityName = cattleHeader.district.value;
          finalTemp = cattleHeader.tempText.value;
          finalHumidity = cattleHeader.humidityText.value;
          finalDescription = cattleHeader.description.value;
          finalSunlight = cattleHeader.sunlight.value;
        }
      }

      // Reduced height and made it more compact
      const double minAppBarHeight = 110;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        constraints: const BoxConstraints(minHeight: minAppBarHeight),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xffd4fcfd),
          border: const Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Left side: Logo + Title + Date/Time + Language button
              Expanded(
                flex: 13,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leading ??
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            logoAssetPath ?? "assets/icons/logo_trade_mark.jpg",
                            height: 48,
                            width: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor ?? Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (date != null && date!.isNotEmpty)
                            Text(
                              date!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: textColor ?? Colors.black87,
                              ),
                            ),
                          if (time != null && time!.isNotEmpty)
                            Text(
                              time!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: textColor ?? Colors.black54,
                              ),
                            ),
                          const SizedBox(height: 4),
                          const _LanguageButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              // 🔹 Right side: Weather info
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: iconColor ?? Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            finalCityName.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor ?? Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CommonText(
                                tempLabel ?? 'air_temp'.tr,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: textColor ?? Colors.black54,
                              ),
                              CommonText(
                                finalTemp ?? '',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textColor ?? Colors.black87,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CommonText(
                                humidityLabel ?? 'humidity'.tr,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: textColor ?? Colors.black54,
                              ),
                              CommonText(
                                finalHumidity ?? '',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textColor ?? Colors.black87,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (finalDescription != null && finalDescription!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      CommonText(
                        finalDescription.tr,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                        maxLines: 1,
                      ),
                    ],
                    if (finalSunlight != null && finalSunlight!.isNotEmpty)
                      CommonText(
                        "${'sunlight'.tr}: ${finalSunlight.tr}",
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              if (actions != null && actions!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'bn') {
          Get.updateLocale(const Locale('bn', 'BD'));
          return;
        }
        Get.updateLocale(const Locale('en', 'US'));
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'en',
          child: Text('english'.tr),
        ),
        PopupMenuItem<String>(
          value: 'bn',
          child: Text('bangla'.tr),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      offset: const Offset(0, 30),
      child: Container(
        height: 24,
        width: 60,
        decoration: BoxDecoration(
          color: const Color(0xff8beeef),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.black12),
        ),
        child: Center(
          child: Text(
            (Get.locale?.languageCode ?? 'en') == 'bn' ? 'bangla'.tr : 'Eng',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
