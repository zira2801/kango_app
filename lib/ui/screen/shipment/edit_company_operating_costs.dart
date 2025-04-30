import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scan_barcode_app/data/models/shipment/operating_cost_shipment_model.dart';
import 'package:scan_barcode_app/data/models/shipment/shipment_operating_costs.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

class EditCompanyOperatingCosts extends StatefulWidget {
  final String shipmentCode;
  const EditCompanyOperatingCosts({required this.shipmentCode, super.key});

  @override
  State<EditCompanyOperatingCosts> createState() =>
      _EditCompanyOperatingCostsState();
}

class _EditCompanyOperatingCostsState extends State<EditCompanyOperatingCosts> {
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
                      text: "Cập nhật chi phí vận hành",
                      fontsize: 20.sp,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    OperatingCostScreen(
                      shipmentCode: widget.shipmentCode,
                    ),
                  ],
                ))
              ],
            ));
      },
    );
  }
}

class OperatingCostScreen extends StatefulWidget {
  final String shipmentCode;

  const OperatingCostScreen({required this.shipmentCode, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OperatingCostScreenState createState() => _OperatingCostScreenState();
}

class _OperatingCostScreenState extends State<OperatingCostScreen> {
  late Future<List<OperatingCost>> futureOperatingCosts;
  final customerRecieveSMSController = TextEditingController();
  final customerPhoneController = TextEditingController();
  final _formFieldOperatingCots = GlobalKey<FormState>();
  Map<int, int?> selectedRadioValues = {};
  List<int> selectedCheckboxValues = [];
  bool isInitialized = false;
  FToast fToast = FToast();
  ChildShipmentOperatingCostModel? childOperatingCostShipmentModel;
  final Map<int, TextEditingController> amountControllers = {};
  final Map<int, TextEditingController> quantityControllers = {};
  Future<List<OperatingCost>> handleGetShipmentOperatingCosts() async {
    final response = await http.post(
      Uri.parse('$baseUrl$shipmentOperatingCosts'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipment_code': widget.shipmentCode,
      }),
    );
    final data = jsonDecode(response.body);
    final data2 = data['shipment'];

    if (response.statusCode == 200) {
      setState(() {
        childOperatingCostShipmentModel =
            ChildShipmentOperatingCostModel.fromJson(data2);
        customerRecieveSMSController.text =
            childOperatingCostShipmentModel?.receiverSmsName ?? '';
        customerPhoneController.text =
            childOperatingCostShipmentModel?.receiverSmsPhone ?? '';
      });
      final List<dynamic> data = json.decode(response.body)['operating_costs'];

      return data.map((json) => OperatingCost.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data');
    }
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

  Future<void> updateShipmentOperatingCosts() async {
    List<OperatingCost> operatingCosts = await futureOperatingCosts;

    final Map<String, dynamic> operatingCostsPayload = {};
    int operatingCostIndex = 0;

    for (var operatingCost in operatingCosts) {
      if (operatingCost.operatingCostType == 0) {
        // Handle RADIO button type
        int? selectedRadio = selectedRadioValues[operatingCost.operatingCostId];
        if (selectedRadio != null) {
          operatingCostsPayload[operatingCostIndex.toString()] = {
            'shipment-operating-cost': [
              {
                'operating-cost-id': selectedRadio.toString(),
                'operating-cost-amount': amountControllers[selectedRadio]!.text,
                'shipment-operating-cost-quantity':
                    quantityControllers[selectedRadio]!.text,
              }
            ]
          };
          operatingCostIndex++;
        }
      } else if (operatingCost.operatingCostType == 1) {
        // Handle CHECKBOX type
        List<Map<String, String>> selectedCheckboxes = [];

        for (var childCost in operatingCost.childOperatingCost) {
          if (selectedCheckboxValues.contains(childCost.operatingCostId)) {
            if (amountControllers[childCost.operatingCostId] != null &&
                quantityControllers[childCost.operatingCostId] != null) {
              selectedCheckboxes.add({
                'operating-cost-id': childCost.operatingCostId.toString(),
                'operating-cost-amount':
                    amountControllers[childCost.operatingCostId]!.text,
                'shipment-operating-cost-quantity':
                    quantityControllers[childCost.operatingCostId]!.text,
              });
            }
          }
        }

        if (selectedCheckboxes.isNotEmpty) {
          operatingCostsPayload[operatingCostIndex.toString()] = {
            'shipment-operating-cost': selectedCheckboxes
          };
        }
      }
    }

    operatingCostsPayload['receiver-sms-name'] =
        customerRecieveSMSController.text;
    operatingCostsPayload['receiver-sms-phone'] = customerPhoneController.text;
    log(operatingCostsPayload.toString());

    final response = await http.post(
      Uri.parse('$baseUrl$hanldeUpdateShipmentOperatingCosts'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipment_code': widget.shipmentCode,
        'operating_costs': operatingCostsPayload,
      }),
    );
    final data = jsonDecode(response.body);
    var messRes = data['message']['text'];
    try {
      if (data['status'] == 200) {
        setState(() {
          futureOperatingCosts = handleGetShipmentOperatingCosts();
        });
        _showToast(
            mess: messRes,
            color: Colors.green,
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ));
      } else {
        _showToast(
            mess: messRes,
            color: Colors.red,
            icon: const Icon(
              Icons.cancel,
              color: Colors.white,
            ));
      }
    } catch (error) {
      log("updateShipmentOperatingCosts error $error 2");
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

  @override
  void initState() {
    super.initState();
    futureOperatingCosts = handleGetShipmentOperatingCosts();
    fToast = FToast();
    fToast.init(context);
  }

  void initializeSelectedValues(List<OperatingCost> operatingCosts) {
    for (var operatingCost in operatingCosts) {
      if (operatingCost.operatingCostType == 0) {
        selectedRadioValues[operatingCost.operatingCostId] = null;
        for (var childCost in operatingCost.childOperatingCost) {
          if (childCost.shipmentOperatingCostId != null) {
            selectedRadioValues[operatingCost.operatingCostId] =
                childCost.operatingCostId;
          }

          amountControllers[childCost.operatingCostId] = TextEditingController(
              text: (childCost.shipmentOperatingCostAmount ?? 0).toString());
          quantityControllers[childCost.operatingCostId] =
              TextEditingController(
                  text: (childCost.shipmentOperatingCostQuantity ?? 1)
                      .toString());
        }
      } else if (operatingCost.operatingCostType == 1) {
        for (var childCost in operatingCost.childOperatingCost) {
          if (childCost.shipmentOperatingCostId != null) {
            selectedCheckboxValues.add(childCost.operatingCostId);
          }

          amountControllers[childCost.operatingCostId] = TextEditingController(
              text: (childCost.shipmentOperatingCostAmount ?? 0).toString());
          quantityControllers[childCost.operatingCostId] =
              TextEditingController(
                  text: (childCost.shipmentOperatingCostQuantity ?? 1)
                      .toString());
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in amountControllers.values) {
      controller.dispose();
    }
    for (var controller in quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OperatingCost>>(
      future: futureOperatingCosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final operatingCosts = snapshot.data!;
          if (!isInitialized) {
            initializeSelectedValues(operatingCosts);
            isInitialized = true;
          }

          return Form(
            key: _formFieldOperatingCots,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: operatingCosts.length,
                  itemBuilder: (context, index) {
                    final operatingCost = operatingCosts[index];

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${index + 1}. ${operatingCost.operatingCostName}',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (operatingCost.operatingCostDescription != null)
                              Text(operatingCost.operatingCostDescription!),
                            if (operatingCost.operatingCostType == 0) ...[
                              ...operatingCost.childOperatingCost
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final childCost = entry.value;
                                final amountController = amountControllers[
                                    childCost.operatingCostId];
                                final quantityController = quantityControllers[
                                    childCost.operatingCostId];
                                return Row(
                                  children: [
                                    Radio<int>(
                                      value: childCost.operatingCostId,
                                      groupValue: selectedRadioValues[
                                          operatingCost.operatingCostId],
                                      onChanged: (int? value) {
                                        setState(() {
                                          selectedRadioValues[operatingCost
                                              .operatingCostId] = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 100.w,
                                      child: Text(childCost.operatingCostName),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller: amountController,
                                        validator: (value) {
                                          if (value != null &&
                                              value.isNotEmpty) {
                                            return null;
                                          }
                                          return "Không được để trống";
                                        },
                                        onTapOutside: (event) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Giá tiền',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[0-9]")),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    SizedBox(
                                      width: 50.w,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value != null &&
                                              value.isNotEmpty) {
                                            return null;
                                          }
                                          return "Không được để trống";
                                        },
                                        textAlign: TextAlign.center,
                                        controller: quantityController,
                                        decoration: const InputDecoration(
                                          labelText: 'SL',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[0-9]")),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ] else if (operatingCost.operatingCostType ==
                                1) ...[
                              ...operatingCost.childOperatingCost
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final childCost = entry.value;
                                final amountController = amountControllers[
                                    childCost.operatingCostId];
                                final quantityController = quantityControllers[
                                    childCost.operatingCostId];

                                return Row(
                                  children: [
                                    Checkbox(
                                      value: selectedCheckboxValues
                                          .contains(childCost.operatingCostId),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedCheckboxValues
                                                .add(childCost.operatingCostId);
                                          } else {
                                            selectedCheckboxValues.remove(
                                                childCost.operatingCostId);
                                          }
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      width: 100.w,
                                      child: Text(childCost.operatingCostName),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value != null &&
                                              value.isNotEmpty) {
                                            return null;
                                          }
                                          return "Không được để trống";
                                        },
                                        controller: amountController,
                                        decoration: const InputDecoration(
                                          labelText: 'Giá tiền',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[0-9]")),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15.w,
                                    ),
                                    SizedBox(
                                      width: 50.w,
                                      child: TextFormField(
                                        controller: quantityController,
                                        validator: (value) {
                                          if (value != null &&
                                              value.isNotEmpty) {
                                            return null;
                                          }
                                          return "Không được để trống";
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'SL',
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp("[0-9]")),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
                TextApp(
                  text:
                      "Tên khách hàng nhận SMS ( ghi IN tiếng việt không dấu)",
                  fontsize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  controller: customerRecieveSMSController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nội dung không được để trống';
                    }
                    return null;
                  },
                  hintText: '',
                ),
                SizedBox(
                  height: 15.h,
                ),
                TextApp(
                  text: "SĐT người nhận tin(Nhập không khoảng trắng)",
                  fontsize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  controller: customerPhoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nội dung không được để trống';
                    }
                    return null;
                  },
                  hintText: '',
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
                          if (_formFieldOperatingCots.currentState!
                              .validate()) {
                            updateShipmentOperatingCosts();
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
          );
        } else {
          return const NoDataFoundWidget();
        }
      },
    );
  }
}
