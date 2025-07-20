import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CollectionChartWidget extends StatefulWidget {
  const CollectionChartWidget({super.key});

  @override
  State<CollectionChartWidget> createState() => _CollectionChartWidgetState();
}

class _CollectionChartWidgetState extends State<CollectionChartWidget> {
  int touchedIndex = -1;

  final List<Map<String, dynamic>> chartData = [
    {"month": "Jan", "amount": 45000.0, "color": Color(0xFF1B365D)},
    {"month": "Feb", "amount": 52000.0, "color": Color(0xFF4A90A4)},
    {"month": "Mar", "amount": 48000.0, "color": Color(0xFF6BA8BC)},
    {"month": "Apr", "amount": 61000.0, "color": Color(0xFF2D5A27)},
    {"month": "May", "amount": 58000.0, "color": Color(0xFF4A8A44)},
    {"month": "Jun", "amount": 67000.0, "color": Color(0xFF1B365D)},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
        width: double.infinity,
        height: 30.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
            color: AppTheme.getSurfaceVariant(isDark == false),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.getOutlineColor(isDark == false), width: 1)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Monthly Collections',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14.sp)),
            CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.getSuccessColor(isDark == false),
                size: 5.w),
          ]),
          SizedBox(height: 2.h),
          Expanded(
              child: Semantics(
                  label: "Monthly Collections Bar Chart",
                  child: BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 80000,
                      barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final month =
                                    chartData[group.x.toInt()]["month"];
                                final amount =
                                    chartData[group.x.toInt()]["amount"];
                                return BarTooltipItem(
                                    '$month\n\$${amount.toStringAsFixed(0)}',
                                    TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onInverseSurface,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11.sp));
                              }),
                          touchCallback:
                              (FlTouchEvent event, barTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  barTouchResponse == null ||
                                  barTouchResponse.spot == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  barTouchResponse.spot!.touchedBarGroupIndex;
                            });
                          }),
                      titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    final index = value.toInt();
                                    if (index >= 0 &&
                                        index < chartData.length) {
                                      return Padding(
                                          padding: EdgeInsets.only(top: 1.h),
                                          child: Text(chartData[index]["month"],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(fontSize: 10.sp)));
                                    }
                                    return Text('');
                                  },
                                  reservedSize: 3.h)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 12.w,
                                  interval: 20000,
                                  getTitlesWidget:
                                      (double value, TitleMeta meta) {
                                    return Text('\$${(value / 1000).toInt()}K',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: 9.sp));
                                  }))),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final isTouched = index == touchedIndex;

                        return BarChartGroupData(x: index, barRods: [
                          BarChartRodData(
                              toY: data["amount"],
                              color: isTouched
                                  ? (data["color"] as Color)
                                      .withValues(alpha: 0.8)
                                  : data["color"],
                              width: isTouched ? 6.w : 5.w,
                              borderRadius: BorderRadius.circular(2)),
                        ]);
                      }).toList(),
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 20000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                                color: AppTheme.getOutlineColor(isDark == false)
                                    .withValues(alpha: 0.3),
                                strokeWidth: 1);
                          }))))),
        ]));
  }
}
