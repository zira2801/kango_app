import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoDatePickerWidget extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onDateChanged;
  final Function() onCancel;
  final Function() onConfirm;

  const CupertinoDatePickerWidget({
    Key? key,
    this.initialDate,
    required this.onDateChanged,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _CupertinoDatePickerWidgetState createState() =>
      _CupertinoDatePickerWidgetState();
}

class _CupertinoDatePickerWidgetState extends State<CupertinoDatePickerWidget> {
  late DateTime tempDate; // Lưu giá trị tạm thời

  @override
  void initState() {
    super.initState();
    tempDate = widget.initialDate ??
        DateTime.now(); // Khởi tạo với initialDate hoặc ngày hiện tại
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).copyWith().size.height / 3,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: widget.onCancel, // Gọi callback Hủy
                  child: const Text(
                    "Huỷ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    widget.onDateChanged(
                        tempDate); // Truyền giá trị đã chọn khi xác nhận
                    widget.onConfirm(); // Gọi callback Xác nhận
                  },
                  child: const Text(
                    "Xác nhận",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (date) {
                setState(() {
                  tempDate =
                      date; // Cập nhật giá trị tạm khi người dùng thay đổi
                });
                widget.onDateChanged(date); // Gọi callback nếu cần
              },
              initialDateTime: widget.initialDate ?? DateTime.now(),
              minimumYear: 2000,
              maximumYear: 2025,
              use24hFormat: false,
            ),
          ),
        ],
      ),
    );
  }
}

void showCupertinoDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  required Function(DateTime) onDateChanged,
  required Function() onCancel,
  required Function() onConfirm,
}) {
  showModalBottomSheet(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(15),
        topLeft: Radius.circular(15),
      ),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    context: context,
    builder: (BuildContext builder) {
      return CupertinoDatePickerWidget(
        initialDate: initialDate,
        onDateChanged: onDateChanged,
        onCancel: onCancel,
        onConfirm: onConfirm,
      );
    },
  );
}

Future<void> showMaterialDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  required Function(DateTime?) onDatePicked,
  VoidCallback? onCancel,
}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      return Theme(
        data: ThemeData.from(colorScheme: Theme.of(context).colorScheme),
        child: child!,
      );
    },
  );

  // If picked is null (user canceled), call onCancel if provided
  if (picked == null && onCancel != null) {
    onCancel();
  } else {
    // Otherwise, call onDatePicked with the selected date
    onDatePicked(picked);
  }
}
