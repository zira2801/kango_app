import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class TruyVanScreen extends StatefulWidget {
  const TruyVanScreen({super.key});

  @override
  State<TruyVanScreen> createState() => _TruyVanScreenState();
}

class _TruyVanScreenState extends State<TruyVanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TextApp(
          text: 'Trang đang trong quá trình phát triển',
          fontsize: 20.sp,
        ),
      ),
    );
  }
}
