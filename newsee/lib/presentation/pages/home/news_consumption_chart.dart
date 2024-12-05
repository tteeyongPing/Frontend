import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NewsConsumptionChart extends StatelessWidget {
  final List<int> dailyCounts;
  final List<String> dates;
  final ScrollController scrollController;

  const NewsConsumptionChart({
    super.key,
    required this.dailyCounts,
    required this.dates,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16), // 전체 패딩을 줄임
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 750, // 그래프 가로 길이를 줄임
          height: 180, // 그래프 세로 길이를 줄임
          child: BarChart(
            BarChartData(
              barGroups: List.generate(
                dailyCounts.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: dailyCounts[index].toDouble(),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0038FF),
                          Color(0xFF4D71F6),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ), // 막대 그라데이션 적용
                      width: 15, // 막대의 폭을 줄임
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.8,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < dates.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            dates[value.toInt()],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black, // 축 텍스트 색상
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 20, // 아래 공간을 줄임
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: false, // 테두리 제거
              ),
              gridData: const FlGridData(
                show: false, // 격자선 제거
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(6),
                  fitInsideHorizontally: true, // 툴팁이 화면 바깥으로 나가지 않도록 설정
                  fitInsideVertically: true, // 툴팁이 화면 위/아래로 나가지 않도록 설정
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${dates[groupIndex]}: ${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
