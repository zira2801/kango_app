import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker extends StatefulWidget {
  final DateTime? initialDateTime;
  final Function(DateTime) onDateTimeSelected;

  const CustomDateTimePicker({
    Key? key,
    this.initialDateTime,
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  _CustomDateTimePickerState createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  late TextEditingController _datePickUpController;
  DateTime? dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = widget.initialDateTime;
    _datePickUpController = TextEditingController(
      text: dateTime != null ? formatDateTime(dateTime.toString()) : '',
    );
  }

  String formatDateTime(String date) {
    DateTime parseDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy HH:mm').format(parseDate);
  }

  Future<void> pickDateAndTime() async {
    DateTime? date;
    TimeOfDay? time;
    final now = DateTime.now();

    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        date = await showDatePicker(
          context: context,
          initialDate: dateTime ?? now,
          firstDate: now,
          lastDate: DateTime(now.year + 1),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
                dialogBackgroundColor: Colors.white,
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (date == null) return;

        time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                timePickerTheme: TimePickerThemeData(
                  backgroundColor: Colors.white,
                  hourMinuteTextColor: Theme.of(context).primaryColor,
                  dayPeriodTextColor: Theme.of(context).primaryColor,
                  dialHandColor: Theme.of(context).primaryColor,
                  dialBackgroundColor: Colors.grey.shade200,
                ),
              ),
              child: child!,
            );
          },
        );
        break;

      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        await showCupertinoModalPopup(
          context: context,
          builder: (context) => Container(
            height: 300,
            color: CupertinoColors.systemBackground,
            child: CupertinoDatePicker(
              initialDateTime: dateTime ?? now,
              minimumDate: now,
              maximumDate: DateTime(now.year + 1),
              mode: CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (DateTime newDateTime) {
                date = newDateTime;
                time = TimeOfDay(
                    hour: newDateTime.hour, minute: newDateTime.minute);
              },
            ),
          ),
        );
        break;
    }

    if (date != null && time != null) {
      final newDateTime = DateTime(
        date!.year,
        date!.month,
        date!.day,
        time!.hour,
        time!.minute,
      );

      setState(() {
        dateTime = newDateTime;
        _datePickUpController.text = formatDateTime(newDateTime.toString());
      });

      widget.onDateTimeSelected(newDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn ngày và giờ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: pickDateAndTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _datePickUpController.text.isEmpty
                          ? 'Chọn ngày và giờ'
                          : _datePickUpController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: _datePickUpController.text.isEmpty
                            ? Colors.grey.shade600
                            : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _datePickUpController.dispose();
    super.dispose();
  }
}
