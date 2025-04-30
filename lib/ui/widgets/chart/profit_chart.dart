import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:scan_barcode_app/data/models/sale_manager/home_sale_manager.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ProfitRevenueChart extends StatelessWidget {
  final Charts chartData;

  const ProfitRevenueChart({Key? key, required this.chartData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                maxY: getMaxY(),
                minY: getMinY(),
                alignment: BarChartAlignment.center,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipMargin: 8,
                    tooltipPadding: const EdgeInsets.all(12),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    direction: TooltipDirection.bottom,
                    getTooltipColor: (group) => Colors.black87,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String month = chartData.month[group.x.toInt()];
                      String label;
                      String value;
                      Color dotColor; // Color for the dot
                      if (rodIndex == 0) {
                        label = 'Doanh thu';
                        value =
                            _formatCurrency(chartData.price[group.x.toInt()]);
                        dotColor = Colors
                            .blue.shade400; // Match bar color for Doanh thu
                      } else {
                        label = 'Lợi nhuận';
                        value =
                            _formatCurrency(chartData.profit[group.x.toInt()]);
                        dotColor = const Color.fromRGBO(
                            0, 227, 150, 0.7); // Match bar color for Lợi nhuận
                      }
                      return BarTooltipItem(
                        month,
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: '\n', // Add spacing before the bullet
                          ),
                          // Custom bullet (dot) using a TextSpan with a special character
                          TextSpan(
                            text: '• ',
                            style: TextStyle(
                              color: dotColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '$label: ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '\n$value vnd',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: TextApp(
                            text: chartData.month[value.toInt()],
                            fontsize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value == meta.min || value == meta.max) {
                          return const SizedBox.shrink();
                        }
                        final intValue = value.toInt();
                        String formattedValue = _formatNumber(intValue);
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: TextApp(
                            text: formattedValue,
                            fontsize: 8,
                          ),
                        );
                      },
                      reservedSize: 60,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: () {
                    double interval = (getMaxY() - getMinY()) / 5;
                    return interval <= 0
                        ? 1.0
                        : interval.toDouble(); // Đảm bảo không bao giờ là 0
                  }(),
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 0.5,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: _getBarGroups(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue, 'Doanh thu'),
              const SizedBox(width: 24),
              _buildLegendItem(
                  const Color.fromRGBO(0, 227, 150, 1), 'Lợi nhuận'),
            ],
          ),
        ],
      ),
    );
  }

  double getMaxY() {
    double maxPrice = chartData.price.isNotEmpty
        ? chartData.price.reduce((a, b) => a > b ? a : b).toDouble()
        : 0;
    double maxProfit = chartData.profit.isNotEmpty
        ? chartData.profit.reduce((a, b) => a > b ? a : b).toDouble()
        : 0;
    double max = (maxPrice > maxProfit ? maxPrice : maxProfit);
    if (max <= 0) return 5; // Giá trị mặc định nếu không có dữ liệu
    return max * 1.1; // Giữ nguyên logic cũ
  }

  double getMinY() {
    double minPrice = chartData.price.isNotEmpty
        ? chartData.price.reduce((a, b) => a < b ? a : b).toDouble()
        : 0;
    double minProfit = chartData.profit.isNotEmpty
        ? chartData.profit.reduce((a, b) => a < b ? a : b).toDouble()
        : 0;
    double min = (minPrice < minProfit ? minPrice : minProfit);
    return min >= 0
        ? 0
        : min * 1.1; // Đảm bảo minY luôn bắt đầu từ 0 nếu không âm
  }

  String _formatNumber(int value) {
    String text = value.toString();
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    text = text.replaceAllMapped(regExp, (Match m) => '${m[1]}.');
    return text;
  }

  List<BarChartGroupData> _getBarGroups() {
    List<BarChartGroupData> barGroups = [];
    double barWidth = (200 / chartData.month.length).clamp(20, 40);

    barWidth = barWidth.clamp(20, 40);

    for (var i = 0; i < chartData.month.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: chartData.price[i].toDouble(),
              color: Colors.blue,
              width: barWidth,
              borderRadius: BorderRadius.zero,
            ),
            BarChartRodData(
              toY: chartData.profit[i].toDouble(),
              color: const Color.fromRGBO(0, 227, 150, 1),
              width: barWidth,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
