import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class FormShipment7 extends StatefulWidget {
  final GlobalKey<FormState> formField;
  final Function() eventBackButton;
  final Function() eventNextButton;
  final TextEditingController cuocNoiDiaController;
  final TextEditingController cuocThuHoController;
  final TextEditingController giaCuocVATController;
  final TextEditingController cuocPhuThuController;
  final TextEditingController cuocPhiBaoHiemController;
  final TextEditingController cuocGocController;
  final TextEditingController thuKhachController;
  final bool isLoadingButtonCreateShipment;
  final String? shipmentCode;
  const FormShipment7({
    required this.formField,
    required this.eventBackButton,
    required this.eventNextButton,
    required this.cuocNoiDiaController,
    required this.cuocThuHoController,
    required this.giaCuocVATController,
    required this.cuocPhuThuController,
    required this.cuocPhiBaoHiemController,
    required this.cuocGocController,
    required this.thuKhachController,
    required this.isLoadingButtonCreateShipment,
    required this.shipmentCode,
  });

  @override
  State<FormShipment7> createState() => _FormShipment7State();
}

class _FormShipment7State extends State<FormShipment7> {
  @override
  void initState() {
    super.initState();
    // Chỉ khởi tạo giá trị mặc định nếu controller chưa có dữ liệu
    if (widget.shipmentCode == null) {
      if (widget.cuocNoiDiaController.text.isEmpty) {
        widget.cuocNoiDiaController.text = '0';
      }
      if (widget.cuocThuHoController.text.isEmpty) {
        widget.cuocThuHoController.text = '0';
      }
      if (widget.giaCuocVATController.text.isEmpty) {
        widget.giaCuocVATController.text = '0';
      }
      if (widget.cuocPhuThuController.text.isEmpty) {
        widget.cuocPhuThuController.text = '0';
      }
      if (widget.cuocPhiBaoHiemController.text.isEmpty) {
        widget.cuocPhiBaoHiemController.text = '0';
      }
      if (widget.cuocGocController.text.isEmpty) {
        widget.cuocGocController.text = '0';
      }
      if (widget.thuKhachController.text.isEmpty) {
        widget.thuKhachController.text = '0';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(right: 20.w, left: 20.w, bottom: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Form(
        key: widget.formField,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextApp(
                                  text: "CHI PHÍ PHỤ THU KHÁCH",
                                  fontsize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextApp(
                                      text: "1/ Giá cước",
                                      fontsize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  _buildFormRow('Cước nội địa',
                                      widget.cuocNoiDiaController),
                                  _buildFormRow('Cước thu hộ',
                                      widget.cuocThuHoController),
                                  _buildFormRow('Giá cước VAT',
                                      widget.giaCuocVATController),
                                  _buildFormRow('Cước phụ thu',
                                      widget.cuocPhuThuController),
                                  _buildFormRow('Cước phí bảo hiểm',
                                      widget.cuocPhiBaoHiemController),
                                  _buildFormRow(
                                      'Cước gốc', widget.cuocGocController),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextApp(
                                      text: "2/ Thu tiền khách",
                                      fontsize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  _buildFormRow(
                                      'Thu khách', widget.thuKhachController),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100.w,
                              child: !widget.isLoadingButtonCreateShipment
                                  ? ButtonApp(
                                      event: widget.eventBackButton,
                                      text: "Về",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : Container(),
                            ),
                            SizedBox(
                              width: 150.w,
                              child: widget.isLoadingButtonCreateShipment ==
                                      false
                                  ? ButtonApp(
                                      event: widget.eventNextButton,
                                      text: widget.shipmentCode == null
                                          ? "Tạo đơn"
                                          : "Cập nhật",
                                      fontsize: 14.sp,
                                      colorText: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextApp(
                text: label,
                fontsize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          CustomTextFormField(
            suffixText: "VND",
            keyboardType: TextInputType.number,
            textInputFormatter: [
              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
            ],
            controller: controller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nội dung không được để trống';
              }
              return null;
            },
            hintText: '',
          ),
        ],
      ),
    );
  }
}
