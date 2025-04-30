import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/home/home_chart_data_model.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class HomeChart extends StatefulWidget {
  final HomeChartDataModel homeChartData;
  HomeChart({Key? key, required this.homeChartData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeChartState();
}

class HomeChartState extends State<HomeChart> {
  BranchResponse? branchResponseData;
  List<String> nameBranch = [];
  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponseData =
          BranchResponse.fromJson(jsonDecode(branchResponseJson));
      for (int i = 0; i < branchResponseData!.branchs.length; i++) {
        nameBranch.add(branchResponseData!.branchs[i].branchName);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    getBranchKango();
    // Thêm đoạn print này để debug
    print("Categories: ${widget.homeChartData.data.categories}");
    print(
        "Series data: ${widget.homeChartData.data.series.map((s) => s.data)}");
    super.initState();
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    String text;
    int index = value.toInt();

    // Khi categories rỗng, sử dụng nameBranch làm nhãn trục X
    if (widget.homeChartData.data.categories.isEmpty) {
      if (index >= 0 && index < nameBranch.length) {
        text = nameBranch[index];
      } else {
        text = '';
      }
    } else if (index >= 0 &&
        index < widget.homeChartData.data.categories.length) {
      text = widget.homeChartData.data.categories[index];
    } else {
      text = '';
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 0,
      child: SizedBox(
        width: 30.w,
        child: TextApp(
          text: text,
          fontsize: 10.sp,
        ),
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    // Only show whole numbers
    if (value % 1 != 0) return Container();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10, // Add some spacing
      child: TextApp(
        text: value.toInt().toString(),
        fontsize: 12.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (branchResponseData != null &&
            branchResponseData!.branchs.isNotEmpty)
          buildLegend(),
        // widget.homeChartData.data.categories.isEmpty
        //     ? const NoDataFoundWidget()
        AspectRatio(
          aspectRatio: 1.5,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final barWidth = screenWidth /
                    (max(widget.homeChartData.data.categories.length, 1) *
                        2); // Đảm bảo không chia cho 0
                final groupSpace = screenWidth /
                    (max(widget.homeChartData.data.categories.length, 1) *
                        4); // Đảm bảo không chia cho 0
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.center,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipMargin: 0,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.toInt().toString(),
                            TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: bottomTitles,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // Increased from 30
                          getTitlesWidget: leftTitles,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      checkToShowHorizontalLine: (value) =>
                          value % 1 == 0, // Show lines for whole numbers
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.grey.withOpacity(0.5)),
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
                      ),
                    ),
                    minY: 0, // Start from 0
                    maxY: widget.homeChartData.data.series.isEmpty ||
                            widget.homeChartData.data.categories.isEmpty
                        ? 10
                        : widget.homeChartData.data.series
                                .map((s) => s.data.reduce((a, b) => a + b))
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                    groupsSpace: groupSpace,
                    barGroups: getData(barWidth),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> getData(double barWidth) {
    final categories = widget.homeChartData.data.categories;
    final series = widget.homeChartData.data.series;

    print("Creating bars for categories: $categories");
    print("With series data: ${series.map((s) => s.data)}");

    if (categories.isEmpty || series.isEmpty) {
      return [];
    }

    return [
      for (var i = 0; i < categories.length; i++)
        BarChartGroupData(
          x: i,
          barsSpace:
              barWidth * 0.2, // Add 20% of barWidth as space between bars
          barRods: [
            BarChartRodData(
              toY: series.map((serie) => serie.data[i]).fold<double>(
                    0,
                    (sum, item) => sum + item.toDouble(),
                  ),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4)), // Round top corners
              width: barWidth,
              color: Colors.transparent,
              rodStackItems: [
                for (var j = 0; j < series.length; j++)
                  BarChartRodStackItem(
                    j == 0
                        ? 0
                        : series
                            .map((serie) => serie.data[i])
                            .take(j)
                            .fold<double>(
                              0,
                              (sum, item) => sum + item.toDouble(),
                            ),
                    series
                        .map((serie) => serie.data[i])
                        .take(j + 1)
                        .fold<double>(
                          0,
                          (sum, item) => sum + item.toDouble(),
                        ),
                    getColorForSeries(series[j].name),
                  ),
              ],
            ),
          ],
        ),
    ];
  }

  final Color dark = Color(0xFF007D88);
  final Color normal = Color(0xFF007D88).withOpacity(0.5);
  final Color light = Color(0xFF007D88).withOpacity(0.1);

  Color getColorForSeries(String seriesName) {
    int index = nameBranch.indexOf(seriesName);

    if (index == 0) {
      return dark;
    } else if (index == 1) {
      return normal;
    } else if (index == 2) {
      return light;
    } else if (index >= 3) {
      return getRandomColor();
    } else {
      return Colors.grey; // Default color if seriesName not found
    }
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Widget buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: [
          for (var i = 0; i < nameBranch.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  color: i == 0
                      ? dark
                      : i == 1
                          ? normal
                          : i == 2
                              ? light
                              : getRandomColor(),
                ),
                SizedBox(width: 4),
                Text(nameBranch[i]),
              ],
            ),
        ],
      ),
    );
  }
}
