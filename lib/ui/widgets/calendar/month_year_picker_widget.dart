import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// Create a new widget for Month-Year picker
class MonthYearPickerWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(DateTime firstDay, DateTime lastDay) onDateSelected;
  final String hintText;
  final String labelText;

  const MonthYearPickerWidget({
    required this.controller,
    required this.onDateSelected,
    this.hintText = 'MM/yyyy',
    this.labelText = 'Chọn tháng',
    Key? key,
  }) : super(key: key);

  @override
  State<MonthYearPickerWidget> createState() => _MonthYearPickerWidgetState();
}

class _MonthYearPickerWidgetState extends State<MonthYearPickerWidget> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10.h),
        TextField(
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          readOnly: true,
          controller: widget.controller,
          onTap: () {
            _showMonthYearPicker(context);
          },
          style: TextStyle(fontSize: 14.sp, color: Colors.black),
          cursorColor: Colors.black,
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_month),
            fillColor: Theme.of(context).colorScheme.primary,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            hintText: widget.hintText,
            isDense: true,
            contentPadding: EdgeInsets.all(20.w),
          ),
        ),
      ],
    );
  }

  void _showMonthYearPicker(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _showMaterialMonthPicker(context);
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _showCupertinoMonthPicker(context);
        break;
    }
  }

  void _showMaterialMonthPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chọn thời gian',
            style: TextStyle(fontSize: 18.sp),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: YearMonthPickerWidget(
              initialDate: _selectedDate ?? DateTime.now(),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                if (_selectedDate != null) {
                  _updateSelectedDate(_selectedDate!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCupertinoMonthPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Hủy'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  CupertinoButton(
                    child: const Text('Xác nhận'),
                    onPressed: () {
                      if (_selectedDate != null) {
                        _updateSelectedDate(_selectedDate!);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: _selectedDate ?? DateTime.now(),
                  mode: CupertinoDatePickerMode.date,
                  dateOrder: DatePickerDateOrder.dmy,
                  onDateTimeChanged: (DateTime dateTime) {
                    setState(() {
                      _selectedDate = dateTime;
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateSelectedDate(DateTime date) {
    // Calculate first and last day of selected month
    DateTime firstDay = DateTime(date.year, date.month, 1);
    DateTime lastDay = DateTime(date.year, date.month + 1, 0);

    // Format text for display
    String formattedText = DateFormat('MM/yyyy').format(date);
    widget.controller.text = formattedText;

    // Call callback with first and last day
    widget.onDateSelected(firstDay, lastDay);
  }
}

// Custom Year-Month picker widget for Material design
class YearMonthPickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;

  const YearMonthPickerWidget({
    required this.initialDate,
    required this.onDateChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<YearMonthPickerWidget> createState() => _YearMonthPickerWidgetState();
}

class _YearMonthPickerWidgetState extends State<YearMonthPickerWidget> {
  late int _selectedYear;
  late int _selectedMonth;
  final List<String> _months = [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Year selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                setState(() {
                  _selectedYear--;
                  _updateSelectedDate();
                });
              },
            ),
            Text(
              '$_selectedYear',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: () {
                setState(() {
                  _selectedYear++;
                  _updateSelectedDate();
                });
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        // Month grid
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final isSelected = month == _selectedMonth;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedMonth = month;
                    _updateSelectedDate();
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _months[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _updateSelectedDate() {
    final selectedDate = DateTime(_selectedYear, _selectedMonth, 1);
    widget.onDateChanged(selectedDate);
  }
}
