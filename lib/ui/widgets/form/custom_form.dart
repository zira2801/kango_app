import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final bool readonly;
  final bool isPassword;
  final bool passwordVisible;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? textInputFormatter;
  final Function()? onTap;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? suffixText;
  final Widget? prefixIcon;
  final Function(PointerDownEvent)? onTapOutside;
  final Function()? onEditingComplete;
  final Function(String)? onChange;
  final double opacityHintText;
  final String? labelText;
  final int minLines;
  final int maxLines;
  final TextInputAction? textInputAction;
  final bool isMoneyFormat;
  final double? errorFontSize;
  final EdgeInsetsGeometry? contentPadding;
  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.enabled = true,
    this.readonly = false,
    this.isPassword = false,
    this.passwordVisible = false,
    this.validator,
    this.keyboardType,
    this.textInputFormatter,
    this.onTap,
    this.suffix,
    this.suffixIcon,
    this.suffixText,
    this.prefixIcon,
    this.onTapOutside,
    this.onEditingComplete,
    this.onChange,
    this.opacityHintText = 0.5,
    this.labelText,
    this.minLines = 1,
    this.maxLines = 1,
    this.textInputAction,
    this.isMoneyFormat = false,
    this.errorFontSize,
    this.contentPadding,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isPasswordVisible = false;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late TextEditingController _controller;

  // Hàm format số tiền
  String formatMoney(String value) {
    if (value.isEmpty) return '';

    // Loại bỏ tất cả các ký tự không phải số
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Chuyển đổi thành số
    int number = int.tryParse(value) ?? 0;

    // Format số với dấu chấm phân cách
    final formatNumber = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(formatNumber, (Match m) => '${m[1]}.');
  }

  @override
  void initState() {
    super.initState();
    isPasswordVisible = widget.passwordVisible;
    _focusNode.addListener(_onFocusChange);
    _controller = widget.controller;

    if (widget.isMoneyFormat!) {
      // Format giá trị ban đầu nếu có
      if (_controller.text.isNotEmpty) {
        _controller.text = formatMoney(_controller.text);
      }

      // Thêm listener để format số tiền khi text thay đổi
      _controller.addListener(() {
        final text = _controller.text;
        final formattedText = formatMoney(text);

        if (text != formattedText) {
          _controller.value = TextEditingValue(
            text: formattedText,
            selection: TextSelection.collapsed(offset: formattedText.length),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  String? validateMoney(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số tiền';
    }

    // Loại bỏ dấu chấm để kiểm tra giá trị số
    final numericValue = value.replaceAll('.', '');
    final amount = int.tryParse(numericValue);

    if (amount == null) {
      return 'Số tiền không hợp lệ';
    }

    if (amount < 1000) {
      return 'Số tiền phải lớn hơn 1.000 VNĐ';
    }

    return null;
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _handleFieldTap() {
    if (widget.readonly && widget.onTap != null) {
      widget.onTap!();
    } else {
      _focusNode.requestFocus();
    }
  }

  Widget _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        onPressed: togglePasswordVisibility,
        icon: Icon(
          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          size: 24.sp,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: widget.suffixIcon!,
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final TextInputType effectiveKeyboardType =
        widget.textInputAction == TextInputAction.newline
            ? TextInputType.multiline
            : (widget.keyboardType ?? TextInputType.text);

    return Stack(
      children: [
        TextFormField(
          focusNode: _focusNode,
          onChanged: (value) {
            if (widget.onChange != null) {
              widget.onChange!(value);
            }
          },
          onEditingComplete: widget.onEditingComplete,
          enabled: widget.enabled,
          readOnly: widget.readonly,
          onTap: _handleFieldTap,
          inputFormatters: widget.isMoneyFormat
              ? [FilteringTextInputFormatter.digitsOnly]
              : widget.textInputFormatter,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          textInputAction: widget.textInputAction,
          onTapOutside: (event) {
            if (widget.onTapOutside != null) {
              widget.onTapOutside!(event);
            }
          },
          controller: _controller,
          obscureText: widget.isPassword ? !isPasswordVisible : false,
          obscuringCharacter: '*',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black,
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          validator: widget.isMoneyFormat ? validateMoney : widget.validator,
          keyboardType: widget.isMoneyFormat
              ? TextInputType.number
              : effectiveKeyboardType,
          decoration: InputDecoration(
            labelText: widget.labelText,
            errorStyle: TextStyle(
              fontSize: widget.errorFontSize ?? 14.sp,
            ),
            fillColor: Theme.of(context).colorScheme.primary,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.w,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onBackground
                  .withOpacity(widget.opacityHintText),
              fontSize: 14.sp,
            ),
            isDense: true,
            contentPadding: widget.contentPadding ??
                EdgeInsets.fromLTRB(20.w, 20.w, 60.w, 20.w),
            suffixIcon: _buildSuffixIcon(),
            suffix: widget.suffix,
            prefixIcon: widget.prefixIcon,
          ),
        ),
        if (widget.suffixText != null)
          Positioned(
            right: 20.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                widget.suffixText!,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
