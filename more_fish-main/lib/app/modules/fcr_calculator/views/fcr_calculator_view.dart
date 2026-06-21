import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../res/colors/colors.dart';
import '../controllers/fcr_calculator_controller.dart';

class FcrCalculatorView extends GetView<FcrCalculatorController> {
  const FcrCalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGround,
      appBar: AppBar(
        title: Text('fcr_calculator'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Obx(() {
              if (controller.ponds.isEmpty) return const SizedBox.shrink();
              return CommonContainer(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.assetId.value,
                    isExpanded: true,
                    onChanged: (val) {
                      if (val != null) {
                        final p = controller.ponds.firstWhere((e) => e.id == val);
                        controller.selectAsset(p.id, p.astName);
                      }
                    },
                    items: controller.ponds.map((p) {
                      return DropdownMenuItem<int>(
                        value: p.id,
                        child: Text(p.astName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
            CommonContainer(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    'feed_conversion_ratio'.tr,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 14),
                  _numberInputField(
                    controller: controller.feedAmountController,
                    label: 'total_feed_amount'.tr,
                  ),
                  const SizedBox(height: 12),
                  _numberInputField(
                    controller: controller.weightGainController,
                    label: 'total_weight_gain'.tr,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.calculateFcr,
                          child: Text('calculate'.tr),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.clearAll,
                          child: Text('clear'.tr),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.validationMessage.value.isNotEmpty) {
                      return Text(
                        controller.validationMessage.value.tr,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }

                    final value = controller.fcrResult.value;
                    if (value == null) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffe8f7ff),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xffb2dbef)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            'result'.tr,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(height: 4),
                          CommonText(
                            'FCR = ${value.toStringAsFixed(3)}',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff0370c3),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.fcrHistory.isEmpty &&
                  !controller.isLoadingHistory.value) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CommonText(
                      'fcr_trend'.tr,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (controller.isLoadingHistory.value)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.fcrHistory.isNotEmpty) ...[
                    _buildChart(),
                    const SizedBox(height: 20),
                    _buildHistoryList(),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final history = controller.fcrHistory;
    if (history.length < 2) return const SizedBox.shrink();

    final spots = history.asMap().entries.map((entry) {
      final record = entry.value;
      final double x = record.calculatedAt?.millisecondsSinceEpoch.toDouble() ?? 0;
      final double y = record.fcr ?? 0;
      return FlSpot(x, y);
    }).toList();

    double minX = spots.first.x;
    double maxX = spots.last.x;
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 0.5;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 0.5;

    return CommonContainer(
      height: 280,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY > 0 ? minY : 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: (maxX - minX) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.blue.withOpacity(0.1),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.blue.withOpacity(0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(date),
                      style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.blue.withOpacity(0.1)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xff0370c3),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: const Color(0xff0370c3),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff0370c3).withOpacity(0.3),
                    const Color(0xff0370c3).withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CommonText(
            'recent_calculations'.tr,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.fcrHistory.length,
          itemBuilder: (context, index) {
            final record = controller.fcrHistory.reversed.toList()[index];
            return CommonContainer(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            CommonText(
                              record.calculatedAt != null
                                  ? DateFormat('MMM d, yyyy h:mm a')
                                      .format(record.calculatedAt!)
                                  : '',
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        CommonText(
                          record.notes ?? 'Optional label',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        CommonText(
                          '${'feed'.tr}: ${record.feedWeightKg}kg | ${'gain'.tr}: ${record.weightGainedKg}kg',
                          fontSize: 12,
                          color: Colors.blueGrey,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xffe8f7ff),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CommonText(
                      'FCR: ${record.fcr?.toStringAsFixed(3)}',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff0370c3),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _numberInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
    );
  }
}
