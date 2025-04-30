import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

class EditAdditionalCosts extends StatefulWidget {
  final String shipmentCode;
  final DetailsShipmentModel? detailsShipment;
  const EditAdditionalCosts(
      {required this.shipmentCode, required this.detailsShipment, super.key});

  @override
  State<EditAdditionalCosts> createState() => _EditAdditionalCostsState();
}

class _EditAdditionalCostsState extends State<EditAdditionalCosts> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.8,
      expand: false,
      builder: (BuildContext context, ScrollController scrollControllerSearch) {
        return Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.w,
                  height: 5.w,
                  margin: EdgeInsets.only(top: 15.h, bottom: 15.h),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.grey),
                ),
                Expanded(
                    child: ListView(
                  controller: scrollControllerSearch,
                  padding: EdgeInsets.only(left: 15.w, right: 15.w),
                  children: [
                    TextApp(
                      text: "Cập nhật chi phí phụ thu",
                      fontsize: 22.sp,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    AdditionalCostsScreen(
                      shipmentCode: widget.shipmentCode,
                      detailsShipment: widget.detailsShipment,
                    ),
                  ],
                ))
              ],
            ));
      },
    );
  }
}

class AdditionalCostsScreen extends StatefulWidget {
  final String shipmentCode;
  final DetailsShipmentModel? detailsShipment;
  const AdditionalCostsScreen(
      {required this.shipmentCode, required this.detailsShipment, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdditionalCostsScreenState createState() => _AdditionalCostsScreenState();
}

class _AdditionalCostsScreenState extends State<AdditionalCostsScreen> {
  final _formFieldAdditionalCosts = GlobalKey<FormState>();
  FToast fToast = FToast();
  final shipmentDomesticChargesTextController = TextEditingController();
  final shipmentAmountSurchargeTextController = TextEditingController();
  final shipmentCollectionFeeTextController = TextEditingController();
  final shipmentAmountInsuranceTextController = TextEditingController();
  final shipmentAmountVatTextController = TextEditingController();
  final shipmentAmountOriginalTextController = TextEditingController();
  final shipmentAmountTotalCustomerTextController = TextEditingController();

  Future<void> getData() async {
    setState(() {
      shipmentDomesticChargesTextController.text =
          widget.detailsShipment?.shipment.shipmentDomesticCharges.toString() ??
              '0';
      shipmentAmountSurchargeTextController.text =
          widget.detailsShipment?.shipment.shipmentAmountSurcharge.toString() ??
              '0';
      shipmentCollectionFeeTextController.text =
          widget.detailsShipment?.shipment.shipmentCollectionFee.toString() ??
              '0';
      shipmentAmountInsuranceTextController.text =
          widget.detailsShipment?.shipment.shipmentAmountInsurance.toString() ??
              '0';
      shipmentAmountVatTextController.text =
          widget.detailsShipment?.shipment.shipmentAmountVat.toString() ?? '0';
      shipmentAmountOriginalTextController.text =
          widget.detailsShipment?.shipment.shipmentAmountOriginal.toString() ??
              '0';
      shipmentAmountTotalCustomerTextController.text = widget
              .detailsShipment?.shipment.shipmentAmountTotalCustomer
              .toString() ??
          '0';
    });
  }

  _showToast({required String mess, required Color color, required Icon icon}) {
    Widget toast = Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(
            width: 10.w,
          ),
          TextApp(
            text: mess,
            fontsize: 14.sp,
            color: Colors.white,
          ),
        ],
      ),
    );

    // Custom Toast Position
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child, gravity) {
        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 80.h),
                  child: child,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void handleUpdateAdditionalCosts() async {
    final response = await http.post(
      Uri.parse('$baseUrl$shipmentUpdateFreight'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        "shipment_code": widget.shipmentCode,
        "shipment_domestic_charges": shipmentDomesticChargesTextController.text,
        "shipment_amount_surcharge": shipmentAmountSurchargeTextController.text,
        "shipment_collection_fee": shipmentCollectionFeeTextController.text,
        "shipment_amount_insurance": shipmentAmountInsuranceTextController.text,
        "shipment_amount_vat": shipmentAmountVatTextController.text,
        "shipment_amount_original": shipmentAmountOriginalTextController.text,
        "shipment_amount_total_customer":
            shipmentAmountTotalCustomerTextController.text
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    var messRes = mess['text'];
    try {
      if (data['status'] == 200) {
        log("handleUpdateAdditionalCosts OKKK ");
        _showToast(
            mess: messRes,
            color: Colors.green,
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ));
      } else {
        log("handleUpdateAdditionalCosts error 1");
        _showToast(
            mess: messRes,
            color: Colors.red,
            icon: const Icon(
              Icons.cancel,
              color: Colors.white,
            ));
      }
    } catch (error) {
      log("handleUpdateAdditionalCosts error $error 2");
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return ErrorDialog(
              eventConfirm: () {
                Navigator.pop(context);
              },
            );
          });
    }
  }

  void init() async {
    await getData();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    shipmentDomesticChargesTextController.dispose();
    shipmentAmountSurchargeTextController.dispose();
    shipmentCollectionFeeTextController.dispose();
    shipmentAmountInsuranceTextController.dispose();
    shipmentAmountVatTextController.dispose();
    shipmentAmountOriginalTextController.dispose();
    shipmentAmountTotalCustomerTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.detailsShipment != null
        ? Form(
            key: _formFieldAdditionalCosts,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextApp(
                            text: "1/ Chi phí phụ thu khách",
                            fontsize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 120.w,
                                child: TextApp(
                                  text: "Cước nội địa",
                                  fontsize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      shipmentDomesticChargesTextController,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    }
                                    return "Không được để trống";
                                  },
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Giá tiền',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 120.w,
                                child: TextApp(
                                  text: "Cước phụ thu",
                                  fontsize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      shipmentAmountSurchargeTextController,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    }
                                    return "Không được để trống";
                                  },
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Giá tiền',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 120.w,
                                child: TextApp(
                                  text: "Cước thu hộ",
                                  fontsize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      shipmentCollectionFeeTextController,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    }
                                    return "Không được để trống";
                                  },
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Giá tiền',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 120.w,
                                child: TextApp(
                                  text: "Cước phí bảo hiểm",
                                  fontsize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      shipmentAmountInsuranceTextController,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    }
                                    return "Không được để trống";
                                  },
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Giá tiền',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 120.w,
                                child: TextApp(
                                  text: "Giá cước VAT",
                                  fontsize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: shipmentAmountVatTextController,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    }
                                    return "Không được để trống";
                                  },
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Giá tiền',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 120.w,
                                child: TextApp(
                                  text: "Cước gốc",
                                  fontsize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      shipmentAmountOriginalTextController,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    }
                                    return "Không được để trống";
                                  },
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Giá tiền',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15.h,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 120.w,
                                child: TextApp(
                                  text: "Thu tiền khách",
                                  fontsize: 14.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      shipmentAmountTotalCustomerTextController,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      return null;
                                    }
                                    return "Không được để trống";
                                  },
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Giá tiền',
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ]),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                SizedBox(
                  width: 1.sw,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ButtonApp(
                        text: 'Đóng',
                        fontsize: 14.sp,
                        fontWeight: FontWeight.bold,
                        colorText: Theme.of(context).colorScheme.background,
                        backgroundColor: Colors.grey,
                        outlineColor: Colors.grey,
                        event: () {
                          Navigator.pop(context);
                        },
                      ),
                      ButtonApp(
                        text: 'Cập nhật',
                        fontsize: 14.sp,
                        fontWeight: FontWeight.bold,
                        colorText: Theme.of(context).colorScheme.background,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        outlineColor: Theme.of(context).colorScheme.primary,
                        event: () {
                          if (_formFieldAdditionalCosts.currentState!
                              .validate()) {
                            handleUpdateAdditionalCosts();
                          }
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 50.h,
                )
              ],
            ),
          )
        : const NoDataFoundWidget();
  }
}
