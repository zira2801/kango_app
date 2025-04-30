import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/data/models/mawb/mawb.dart';

class CustomMAWBDropdown extends StatefulWidget {
  final ShipmentTracktry? value;
  final List<ShipmentTracktry> items;
  final Function(ShipmentTracktry?) onChanged;
  final String hint;

  const CustomMAWBDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'Chọn MAWB',
  });

  @override
  State<CustomMAWBDropdown> createState() => _CustomMAWBDropdownState();
}

class _CustomMAWBDropdownState extends State<CustomMAWBDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _createOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _isOpen = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              height: min(300.h, widget.items.length * 56.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return InkWell(
                    onTap: () {
                      widget.onChanged(item);
                      _removeOverlay();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 18.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: index == widget.items.length - 1
                                ? Colors.transparent
                                : Colors.black
                                    .withOpacity(0.4), // Đổi màu gạch ngang
                            width: 1.5, // Tăng độ dày
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.awbCode,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ),
                          if (widget.value?.awbCode == item.awbCode)
                            Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        focusNode: _focusNode,
        child: GestureDetector(
          onTap: () {
            if (_isOpen) {
              _removeOverlay();
            } else {
              _createOverlay();
              _focusNode.requestFocus();
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value?.awbCode ?? widget.hint,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: widget.value == null
                          ? Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.5)
                          : Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
                Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
