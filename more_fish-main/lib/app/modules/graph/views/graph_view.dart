import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../res/colors/colors.dart';
import '../controllers/graph_controller.dart';

class GraphView extends GetView<GraphController> {
  const GraphView({super.key});

  String _periodLabel(String period) {
    if (period == 'Daily') return 'Last 24 H';
    return period;
  }

  double _computePadding(double minValue, double maxValue) {
    final range = (maxValue - minValue).abs();
    if (range < 1.0) {
      return 0.5;
    }
    return range * 0.1;
  }

  double _computeYAxisInterval(
    double minY,
    double maxY, {
    required bool isMonthly,
  }) {
    final range = (maxY - minY).abs();
    if (range <= 0) {
      return 1.0;
    }

    final targetTicks = isMonthly ? 5.0 : 6.0;
    final roughInterval = range / targetTicks;
    final magnitude = math
        .pow(10, (math.log(roughInterval) / math.ln10).floor())
        .toDouble();
    final residual = roughInterval / magnitude;

    double niceMultiplier;
    if (residual <= 1) {
      niceMultiplier = 1;
    } else if (residual <= 2) {
      niceMultiplier = 2;
    } else if (residual <= 5) {
      niceMultiplier = 5;
    } else {
      niceMultiplier = 10;
    }

    return niceMultiplier * magnitude;
  }

  String _formatYAxisValue(double value, {required bool isMonthly}) {
    if (value.isNaN || value.isInfinite) return '0';
    final absValue = value.abs();

    if (absValue >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (absValue >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    if (isMonthly || absValue >= 100) {
      return value.toStringAsFixed(0);
    }
    if (absValue >= 10) {
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffd4fcfd),
        title: Text(
          controller.graphTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        actions: [
          Obx(
            () => PopupMenuButton<String>(
              initialValue: controller.selectedPeriod.value,
              onSelected: (value) {
                controller.selectedPeriod.value = value;
                controller.graphData(type: value.toLowerCase());
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Daily', child: Text('Last 24 H')),
                PopupMenuItem(value: 'Weekly', child: Text('Weekly')),
                PopupMenuItem(value: 'Monthly', child: Text('Monthly')),
                PopupMenuItem(value: 'Yearly', child: Text('Yearly')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      _periodLabel(controller.selectedPeriod.value),
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty &&
            controller.sensorValues.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.error.value.contains('TimeoutException')
                        ? 'The server is taking too long to respond. Please check your connection and try again.'
                        : controller.error.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.graphData(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.sensorValues.isEmpty) {
          return const Center(
            child: Text(
              'No graph data available',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        final sensorValues = controller.sensorValues;
        final timeLabels = controller.timeLabels;
        final minValue = sensorValues.reduce((a, b) => a < b ? a : b);
        final maxValue = sensorValues.reduce((a, b) => a > b ? a : b);
        final padding = _computePadding(minValue, maxValue);
        final minY = minValue - padding;
        final maxY = maxValue + padding;
        final isMonthly = controller.selectedPeriod.value == 'Monthly';
        final isWeekly = controller.selectedPeriod.value == 'Weekly';
        final isYearly = controller.selectedPeriod.value == 'Yearly';
        final yInterval = _computeYAxisInterval(
          minY,
          maxY,
          isMonthly: isMonthly || isYearly,
        );

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Time Period",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedPeriod.value,
                          items: const [
                            DropdownMenuItem(
                              value: 'Daily',
                              child: Text('Last 24 H'),
                            ),
                            DropdownMenuItem(
                              value: 'Weekly',
                              child: Text('Weekly'),
                            ),
                            DropdownMenuItem(
                              value: 'Monthly',
                              child: Text('Monthly'),
                            ),
                            DropdownMenuItem(
                              value: 'Yearly',
                              child: Text('Yearly'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedPeriod.value = value;
                              controller.graphData(type: value.toLowerCase());
                            }
                          },
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          dropdownColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 24, 20, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) =>
                              AppColors.primary.withValues(alpha: 0.9),
                          tooltipRoundedRadius: 8,
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              return LineTooltipItem(
                                touchedSpot.y.toStringAsFixed(2),
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        getTouchedSpotIndicator:
                            (LineChartBarData barData, List<int> spotIndexes) {
                              return spotIndexes.map((spotIndex) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    strokeWidth: 2,
                                    dashArray: [5, 5],
                                  ),
                                  FlDotData(
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 6,
                                            color: AppColors.primary,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                  ),
                                );
                              }).toList();
                            },
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: yInterval,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: (isWeekly || isYearly)
                                ? 1
                                : (sensorValues.length / 5)
                                      .floorToDouble()
                                      .clamp(1, 10),
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < timeLabels.length) {
                                final label = timeLabels[index].trim();
                                if (label.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8,
                                  child: Transform.rotate(
                                    angle: -0.5,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: (isMonthly || isYearly) ? 56 : 48,
                            interval: yInterval,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8,
                                child: Text(
                                  _formatYAxisValue(
                                    value,
                                    isMonthly: isMonthly || isYearly,
                                  ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          left: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          right: const BorderSide(color: Colors.transparent),
                          top: const BorderSide(color: Colors.transparent),
                        ),
                      ),
                      minY: minY,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            sensorValues.length,
                            (i) => FlSpot(i.toDouble(), sensorValues[i]),
                          ),
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: AppColors.primary,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: sensorValues.length < 30,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: AppColors.primary,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.3),
                                AppColors.primary.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Tip: Long press on the graph to see exact values",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
