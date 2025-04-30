import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:country_flags/country_flags.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:provider/provider.dart';
import 'package:scan_barcode_app/bloc/order_pickup/get_fwd_list/get_fwd_list_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/get_sale_list/get_sale_list_bloc.dart';
import 'package:scan_barcode_app/data/models/area.dart';
import 'package:scan_barcode_app/data/models/area_Vn.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/data/models/shipment/all_type_service.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/delivery_service.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment_to_update.dart';
import 'package:scan_barcode_app/data/models/shipment/info_old_receiver.dart';
import 'package:scan_barcode_app/data/models/shipment/list_old_receiver.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/home/home_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipment/form_shipment_1.dart';
import 'package:scan_barcode_app/ui/screen/shipment/form_shipment_2.dart';
import 'package:scan_barcode_app/ui/screen/shipment/form_shipment_3.dart';
import 'package:scan_barcode_app/ui/screen/shipment/form_shipment_4.dart';
import 'package:scan_barcode_app/ui/screen/shipment/form_shipment_5.dart';
import 'package:scan_barcode_app/ui/screen/shipment/form_shipment_6.dart';
import 'package:scan_barcode_app/ui/screen/shipment/form_shipment_7.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_manager_screen.dart';
import 'package:scan_barcode_app/ui/utils/format_money.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/easystepper/custom_easy_stepper.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

class CreateShipmentScreen extends StatefulWidget {
  final String? shipmentCode;
  final bool? isSale;
  final bool? isFwd;
  const CreateShipmentScreen(
      {super.key,
      required this.shipmentCode,
      this.isSale = false,
      this.isFwd = false});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  final _formField = GlobalKey<FormState>();
  final _formField2 = GlobalKey<FormState>();
  final _formField3 = GlobalKey<FormState>();
  final _formField4 = GlobalKey<FormState>();
  final _formField5 = GlobalKey<FormState>();
  final _formField6 = GlobalKey<FormState>();
  final _formField7 = GlobalKey<FormState>();
  final _formGoods = GlobalKey<FormState>();
  final _formInvoice = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  final scrollListFWDController = ScrollController();

  List cityListSender = [];
  List districListSender = [];
  List wardListSender = [];

  List countryFlagList = [];
  List countryListReciver = [];
  List stateListReciver = [];
  List cityListReciver = [];

  List<int>? countryIDList = [];
  List<int>? stateIDList = [];
  List<int>? cityIDList = [];

  DeliveryServiceModel? deliveryServiceMode;
  ListTypeServiceModel? listTypeServiceModel;

  BranchResponse? branchResponse;
  InforAccountModel? inforAccountDataRes;
  ListOldReceiverModel? listOldReceiverModel;
  AllUnitShipmentModel? allUnitShipmentModel;
  InfoOldReceiverModel? infoOldReceiverModel;
  DetailsShipmentModel? detailsShipmentModel;
  DetailsShipmentToUpdateModel? detailsShipmentToUpdate;
  AreaModel? areaModel;
  int? currentIDCitySender;
  int? currentIDDistricSender;
  int? currentIDWardSender;

  int? currentIDCountryReciver;
  int? currentIDStateReciver;
  int? currentIDCityReciver;

  int? currentShipmentServiceID;
  int? currentOldReceiverID;
  int serviceTypeID = 0;

  int? editingPackageIndex;
  int? editingInvoiceIndex;
  int? currentBrandID;
  int? currentExportAsIndex;
  int? currentGoodTypeIndex;
  int? currentInvoiceUnitIndex;
  int selectedPaymentMethod = 0;

  bool agreePersonalData = false;
  bool isEditInvoice = false;
  bool isEditGoods = false;
  bool isLoadingPageSender = false;
  bool saveInforReceiver = false;
  bool signatureServiceReceiver = false;
  bool isFinishCreateShipment = false;
  bool isLoadingButtonCreateShipment = false;

  String namePosition = '';
  int currentForm = 0;

  List<Package>? packageList = [];
  List<Invoice>? invoiceList = [];
  int get totalSteps => widget.shipmentCode != null ? 5 : 7;

  Future<void> getListTypeService() async {
    final response = await http.post(
      Uri.parse('$baseUrl$getListTypeServiceShipement'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    try {
      if (data['status'] == 200) {
        mounted
            ? setState(() {
                listTypeServiceModel = ListTypeServiceModel.fromJson(data);
                position == 'fwd'
                    ? controllers['serviceType']!.text =
                        listTypeServiceModel!.serviceTypes['0']!
                    : controllers['serviceType']!.text =
                        listTypeServiceModel!.serviceTypes[detailsShipmentModel
                                ?.shipment.service.promotionFlg
                                .toString() ??
                            '0']!;
              })
            : null;
      } else {
        log("getDeliveryService error 1");
      }
    } catch (error) {
      log("getDeliveryService error $error 2");
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

  Future<void> getDeliveryService() async {
    log({
      'country_id': currentIDCountryReciver,
      'service_promotion_id': serviceTypeID
    }.toString());
    final response = await http.post(
      Uri.parse('$baseUrl$getDeliveryServiceApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'country_id': currentIDCountryReciver,
        'service_promotion_id': serviceTypeID
      }),
    );
    final data = jsonDecode(response.body);
    var mess = data['message'];
    try {
      if (data['status'] == 200) {
        mounted
            ? setState(() {
                deliveryServiceMode = DeliveryServiceModel.fromJson(data);
                if (deliveryServiceMode!.services.isEmpty) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc:
                          "Chưa có dịch vụ vận chuyển ở quốc gia này. \n Việc hoàn thành đơn không thể thực hiện!",
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      colorButtonCancle: Colors.blue,
                      btnOKText: "Về trang chủ",
                      btnCancleText: "Chọn lại",
                      typeDialog: "info",
                      eventButtonOKPress: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      eventButtonCanclePress: () {},
                      isTwoButton: true);
                }
              })
            : null;
      } else {
        log("getDeliveryService error 1");
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: mess['text'],
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {
              Navigator.pop(context);
            },
            eventButtonCanclePress: () {},
            isTwoButton: false);
      }
    } catch (error) {
      log("getDeliveryService error $error 2");
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return ErrorDialog(
              errorText: error.toString(),
              eventConfirm: () {
                Navigator.pop(context);
              },
            );
          });
    }
  }

  Future<void> getDetailsShipment({
    required String shipmentCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$getDetailsShipmentApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipment_code': shipmentCode,
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        log(data.toString());
        mounted
            ? setState(() {
                detailsShipmentModel = DetailsShipmentModel.fromJson(data);
              })
            : null;
      } else {
        log("getDeliveryService error 1");
      }
    } catch (error) {
      log("getDeliveryService error $error 2");
    }
  }

  Future<void> getListOldReceiver() async {
    final response = await http.post(
      Uri.parse('$baseUrl$getListOldReceiverApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    log("getListOldReceiver");

    try {
      if (data['status'] == 200) {
        log("getListOldReceiver OK");
        mounted
            ? setState(() {
                listOldReceiverModel = ListOldReceiverModel.fromJson(data);
              })
            : null;
      } else {
        log("getListOldReceiver error 1");
      }
    } catch (error) {
      log("getListOldReceiver error $error 2");
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

  Future<void> getAllUnitShipment() async {
    final response = await http.post(
      Uri.parse('$baseUrl$typeAndUnitShpment'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        log("getAllUnitShipment OK");
        mounted
            ? setState(() {
                allUnitShipmentModel = AllUnitShipmentModel.fromJson(data);
              })
            : null;
      } else if (response.statusCode == 401) {
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: "Hết phiên đăng nhập",
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {
              StorageUtils.instance.removeKey(key: 'token');
              StorageUtils.instance.removeKey(key: 'branch_response');
              navigatorKey.currentContext?.go('/');
            },
            isTwoButton: false);
      } else {
        log("getAllUnitShipment error 1");
      }
    } catch (error) {
      log("getAllUnitShipment error $error 2");
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

  Future<void> handleGetInforOldReciever({required int receiverID}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$inforOldReceiverApi'),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({
          'receiver_id': receiverID,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        mounted
            ? setState(() {
                infoOldReceiverModel = InfoOldReceiverModel.fromJson(data);
              })
            : null;

        // Check if receiver info is valid before accessing
        if (infoOldReceiverModel?.receivers != null) {
          // Gọi handleGetAreaGobal trước khi autoFill
          await handleGetAreaGobal(
            countryID: infoOldReceiverModel!.receivers!.receiverCountryId,
            stateID: infoOldReceiverModel!.receivers!.receiverStateId == 0
                ? null
                : infoOldReceiverModel!.receivers!.receiverStateId,
          );

          // Sau khi có data area mới autoFill
          await autoFillInfoOldReceiver();
        } else {
          log("Receiver data is null or incomplete");
        }
      }
    } catch (error) {
      log("handleGetInforOldReciever error $error");
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

  Future<void> autoFillInfoOldReceiver() async {
    setState(() {
      controllers['companyReciver']!.text =
          infoOldReceiverModel?.receivers?.receiverCompanyName ?? '';
      controllers['contactNameReciver']!.text =
          infoOldReceiverModel?.receivers?.receiverContactName ?? '';
      controllers['phoneReciver']!.text =
          infoOldReceiverModel?.receivers?.receiverTelephone ?? '';
      controllers['postalCodeReciver']!.text =
          infoOldReceiverModel?.receivers?.receiverPostalCode ?? '';
      controllers['address1Reciver']!.text =
          infoOldReceiverModel?.receivers?.receiverAddress1 ?? '';
      controllers['address2Reciver']!.text =
          infoOldReceiverModel?.receivers?.receiverAddress2 ?? '';
      controllers['address3Reciver']!.text =
          infoOldReceiverModel?.receivers?.receiverAddress3 ?? '';

      // Handle country
      List<Country> oldCountry = areaModel!.areas.countries
          .where((idCountry) =>
              idCountry.countryId ==
              infoOldReceiverModel!.receivers?.receiverCountryId)
          .toList();

      if (oldCountry.isNotEmpty) {
        controllers['countryNameReceiver']!.text = oldCountry[0].countryName;
        currentIDCountryReciver = oldCountry[0].countryId;
      }

      // Handle state
      if (infoOldReceiverModel?.receivers?.receiverStateId != null) {
        List<StateName> oldState = areaModel!.areas.states
            .where((idState) =>
                idState.stateId ==
                infoOldReceiverModel!.receivers?.receiverStateId)
            .toList();

        if (oldState.isNotEmpty) {
          controllers['stateNameReceiver']!.text = oldState[0].stateName;
          currentIDStateReciver = oldState[0].stateId;
        }
      } else {
        controllers['stateNameReceiver']!.text = '';
        currentIDStateReciver = null;
      }

      // Handle city
      // Handle city
      if (infoOldReceiverModel?.receivers?.receiverCityId != null &&
          currentIDStateReciver != null) {
        // Kiểm tra nếu state ID != null
        List<City> oldCity = areaModel!.areas.cities
            .where((idCity) =>
                idCity.cityId ==
                infoOldReceiverModel!.receivers?.receiverCityId)
            .toList();

        if (oldCity.isNotEmpty) {
          controllers['cityNameReceiver']!.text = oldCity[0].cityName;
          currentIDCityReciver = oldCity[0].cityId;
        } else {
          controllers['cityNameReceiver']!.text = '';
          currentIDCityReciver = null;
        }
      } else {
        controllers['cityNameReceiver']!.text = '';
        currentIDCityReciver = null;
      }

      getDeliveryService();
    });
  }

  Future<void> getDetailsShipmentToUpdate({
    required String shipmentCode,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$getDataUpdateShipmentApi'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'is_api': true,
        'shipment_code': shipmentCode,
      }),
    );

    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        setState(() {
          detailsShipmentToUpdate = DetailsShipmentToUpdateModel.fromJson(data);

          controllers['companySender']!.text =
              detailsShipmentToUpdate?.shipment.senderCompanyName ?? '';
          controllers['contactNameSender']!.text =
              detailsShipmentToUpdate?.shipment.senderContactName ?? '';
          controllers['phoneSender']!.text =
              detailsShipmentToUpdate?.shipment.senderTelephone ?? '';
          controllers['addressSender']!.text =
              detailsShipmentToUpdate?.shipment.senderAddress ?? '';
          currentIDCitySender = detailsShipmentToUpdate?.shipment.senderCity;
          currentIDDistricSender =
              detailsShipmentToUpdate?.shipment.senderDistrict;
          currentIDWardSender = detailsShipmentToUpdate?.shipment.senderWard;
          currentIDCountryReciver =
              detailsShipmentToUpdate?.shipment.receiverCountryId;
          currentIDStateReciver =
              detailsShipmentToUpdate?.shipment.receiverStateId;
          currentIDCityReciver =
              detailsShipmentToUpdate?.shipment.receiverCityId;
          serviceTypeID =
              detailsShipmentModel?.shipment.service.promotionFlg ?? 0;
          selectedPaymentMethod =
              detailsShipmentModel?.shipment.shipmentPaidBy ?? 0;

          currentOldReceiverID =
              detailsShipmentToUpdate?.shipment.receiverId ?? 0;
          controllers['cuocNoiDia']!.text =
              (detailsShipmentModel?.shipment.shipmentDomesticCharges ?? 0)
                  .toString();
          controllers['cuocPhiBaoHiem']!.text =
              (detailsShipmentModel?.shipment.shipmentAmountInsurance ?? 0)
                  .toString();
          controllers['cuocThuHo']!.text =
              (detailsShipmentModel?.shipment.shipmentCollectionFee ?? 0)
                  .toString();
          controllers['cuocPhuThu']!.text =
              (detailsShipmentModel?.shipment.shipmentAmountSurcharge ?? 0)
                  .toString();
          controllers['giaCuocVAT']!.text =
              (detailsShipmentModel?.shipment.shipmentAmountVat ?? 0)
                  .toString();
          controllers['cuocGoc']!.text =
              (detailsShipmentModel?.shipment.shipmentAmountOriginal ?? 0)
                  .toString();
          controllers['thuKhach']!.text =
              (detailsShipmentModel?.shipment.shipmentAmountTotalCustomer ?? 0)
                  .toString();
          agreePersonalData = true;
          signatureServiceReceiver =
              (detailsShipmentModel?.shipment.shipmentSignatureFlg ?? 0) == 1;
        });

        await handleGetAreaGobal(
            countryID: detailsShipmentToUpdate?.shipment.receiverCountryId,
            stateID: null);
        await getDeliveryService();
        setState(() {
          controllers['companyReciver']!.text =
              detailsShipmentToUpdate?.shipment.receiverCompanyName ?? '';
          controllers['contactNameReciver']!.text =
              detailsShipmentToUpdate?.shipment.receiverContactName ?? '';
          controllers['phoneReciver']!.text =
              detailsShipmentToUpdate?.shipment.receiverTelephone ?? '';
          List<Country> oldCountry = areaModel!.areas.countries
              .where((idCountry) =>
                  idCountry.countryId ==
                  detailsShipmentToUpdate?.shipment.receiverCountryId)
              .toList();
          List<StateName> oldState = areaModel!.areas.states
              .where((idState) =>
                  idState.stateId ==
                  detailsShipmentToUpdate?.shipment.receiverStateId)
              .toList();

          controllers['countryNameReceiver']!.text = oldCountry[0].countryName;
          // Thêm check nếu receiver_state_id null thì lấy receiver_state_name
          if (detailsShipmentToUpdate?.shipment.receiverStateId == null) {
            controllers['stateNameReceiver']!.text =
                detailsShipmentToUpdate?.shipment.receiverStateName ?? '';
          } else {
            List<StateName> oldState = areaModel!.areas.states
                .where((idState) =>
                    idState.stateId ==
                    detailsShipmentToUpdate?.shipment.receiverStateId)
                .toList();
            controllers['stateNameReceiver']!.text = oldState[0].stateName;
          }

          if (areaModel!.areas.cities.isNotEmpty) {
            List<City> oldCity = areaModel!.areas.cities
                .where((idCity) =>
                    idCity.cityId ==
                    detailsShipmentToUpdate?.shipment.receiverCityId)
                .toList();
            controllers['cityNameReceiver']!.text = oldCity[0].cityName;
          }
          controllers['postalCodeReciver']!.text =
              detailsShipmentToUpdate?.shipment.receiverPostalCode.toString() ??
                  '';
          controllers['address1Reciver']!.text =
              detailsShipmentToUpdate?.shipment.receiverAddress1 ?? '';
          controllers['address2Reciver']!.text =
              detailsShipmentToUpdate?.shipment.receiverAddress2 ?? '';
          controllers['address3Reciver']!.text =
              detailsShipmentToUpdate?.shipment.receiverAddress3 ?? '';

          var nameServiceText = deliveryServiceMode?.services
              .where((idShipmentService) =>
                  idShipmentService.serviceId ==
                  detailsShipmentToUpdate!.shipment.shipmentServiceId)
              .toList();
          log("KKKKKK");
          // log(detailsShipmentToUpdate.shipment.service.)
          controllers['serviceText']!.text = nameServiceText![0].serviceName;
          currentShipmentServiceID =
              detailsShipmentToUpdate!.shipment.shipmentServiceId;
          var listIDBranch = branchResponse?.branchs
              .where((branch) =>
                  branch.branchId ==
                  detailsShipmentToUpdate!.shipment.shipmentBranchId)
              .toList();
          controllers['branchText']!.text = listIDBranch![0].branchName;
          currentBrandID = detailsShipmentToUpdate!.shipment.shipmentBranchId;
          controllers['referenceCode']!.text =
              detailsShipmentToUpdate?.shipment.shipmentReferenceCode ?? '';
          controllers['goodsNameText']!.text =
              detailsShipmentToUpdate?.shipment.shipmentGoodsName ?? '';
          controllers['goodsInvoiceValue']!.text =
              detailsShipmentToUpdate?.shipment.shipmentValue.toString() ?? '';
          controllers['exportAsText']!.text =
              allUnitShipmentModel?.data.invoiceExportsAs[
                      detailsShipmentToUpdate!.shipment.shipmentExportAs] ??
                  '';
          currentExportAsIndex =
              detailsShipmentToUpdate!.shipment.shipmentExportAs;
          packageList = detailsShipmentToUpdate?.shipment.packages;
          invoiceList = detailsShipmentToUpdate?.shipment.invoices;
        });
      } else if (response.statusCode == 401) {
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: "Hết phiên đăng nhập",
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {
              StorageUtils.instance.removeKey(key: 'token');
              StorageUtils.instance.removeKey(key: 'branch_response');
              navigatorKey.currentContext?.go('/');
            },
            isTwoButton: false);
      } else {
        log('getDetailsShipmentToUpdate error ${data['message']} 1');

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
    } catch (error) {
      log('getDetailsShipmentToUpdate $error  2');

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

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  void onGetListSale({required String? keywords}) {
    context.read<GetListSaleScreenBloc>().add(
          FetchListSale(keywords: keywords),
        );
  }

  void init() async {
    setState(() {
      isLoadingPageSender = true;
    });
    onGetListSale(keywords: null);
    await getBranchKango();
    await getAllUnitShipment();
    if (widget.shipmentCode != null) {
      await getDetailsShipment(shipmentCode: widget.shipmentCode!);
      await getDetailsShipmentToUpdate(shipmentCode: widget.shipmentCode!);
    } else {
      await getInforUser();
    }

    await handleGetAreaVN(
        cityID: currentIDCitySender, districtID: currentIDDistricSender);
    await handleGetAreaGobal(
        countryID: currentIDCountryReciver, stateID: currentIDStateReciver);
    await initAreaFieldSender();
    await getListOldReceiver();
    getListTypeService();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          isLoadingPageSender = false;
        });
      }
    });
  }

  void addCommaToDotListener(TextEditingController controller) {
    controller.addListener(() {
      String text = controller.text;
      if (text.contains(',')) {
        controller.value = controller.value.copyWith(
          text: text.replaceAll(',', '.'),
          selection: TextSelection.collapsed(offset: controller.text.length),
        );
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    initializeControllers([
      'companySender',
      'contactNameSender',
      'phoneSender',
      'addressSender',
      'longitudeSender',
      'latitudeSender',
      'fwdID',
      'fwdReciver',
      'cityNameSender',
      'districNameSender',
      'wardNameSender',
      'chooseOldReciver',
      'companyReciver',
      'contactNameReciver',
      'phoneReciver',
      'postalCodeReciver',
      'address1Reciver',
      'address2Reciver',
      'address3Reciver',
      'referenceCode',
      'countryNameReceiver',
      'stateNameReceiver',
      'cityNameReceiver',
      'serviceText',
      'branchText',
      'exportAsText',
      'invoiceGoodsDetails',
      'invoiceQuantityText',
      'invoiceUnitText',
      'invoicePriceText',
      'invoiceTotalValue',
      'goodsNameText',
      'goodsInvoiceValue',
      'goodsQuantity',
      'goodsTypeText',
      'goodsLengthValue',
      'goodsWidthValue',
      'goodsHeigthValue',
      'goodsWeightValue',
      'serviceType',
      'search',
      //Form 7
      'cuocNoiDia',
      'cuocThuHo',
      'giaCuocVAT',
      'cuocPhuThu',
      'cuocPhiBaoHiem',
      'cuocGoc',
      'thuKhach',
    ]);
    scrollListFWDController.addListener(_onScrollListFwd);

    mounted
        ? init()
        : null; // Add a listener to the controller to automatically replace ',' with '.'
    addCommaToDotListener(controllers['goodsLengthValue']!);
    addCommaToDotListener(controllers['goodsWidthValue']!);
    addCommaToDotListener(controllers['goodsHeigthValue']!);
    addCommaToDotListener(controllers['goodsWeightValue']!);
  }

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  void _onScrollListFwd() {
    if (scrollListFWDController.position.maxScrollExtent ==
        scrollListFWDController.offset) {
      BlocProvider.of<GetListSaleScreenBloc>(context)
          .add(LoadMoreListSale(keywords: controllers['search']!.text));
    }
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    scrollListFWDController.dispose();
    super.dispose();
  }

  Future<void> getInforUser() async {
    final int? userID = StorageUtils.instance.getInt(key: 'user_ID');

    final response = await http.post(
      Uri.parse('$baseUrl$getInforAccount'),
      headers: ApiUtils.getHeaders(isNeedToken: true),
      body: jsonEncode({
        'user_id': userID,
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        mounted
            ? setState(() {
                inforAccountDataRes = InforAccountModel.fromJson(data);

                controllers['companySender']!.text =
                    inforAccountDataRes?.data.userCompanyName ?? '';
                controllers['contactNameSender']!.text =
                    inforAccountDataRes?.data.userContactName ?? '';
                controllers['phoneSender']!.text =
                    inforAccountDataRes?.data.userPhone ?? '';
                // controllers['addressSender']!.text =
                //     inforAccountDataRes?.data.userAddress ?? '';
                currentIDCitySender = inforAccountDataRes?.data.userAddress1;
                currentIDDistricSender = inforAccountDataRes?.data.userAddress2;
                currentIDWardSender = inforAccountDataRes?.data.userAddress3;
              })
            : null;
      } else if (response.statusCode == 401) {
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: "Hết phiên đăng nhập",
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {
              StorageUtils.instance.removeKey(key: 'token');
              StorageUtils.instance.removeKey(key: 'branch_response');
              navigatorKey.currentContext?.go('/');
            },
            isTwoButton: false);
      } else {
        log("ERROR _onManagerLogout 1");
      }
    } catch (error) {
      log("ERROR _onManagerLogout 2 $error");
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

  Future<void> handleGetAreaGobal({
    required int? countryID,
    required int? stateID,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$getAreaApi'),
      headers: ApiUtils.getHeaders(),
      body: jsonEncode({
        'country_id': countryID,
        'state_id': stateID,
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        mounted
            ? setState(() {
                countryListReciver.clear();
                stateListReciver.clear();
                cityListReciver.clear();
                areaModel = AreaModel.fromJson(data);
                var countryDataRes = AreaModel.fromJson(data);
                countryListReciver = countryDataRes.areas.countries
                    .map((country) => country.countryName)
                    .toList(); //get Name Country and add to countryList
                countryFlagList = countryDataRes.areas.countries
                    .map((country) => country.countryCode)
                    .toList(); //get code Country and add to countryFlag to render flag
                // wardList.clear();
                countryIDList = countryDataRes.areas.countries
                    .map((country) => country.countryId)
                    .toList(); //get ID Country and add to countryIDList

                stateListReciver = countryDataRes.areas.states
                    .map((state) => state.stateName)
                    .toList(); //get Name State and add to cityList

                stateIDList = countryDataRes.areas.states
                    .map((state) => state.stateId)
                    .toList(); //get ID state and add to stateIDList

                cityListReciver = countryDataRes.areas.cities
                    .map((city) => city.cityName)
                    .toList();
                cityIDList = countryDataRes.areas.cities
                    .map((city) => city.cityId)
                    .toList(); //get ID state and add to stateIDList
              })
            : null;
      } else if (response.statusCode == 401) {
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: "Hết phiên đăng nhập",
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {
              StorageUtils.instance.removeKey(key: 'token');
              StorageUtils.instance.removeKey(key: 'branch_response');
              navigatorKey.currentContext?.go('/');
            },
            isTwoButton: false);
      } else {
        log("ERROR handleGetAreaGobal 1");
      }
    } catch (error) {
      log("ERROR handleGetAreaGobal $error 2");
    }
  }

  Future<void> handleGetAreaVN({
    required int? cityID,
    required int? districtID,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$getAreaVNApi'),
      headers: ApiUtils.getHeaders(),
      body: jsonEncode({
        'city': cityID,
        'district': districtID,
      }),
    );
    final data = jsonDecode(response.body);
    try {
      if (data['status'] == 200) {
        mounted
            ? setState(() {
                cityListSender.clear();
                districListSender.clear();
                wardListSender.clear();

                var areaVNDataRes = AreaVnModel.fromJson(data);

                cityListSender =
                    List<String>.from(areaVNDataRes.areas.cities ?? []);
                districListSender =
                    List<String>.from(areaVNDataRes.areas.districts ?? []);
                wardListSender =
                    List<String>.from(areaVNDataRes.areas.wards ?? []);
              })
            : null;
      } else if (response.statusCode == 401) {
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: "Hết phiên đăng nhập",
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {
              StorageUtils.instance.removeKey(key: 'token');
              StorageUtils.instance.removeKey(key: 'branch_response');
              navigatorKey.currentContext?.go('/');
            },
            isTwoButton: false);
      } else {
        log("ERROR AREA 1");
      }
    } catch (error) {
      log("ERROR AREA  2 $error");
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

  Future<void> initAreaFieldSender() async {
    if (currentIDCitySender != null &&
        currentIDCitySender! >= 0 &&
        currentIDCitySender! < cityListSender.length) {
      controllers['cityNameSender']!.text =
          cityListSender[currentIDCitySender!];
    }

    if (currentIDDistricSender != null &&
        currentIDDistricSender! >= 0 &&
        currentIDDistricSender! < districListSender.length) {
      controllers['districNameSender']!.text =
          districListSender[currentIDDistricSender!];
    }

    if (currentIDWardSender != null &&
        currentIDWardSender! >= 0 &&
        currentIDWardSender! < wardListSender.length) {
      controllers['wardNameSender']!.text =
          wardListSender[currentIDWardSender!];
    }
  }

// Thêm hàm validation
  bool validateShipmentData() {
    // Validate thông tin người gửi
    if (controllers['companySender']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập tên công ty người gửi");
      return false;
    }
    if (controllers['contactNameSender']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập tên người liên hệ bên gửi");
      return false;
    }
    if (controllers['phoneSender']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập số điện thoại người gửi");
      return false;
    }
    if (currentIDCitySender == null) {
      showErrorDialog("Vui lòng chọn thành phố người gửi");
      return false;
    }
    if (currentIDDistricSender == null) {
      showErrorDialog("Vui lòng chọn quận/huyện người gửi");
      return false;
    }
    if (currentIDWardSender == null) {
      showErrorDialog("Vui lòng chọn phường/xã người gửi");
      return false;
    }
    if (controllers['addressSender']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập địa chỉ người gửi");
      return false;
    }

    // Validate thông tin người nhận
    if (controllers['companyReciver']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập tên công ty người nhận");
      return false;
    }
    if (controllers['contactNameReciver']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập tên người liên hệ bên nhận");
      return false;
    }
    if (controllers['phoneReciver']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập số điện thoại người nhận");
      return false;
    }
    if (currentIDCountryReciver == null) {
      showErrorDialog("Vui lòng chọn quốc gia người nhận");
      return false;
    }
    if (controllers['address1Reciver']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập địa chỉ người nhận");
      return false;
    }

    // Validate thông tin hàng hóa
    if (controllers['goodsNameText']?.text.isEmpty ?? true) {
      showErrorDialog("Vui lòng nhập tên hàng hóa");
      return false;
    }
    if (packageList == null) {
      showErrorDialog("Vui lòng thêm ít nhất một kiện hàng");
      return false;
    }

    return true;
  }

  void showErrorDialog(String message) {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return ErrorDialog(
          errorText: message,
          eventConfirm: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void handleCreateShipment() async {
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    final String normalizedPosition = position!.trim().toLowerCase();
    // Validate dữ liệu trước khi gửi
    if (!validateShipmentData()) {
      setState(() {
        isLoadingButtonCreateShipment = false;
      });
      return;
    }

    setState(() {
      isLoadingButtonCreateShipment = true;
    });

    // Chuẩn bị dữ liệu shipment
    final Map<String, dynamic> shipmentData = {
      'shipment_code': detailsShipmentToUpdate?.shipment.shipmentCode,
      'shipment_id': detailsShipmentToUpdate?.shipment.shipmentId,
      // Thông tin người gửi
      'sender_company_name': controllers['companySender']!.text.trim(),
      'sender_contact_name': controllers['contactNameSender']!.text.trim(),
      'sender_telephone': controllers['phoneSender']!.text.trim(),
      'sender_city': currentIDCitySender,
      'sender_district': currentIDDistricSender,
      'sender_ward': currentIDWardSender,
      'sender_address': controllers['addressSender']!.text.trim(),

      // Thông tin người nhận
      'receiver_id': currentOldReceiverID,
      'receiver_company_name': controllers['companyReciver']!.text.trim(),
      'receiver_contact_name': controllers['contactNameReciver']!.text.trim(),
      'receiver_telephone': controllers['phoneReciver']!.text.trim(),
      'receiver_country_id': currentIDCountryReciver,
      'receiver_state_id': currentIDStateReciver,
      'receiver_state_name': controllers['stateNameReceiver']!.text.trim(),
      'receiver_city_id': currentIDCityReciver,
      'receiver_postal_code': controllers['postalCodeReciver']!.text.trim(),
      'receiver_address_1': controllers['address1Reciver']!.text.trim(),
      'receiver_address_2': controllers['address2Reciver']?.text.trim() ?? '',
      'receiver_address_3': controllers['address3Reciver']?.text.trim() ?? '',

//Thông tin thanh toán
      'shipment_paid_by': selectedPaymentMethod,

//Thông tin Phụ phí
      'shipment_domestic_charges':
          controllers['cuocNoiDia']!.text.trim().isEmpty
              ? 0
              : controllers['cuocNoiDia']!.text.trim(),
      'shipment_amount_surcharge':
          controllers['cuocPhuThu']!.text.trim().isEmpty
              ? 0
              : controllers['cuocPhuThu']!.text.trim(),
      'shipment_collection_fee': controllers['cuocThuHo']!.text.trim().isEmpty
          ? 0
          : controllers['cuocThuHo']!.text.trim(),
      'shipment_amount_insurance':
          controllers['cuocPhiBaoHiem']!.text.trim().isEmpty
              ? 0
              : controllers['cuocPhiBaoHiem']!.text.trim(),
      'shipment_amount_vat': controllers['giaCuocVAT']!.text.trim().isEmpty
          ? 0
          : controllers['giaCuocVAT']!.text.trim(),
      'shipment_amount_original': controllers['cuocGoc']!.text.trim().isEmpty
          ? 0
          : controllers['cuocGoc']!.text.trim(),
      'shipment_amount_total_customer':
          controllers['thuKhach']!.text.trim().isEmpty
              ? 0
              : controllers['thuKhach']!.text.trim(),

      // Thông tin dịch vụ
      'save_receiver_flg': saveInforReceiver,
      'shipment_service_id': currentShipmentServiceID,
      'shipment_signature_flg': signatureServiceReceiver,
      'shipment_branch_id': currentBrandID,
      'shipment_reference_code': controllers['referenceCode']!.text.trim(),
      'agree_terms_use_service': agreePersonalData,

      // Thông tin hàng hóa
      'shipment_goods_name': controllers['goodsNameText']!.text.trim(),
      'shipment_value':
          controllers['goodsInvoiceValue']!.text.replaceAll(',', ''),
      'shipment_export_as': currentExportAsIndex.toString(),
      'packages': packageList,
      'invoices': invoiceList,
    };

// Thêm các field optional nếu có
    if (serviceTypeID != null) {
      shipmentData['shipment_service_promotion_id'] = serviceTypeID;
    }
    if (controllers['fwdID']?.text.isNotEmpty ?? false) {
      shipmentData['fwd_id'] = controllers['fwdID']!.text.trim();
    }
    if (controllers['longitudeSender']?.text.isNotEmpty ?? false) {
      shipmentData['sender_longitude'] =
          controllers['longitudeSender']!.text.trim();
    }
    if (controllers['latitudeSender']?.text.isNotEmpty ?? false) {
      shipmentData['sender_latitude'] =
          controllers['latitudeSender']!.text.trim();
    }

    try {
      var urlShipment = widget.shipmentCode == null
          ? '$baseUrl$createNewShipment'
          : '$baseUrl$updateShipmentApi';

      final response = await http.post(
        Uri.parse(urlShipment),
        headers: ApiUtils.getHeaders(isNeedToken: true),
        body: jsonEncode({"shipment": shipmentData}),
      );

      print('Request data: ${jsonEncode(shipmentData)}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        var mess = data['message'];
        if (mounted) {
          setState(() {
            isFinishCreateShipment = true;
            showCustomDialogModal(
                isCanCloseWhenTouchOutside: false,
                isShowCloseIcon: false,
                context: navigatorKey.currentContext!,
                textDesc: mess,
                title: "Thành công",
                colorButtonOk: Colors.green,
                colorButtonCancle: Colors.blue,
                btnOKText: "Về trang chủ",
                btnCancleText: "Danh sách đơn",
                typeDialog: "success",
                eventButtonOKPress: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                eventButtonCanclePress: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PackageManagerScreen(
                        // Pass user position as parameter
                        userPosition: normalizedPosition,
                        // Pass permissions as boolean flags
                        canUploadLabel: normalizedPosition != 'sale' &&
                            normalizedPosition != 'fwd' &&
                            normalizedPosition != 'ops-leader' &&
                            normalizedPosition != 'ops_pickup',
                        canUploadPayment: normalizedPosition != 'fwd' &&
                            normalizedPosition != 'document' &&
                            normalizedPosition != 'accountant',
                      ),
                    ),
                  );
                },
                isTwoButton: true);
            isLoadingButtonCreateShipment = false;
          });
        }
      } else if (response.statusCode == 401) {
        showCustomDialogModal(
            context: navigatorKey.currentContext!,
            textDesc: "Hết phiên đăng nhập",
            title: "Thông báo",
            colorButtonOk: Colors.red,
            btnOKText: "Xác nhận",
            typeDialog: "error",
            eventButtonOKPress: () {
              StorageUtils.instance.removeKey(key: 'token');
              StorageUtils.instance.removeKey(key: 'branch_response');
              navigatorKey.currentContext?.go('/');
            },
            isTwoButton: false);
      } else {
        var errorText = data['message'];
        showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return ErrorDialog(
              errorText: errorText is String ? errorText : errorText['text'],
              eventConfirm: () {
                Navigator.pop(context);
              },
            );
          },
        );
        setState(() {
          isLoadingButtonCreateShipment = false;
        });
      }
    } catch (error) {
      log("handleCreateShipment error $error");
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return ErrorDialog(
              eventConfirm: () {
                Navigator.pop(context);
              },
            );
          });
      setState(() {
        isLoadingButtonCreateShipment = false;
      });
    }
  }

  void editPackage(int index) {
    setState(() {
      editingPackageIndex = index;
      final package = packageList![index];
      controllers['goodsQuantity']!.text = package.packageQuantity.toString();
      controllers['goodsTypeText']!.text =
          allUnitShipmentModel!.data.packageTypes[package.packageType];
      currentGoodTypeIndex = package.packageType;
      controllers['goodsLengthValue']!.text = package.packageLength.toString();
      controllers['goodsWidthValue']!.text = package.packageWidth.toString();
      controllers['goodsHeigthValue']!.text = package.packageHeight.toString();
      controllers['goodsWeightValue']!.text = package.packageWeight.toString();
    });
  }

  void editInvoice(int index) {
    setState(() {
      editingInvoiceIndex = index;
      final invoice = invoiceList![index];
      controllers['invoiceGoodsDetails']!.text =
          invoice.invoiceGoodsDetails.toString();
      controllers['invoiceQuantityText']!.text =
          invoice.invoiceQuantity.toString();
      controllers['invoiceUnitText']!.text =
          allUnitShipmentModel!.data.invoiceUnits[invoice.invoiceUnit];
      currentInvoiceUnitIndex = invoice.invoiceUnit;
      controllers['invoicePriceText']!.text = invoice.invoicePrice.toString();
      controllers['invoiceTotalValue']!.text =
          invoice.invoiceTotalPrice.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isFinishCreateShipment) {
          Navigator.pop(context);
          return true;
        } else {
          showCustomDialogModal(
              context: navigatorKey.currentContext!,
              textDesc: widget.shipmentCode == null
                  ? "Bạn chưa hoàn thành việc tạo shipment. \n Bạn có chắc muốn thoát ?"
                  : "Bạn chưa đang cập nhật shipment. \n Bạn có chắc muốn thoát ?",
              title: "Thông báo",
              colorButtonOk: Colors.green,
              colorButtonCancle: Colors.red,
              btnOKText: "Xác nhận",
              btnCancleText: "Đóng",
              typeDialog: "question",
              eventButtonOKPress: () {
                Navigator.pop(context);
              },
              eventButtonCanclePress: () {},
              isTwoButton: true);
          return false;
        }
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.black, //change your color here
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.white,
            title: TextApp(
              text: widget.shipmentCode == null
                  ? "Create Shipment"
                  : "Update Shipment",
              fontsize: 20.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            leading: InkWell(
                onTap: () => {
                      isFinishCreateShipment
                          ? Navigator.pop(context)
                          : showCustomDialogModal(
                              context: navigatorKey.currentContext!,
                              textDesc: widget.shipmentCode == null
                                  ? "Bạn chưa hoàn thành việc tạo shipment. \n Bạn có chắc muốn thoát ?"
                                  : "Bạn chưa đang cập nhật shipment. \n Bạn có chắc muốn thoát ?",
                              title: "Thông báo",
                              colorButtonOk: Colors.green,
                              colorButtonCancle: Colors.red,
                              btnOKText: "Xác nhận",
                              btnCancleText: "Đóng",
                              typeDialog: "question",
                              eventButtonOKPress: () {
                                Navigator.pop(context);
                              },
                              eventButtonCanclePress: () {},
                              isTwoButton: true)
                    },
                child: Container(
                  // margin: EdgeInsets.only(right: 15.w),
                  width: 50.w,
                  height: 50.w,
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                    size: 32.sp,
                  ),
                )),
          ),
          body: SlidableAutoCloseBehavior(
            child: SafeArea(
                child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // Close any open slidable when tapping outside
                Slidable.of(context)?.close();
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: CustomStepper(
                          context: context,
                          stepRadius: 25.w,
                          enableStepTapping:
                              false, // Chỗ này chỉnh để có thể bấm vô step hoặc sẽ không bấm được
                          lineStyle: const CustomLineStyle(
                            lineLength: 100,
                            lineType: CustomLineType.normal,
                            unreachedLineType: CustomLineType.dotted,
                          ),
                          activeStep: currentForm,
                          direction: Axis.horizontal,
                          unreachedStepIconColor: Colors.white,
                          unreachedStepBorderColor: Colors.transparent,
                          finishedStepBackgroundColor:
                              Theme.of(context).colorScheme.primary,
                          unreachedStepBackgroundColor: Colors.grey,
                          activeStepBackgroundColor:
                              Theme.of(context).primaryColor,
                          showTitle: true,
                          onStepReached: (index) =>
                              setState(() => currentForm = index),
                          steps: _buildSteps(),
                        ),
                      ),
                      sectionController()
                    ]),
                  ),
                ],
              ),
            )),
          )),
    );
  }

  List<CustomStep> _buildSteps() {
    // Base steps - Các bước cơ bản luôn hiển thị
    final List<CustomStep> baseSteps = [
      const CustomStep(
        icon: Icon(Icons.send, size: 20), // Giảm size icon cho tinh tế hơn
        activeIcon: 'assets/lottie/loadingstep.json',
        finishIcon: Icon(Icons.check_circle,
            color: Colors.white, size: 20), // Dùng check_circle thay check
        title: 'Người gửi',
        isActiveLottie: true,
      ),
      const CustomStep(
        icon: Icon(Icons.get_app, size: 20),
        activeIcon: 'assets/lottie/loadingstep.json',
        finishIcon: Icon(Icons.check_circle, color: Colors.white, size: 20),
        title: 'Người nhận',
        isActiveLottie: true,
      ),
      const CustomStep(
        icon: Icon(Icons.info, size: 20),
        activeIcon: 'assets/lottie/loadingstep.json',
        finishIcon: Icon(Icons.check_circle, color: Colors.white, size: 20),
        title: 'Đơn hàng',
        isActiveLottie: true,
      ),
      const CustomStep(
        icon: Icon(Icons.inbox, size: 20),
        activeIcon: 'assets/lottie/loadingstep.json',
        finishIcon: Icon(Icons.check_circle, color: Colors.white, size: 20),
        title: 'Kiện hàng',
        isActiveLottie: true,
      ),
      const CustomStep(
        icon: Icon(Icons.receipt,
            size: 20), // Thay inbox bằng receipt cho Invoice
        activeIcon: 'assets/lottie/loadingstep.json',
        finishIcon: Icon(Icons.check_circle, color: Colors.white, size: 20),
        title: 'Invoice',
        isActiveLottie: true,
      ),
    ];

    // Additional steps - Các bước bổ sung cho sale position
    final List<CustomStep> saleSteps = [
      const CustomStep(
        icon: Icon(Icons.payment, size: 20),
        activeIcon: 'assets/lottie/loadingstep.json',
        finishIcon: Icon(Icons.check_circle, color: Colors.white, size: 20),
        title: 'Thanh toán',
        isActiveLottie: true,
      ),
      const CustomStep(
        icon: Icon(Icons.monetization_on, size: 20),
        activeIcon: 'assets/lottie/loadingstep.json',
        finishIcon: Icon(Icons.check_circle, color: Colors.white, size: 20),
        title: 'Phụ thu',
        isActiveLottie: true,
      ),
    ];

    // Logic thêm steps cho sale user
    // Note: widget.isSale cần được định nghĩa trong class chứa CustomStepper
    if (widget.isSale == true) {
      baseSteps.addAll(saleSteps);
    }

    return baseSteps;
  }

  sectionController() {
    if (widget.shipmentCode != null && currentForm > 4) {
      setState(() {
        currentForm = 4;
      });
    }
    switch (currentForm) {
      case 0:
        return isLoadingPageSender
            ? Center(
                child: SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: Lottie.asset('assets/lottie/loading_kango.json'),
                ),
              )
            : FormShipment1(
                formField: _formField,
                fwdAccountController: controllers['fwdReciver']!,
                companySenderController: controllers['companySender']!,
                contactNameSenderController: controllers['contactNameSender']!,
                phoneSenderController: controllers['phoneSender']!,
                cityNameSenderController: controllers['cityNameSender']!,
                districNameSenderController: controllers['districNameSender']!,
                wardNameSenderController: controllers['wardNameSender']!,
                addressSenderController: controllers['addressSender']!,
                longitudeSenderController: controllers['longitudeSender']!,
                latitudeSenderController: controllers['latitudeSender']!,
                cityListSender: cityListSender,
                districListSender: districListSender,
                wardListSender: wardListSender,
                eventChooseFWD: () {
                  showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15.r),
                        topLeft: Radius.circular(15.r),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return DraggableScrollableSheet(
                        maxChildSize: 0.8,
                        initialChildSize: 0.8,
                        expand: false,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 50.w,
                                  height: 5.w,
                                  margin:
                                      EdgeInsets.only(top: 15.h, bottom: 15.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: Colors.grey,
                                  ),
                                ),
                                Container(
                                  width: 1.sw,
                                  padding: EdgeInsets.all(15.w),
                                  child: TextFormField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    onFieldSubmitted: (value) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      onGetListSale(keywords: value);
                                    },
                                    // onChanged: searchProduct,
                                    controller: controllers['search'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            log(controllers['search']!.text);
                                            onGetListSale(
                                                keywords: controllers['search']!
                                                    .text);
                                          },
                                          child: const Icon(Icons.search),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        isDense: true,
                                        hintText: "Tìm kiếm...",
                                        contentPadding:
                                            const EdgeInsets.all(15)),
                                  ),
                                ),
                                BlocBuilder<GetListSaleScreenBloc,
                                        HandleGetListSaleState>(
                                    builder: (context, state) {
                                  if (state is HandleGetListSaleLoading) {
                                    return Center(
                                      child: SizedBox(
                                        width: 100.w,
                                        height: 100.w,
                                        child: Lottie.asset(
                                            'assets/lottie/loading_kango.json'),
                                      ),
                                    );
                                  } else if (state
                                      is HandleGetListSaleSuccess) {
                                    return Expanded(
                                        child: state.data.isEmpty
                                            ? const NoDataFoundWidget()
                                            : SizedBox(
                                                width: 1.sw,
                                                child: ListView.builder(
                                                    shrinkWrap: true,
                                                    // padding: EdgeInsets.only(top: 10.w),
                                                    controller:
                                                        scrollListFWDController,
                                                    itemCount: state
                                                            .hasReachedMax
                                                        ? state.data.length
                                                        : state.data.length + 1,
                                                    itemBuilder:
                                                        (context, index) {
                                                      if (index >=
                                                          state.data.length) {
                                                        return Center(
                                                          child: SizedBox(
                                                            width: 100.w,
                                                            height: 100.w,
                                                            child: Lottie.asset(
                                                                'assets/lottie/loading_kango.json'),
                                                          ),
                                                        );
                                                      } else {
                                                        final dataSale =
                                                            state.data[index];
                                                        return Column(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          15.w),
                                                              child: InkWell(
                                                                onTap:
                                                                    () async {
                                                                  Navigator.pop(
                                                                      context);

                                                                  mounted
                                                                      ? setState(
                                                                          () {
                                                                          controllers['fwdReciver']!.text =
                                                                              "${dataSale.userContactName} [${dataSale.userCode}]";
                                                                          controllers['fwdID']!.text = dataSale
                                                                              .userId
                                                                              .toString();
                                                                        })
                                                                      : null;
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                      width: 1.sw -
                                                                          80.w,
                                                                      child:
                                                                          TextApp(
                                                                        text:
                                                                            "${dataSale.userContactName} [${dataSale.userCode}]",
                                                                        color: Colors
                                                                            .black,
                                                                        fontsize:
                                                                            16.sp,
                                                                        maxLines:
                                                                            3,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            Divider(
                                                              height: 25.h,
                                                            )
                                                          ],
                                                        );
                                                      }
                                                    }),
                                              ));
                                  } else if (state
                                      is HandleGetListSaleFailure) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          ErrorDialog(
                                            eventConfirm: () {
                                              Navigator.pop(context);
                                            },
                                            errorText: state.message,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const Center(
                                      child: NoDataFoundWidget());
                                })
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                eventFormCity: () {
                  showMyCustomModalBottomSheet(
                      context: context,
                      height: 0.6,
                      isScroll: true,
                      itemCount: cityListSender.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  handleGetAreaVN(
                                      cityID: index, districtID: null);
                                  setState(() {
                                    controllers['cityNameSender']!.text =
                                        cityListSender[index];
                                    currentIDCitySender = index;
                                    controllers['districNameSender']!.clear();
                                    controllers['wardNameSender']!.clear();
                                    currentIDDistricSender = null;
                                    currentIDWardSender = null;
                                  });
                                },
                                child: Row(
                                  children: [
                                    TextApp(
                                      text: cityListSender[index],
                                      color: Colors.black,
                                      fontsize: 20.sp,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 25.h,
                            )
                          ],
                        );
                      });
                },
                eventFormDistric: () {
                  showMyCustomModalBottomSheet(
                      context: context,
                      height: 0.6,
                      isScroll: true,
                      itemCount: districListSender.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  handleGetAreaVN(
                                      cityID: currentIDCitySender,
                                      districtID: index);
                                  setState(() {
                                    controllers['districNameSender']!.text =
                                        districListSender[index];
                                    currentIDDistricSender = index;
                                    controllers['wardNameSender']!.clear();
                                    currentIDWardSender = null;
                                  });
                                },
                                child: Row(
                                  children: [
                                    TextApp(
                                      text: districListSender[index],
                                      color: Colors.black,
                                      fontsize: 20.sp,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 25.h,
                            )
                          ],
                        );
                      });
                },
                eventFormWard: () {
                  showMyCustomModalBottomSheet(
                      context: context,
                      height: 0.6,
                      isScroll: true,
                      itemCount: wardListSender.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20.w),
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  setState(() {
                                    controllers['wardNameSender']!.text =
                                        wardListSender[index];
                                    currentIDWardSender = index;
                                  });
                                },
                                child: Row(
                                  children: [
                                    TextApp(
                                      text: wardListSender[index],
                                      color: Colors.black,
                                      fontsize: 20.sp,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 25.h,
                            )
                          ],
                        );
                      });
                },
                eventNextButton: () {
                  log({
                    'fwd_id': controllers['fwdID']!.text,
                    'sender_longitude': controllers['longitudeSender']!.text,
                    'sender_latitude': controllers['latitudeSender']!.text,
                  }.toString());
                  mounted
                      ? setState(() {
                          currentForm = 1;
                        })
                      : null;
                });
      case 1:
        return FormShipment2(
            formField: _formField2,
            chooseOldReciverController: controllers['chooseOldReciver']!,
            companyReciverController: controllers['companyReciver']!,
            contactNameReciverController: controllers['contactNameReciver']!,
            phoneReciverController: controllers['phoneReciver']!,
            countryNameReceiverController: controllers['countryNameReceiver']!,
            stateNameReceiverController: controllers['stateNameReceiver']!,
            cityNameReceiverController: controllers['cityNameReceiver']!,
            postalCodeReciverController: controllers['postalCodeReciver']!,
            address1ReciverController: controllers['address1Reciver']!,
            address2ReciverController: controllers['address2Reciver']!,
            address3ReciverController: controllers['address3Reciver']!,
            countryListReciver: countryListReciver,
            countryFlagList: countryFlagList,
            stateListReciver: stateListReciver,
            cityListReciver: cityListReciver,
            onReceiverNameChanged: (value) {
              setState(() {
                currentIDStateReciver = null; // Set ID về null khi nhập tay
                controllers['cityNameReceiver']?.clear(); // Clear city
                currentIDCityReciver = null;
              });
            },
            eventFormCountry: () {
              List filteredCountries = List<String>.from(countryListReciver);
              showMyCustomModalBottomSheet(
                context: context,
                isScroll: true,
                itemCount: 1,
                searchWidget: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.sp,
                      fontFamily: "OpenSans",
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm quốc gia...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.w,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 10.h),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredCountries = value.isEmpty
                            ? List<String>.from(countryListReciver)
                            : countryListReciver
                                .where((country) => country
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                      });
                    },
                  ),
                ),
                itemBuilder: (context, _) {
                  return Padding(
                    padding: EdgeInsets.only(right: 20.h, left: 20.h),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.62,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: filteredCountries.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Không tìm thấy quốc gia nào',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: filteredCountries.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final country = filteredCountries[index];
                                      final originalIndex =
                                          countryListReciver.indexOf(country);
                                      final countryId = countryIDList
                                          ?.elementAtOrNull(originalIndex);
                                      final countryFlag = countryFlagList
                                              .elementAtOrNull(originalIndex) ??
                                          '';

                                      return InkWell(
                                        onTap: () {
                                          if (countryId != null) {
                                            Navigator.pop(context);
                                            handleGetAreaGobal(
                                                countryID: countryId,
                                                stateID: null);
                                            setState(() {
                                              controllers['countryNameReceiver']
                                                  ?.text = country;
                                              currentIDCountryReciver =
                                                  countryId;
                                              controllers['stateNameReceiver']
                                                  ?.clear();
                                              controllers['cityNameReceiver']
                                                  ?.clear();
                                              currentIDStateReciver = null;
                                              currentIDCityReciver = null;
                                            });
                                            getDeliveryService();
                                          }
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.h, horizontal: 10.w),
                                          child: Row(
                                            children: [
                                              if (countryFlag.isNotEmpty)
                                                CountryFlag.fromCountryCode(
                                                  countryFlag,
                                                  height: 35.sp,
                                                  width: 35.sp,
                                                ),
                                              SizedBox(width: 10.w),
                                              Expanded(
                                                child: Text(
                                                  country,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20.sp,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            eventFormState: () {
              List filteredStates = List<String>.from(stateListReciver);
              showMyCustomModalBottomSheet(
                context: context,
                isScroll: true,
                itemCount:
                    1, // Đổi thành 1 vì sẽ dùng ListView.builder bên trong
                searchWidget: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.sp,
                      fontFamily: "OpenSans",
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tỉnh/bang...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.w,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 10.h),
                    ),
                    onChanged: (value) {
                      filteredStates = value.isEmpty
                          ? List<String>.from(stateListReciver)
                          : stateListReciver
                              .where((state) => state
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                    },
                  ),
                ),
                itemBuilder: (context, _) {
                  return StatefulBuilder(
                    builder: (context, setStateModal) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 20.h, right: 20.h, bottom: 20.h),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.62,
                          child: Column(
                            children: [
                              Expanded(
                                child: filteredStates.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Không tìm thấy tỉnh/bang nào',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredStates.length,
                                        itemBuilder: (context, index) {
                                          final state = filteredStates[index];
                                          final originalIndex =
                                              stateListReciver.indexOf(state);
                                          final stateId = stateIDList
                                              ?.elementAtOrNull(originalIndex);

                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20.w),
                                                child: InkWell(
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    handleGetAreaGobal(
                                                      countryID:
                                                          currentIDCountryReciver,
                                                      stateID: stateId,
                                                    );
                                                    setState(() {
                                                      controllers[
                                                              'stateNameReceiver']!
                                                          .text = state;
                                                      currentIDStateReciver =
                                                          stateId;

                                                      controllers[
                                                              'cityNameReceiver']!
                                                          .clear();
                                                      currentIDCityReciver =
                                                          null;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      TextApp(
                                                        text: state,
                                                        color: Colors.black,
                                                        fontsize: 20.sp,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Divider(height: 25.h)
                                            ],
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            eventFormCity: () {
              List filteredCities = List<String>.from(cityListReciver);

              showMyCustomModalBottomSheet(
                context: context,
                isScroll: true,
                itemCount:
                    1, // Đổi thành 1 vì sẽ dùng ListView.builder bên trong
                searchWidget: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.sp,
                      fontFamily: "OpenSans",
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm thành phố...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontSize: 15.w,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 10.h),
                    ),
                    onChanged: (value) {
                      filteredCities = value.isEmpty
                          ? List<String>.from(cityListReciver)
                          : cityListReciver
                              .where((city) => city
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                    },
                  ),
                ),
                itemBuilder: (context, _) {
                  return StatefulBuilder(
                    builder: (context, setStateModal) {
                      return Padding(
                        padding: EdgeInsets.only(right: 20.h, left: 20.h),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.62,
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: filteredCities.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Không tìm thấy thành phố nào',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredCities.length,
                                        itemBuilder: (context, index) {
                                          final city = filteredCities[index];
                                          final originalIndex =
                                              cityListReciver.indexOf(city);
                                          final cityId = cityIDList
                                              ?.elementAtOrNull(originalIndex);
// Thêm dòng này để lấy statePostCode
                                          final cityPostCode = areaModel!
                                              .areas.cities
                                              .firstWhere(
                                                  (c) => c.cityId == cityId,
                                                  orElse: () => City(
                                                      cityId: -1,
                                                      cityName: "",
                                                      cityCode: "",
                                                      cityPostCode: null))
                                              .cityPostCode;
                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20.w),
                                                child: InkWell(
                                                  onTap: () async {
                                                    if (currentIDStateReciver ==
                                                        0) {
                                                      handleGetAreaGobal(
                                                        countryID:
                                                            currentIDCountryReciver,
                                                        stateID: null,
                                                      );
                                                    } else {
                                                      handleGetAreaGobal(
                                                        countryID:
                                                            currentIDCountryReciver,
                                                        stateID:
                                                            currentIDStateReciver,
                                                      );
                                                    }
                                                    setState(() {
                                                      controllers[
                                                              'cityNameReceiver']!
                                                          .text = city;

                                                      currentIDCityReciver =
                                                          cityId;
                                                      log(cityPostCode
                                                          .toString());
                                                      controllers[
                                                              'postalCodeReciver']!
                                                          .text = cityPostCode !=
                                                              null
                                                          ? cityPostCode
                                                              .toString()
                                                          : "";
                                                    });

                                                    Navigator.pop(context);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      TextApp(
                                                        text: city,
                                                        color: Colors.black,
                                                        fontsize: 20.sp,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Divider(height: 25.h),
                                            ],
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            eventBackButton: () {
              mounted
                  ? setState(() {
                      currentForm = 0;
                    })
                  : null;
            },
            eventNextButton: () async {
              await getDeliveryService();
              if (_formField2.currentState!.validate()) {
                if (!saveInforReceiver &&
                    deliveryServiceMode!.services.isNotEmpty) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc:
                          "Bạn có muốn lưu thông tin của người nhận này không ?",
                      title: "Thông báo",
                      colorButtonOk: Colors.blue,
                      colorButtonCancle: Colors.red,
                      btnOKText: "Lưu thông tin",
                      typeDialog: "info",
                      btnCancleText: "Bỏ qua",
                      eventButtonCanclePress: () {
                        mounted
                            ? setState(() {
                                currentForm = 2;
                              })
                            : null;
                      },
                      eventButtonOKPress: () {
                        mounted
                            ? setState(() {
                                saveInforReceiver = true;
                                currentForm = 2;
                              })
                            : null;
                      },
                      isTwoButton: true);
                } else if (deliveryServiceMode!.services.isEmpty) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc:
                          "Chưa có dịch vụ vận chuyển ở quốc gia này. \n Việc hoàn thành đơn không thể thực hiện!",
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      colorButtonCancle: Colors.blue,
                      btnOKText: "Về trang chủ",
                      btnCancleText: "Chọn lại",
                      typeDialog: "info",
                      eventButtonOKPress: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      eventButtonCanclePress: () {},
                      isTwoButton: true);
                } else {
                  mounted
                      ? setState(() {
                          currentForm = 2;
                        })
                      : null;
                }
              }
            },
            checkBoxSaveInforReceiver: Checkbox(
              checkColor: Theme.of(context).colorScheme.background,
              value: saveInforReceiver,
              onChanged: (bool? value) {
                mounted
                    ? setState(() {
                        saveInforReceiver = value!;
                      })
                    : null;
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            listOldReceiverModel: listOldReceiverModel,
            eventChooseOldReciver: () {
              showMyCustomModalBottomSheet(
                  context: context,
                  height: 0.6,
                  isScroll: true,
                  itemCount: listOldReceiverModel!.receivers.length,
                  itemBuilder: (context, index) {
                    return listOldReceiverModel!.receivers.isEmpty
                        ? const NoDataFoundWidget()
                        : Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20.w),
                                child: InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);

                                    // First, reset all the necessary values
                                    setState(() {
                                      // Reset IDs first
                                      currentIDCountryReciver = null;
                                      currentIDStateReciver = null;
                                      currentIDCityReciver = null;

                                      // Reset controller text values
                                      controllers['countryNameReceiver']!.text =
                                          '';
                                      controllers['stateNameReceiver']!.text =
                                          '';
                                      controllers['cityNameReceiver']!.text =
                                          controllers['postalCodeReciver']!
                                              .text = '';
                                    });

                                    // Then in a separate setState, set the receiver information
                                    setState(() {
                                      // Set receiver name and ID
                                      controllers['chooseOldReciver']!.text =
                                          listOldReceiverModel?.receivers[index]
                                                  .receiverContactName ??
                                              '';
                                      currentOldReceiverID =
                                          listOldReceiverModel
                                              ?.receivers[index].receiverId;
                                    });

                                    // Finally, call the handler if needed
                                    if (currentOldReceiverID != null) {
                                      handleGetInforOldReciever(
                                          receiverID: currentOldReceiverID!);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.person,
                                          color: Colors.black, size: 28.sp),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      TextApp(
                                        text: listOldReceiverModel
                                                ?.receivers[index]
                                                .receiverContactName ??
                                            '',
                                        color: Colors.black,
                                        fontsize: 20.sp,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                height: 25.h,
                              )
                            ],
                          );
                  });
            });

      case 2:
        return FormShipment3(
            formField: _formField3,
            serviceTypeTextController: controllers['serviceType']!,
            serviceTextController: controllers['serviceText']!,
            branchTextController: controllers['branchText']!,
            referenceCodeController: controllers['referenceCode']!,
            eventTypeService: () {
              showMyCustomModalBottomSheet(
                  context: context,
                  height: 0.6,
                  isScroll: true,
                  itemCount: listTypeServiceModel!.serviceTypes.length,
                  itemBuilder: (context, index) {
                    String key = listTypeServiceModel!.serviceTypes.keys
                        .elementAt(index); // Get the key
                    String value = listTypeServiceModel!
                        .serviceTypes[key]!; // Get the value
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              setState(() {
                                controllers['serviceType']!.text = value;
                                log(key.toString());
                                serviceTypeID = int.parse(key);
                                getDeliveryService();
                                controllers['serviceText']!.clear();
                              });
                            },
                            child: Row(
                              children: [
                                TextApp(
                                  text: value,
                                  color: Colors.black,
                                  fontsize: 20.sp,
                                )
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 25.h,
                        )
                      ],
                    );
                  });
            },
            eventService: () {
              showMyCustomModalBottomSheet(
                  context: context,
                  height: 0.6,
                  isScroll: true,
                  itemCount: deliveryServiceMode!.services.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              setState(() {
                                controllers['serviceText']!.text =
                                    deliveryServiceMode
                                            ?.services[index].serviceName ??
                                        'DV vận chuyển Kango';
                                currentShipmentServiceID = deliveryServiceMode
                                    ?.services[index].serviceId;
                              });
                            },
                            child: Row(
                              children: [
                                TextApp(
                                  text: deliveryServiceMode
                                          ?.services[index].serviceName ??
                                      '',
                                  color: Colors.black,
                                  fontsize: 20.sp,
                                )
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 25.h,
                        )
                      ],
                    );
                  });
            },
            eventBranchText: () {
              showMyCustomModalBottomSheet(
                  context: context,
                  height: 0.6,
                  isScroll: true,
                  itemCount: branchResponse?.branchs.length ?? 0,
                  itemBuilder: (context, index) {
                    return (branchResponse!.branchs.isEmpty ||
                            branchResponse?.branchs == null)
                        ? Container()
                        : Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 20.w),
                                child: InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);
                                    setState(() {
                                      controllers['branchText']!.text =
                                          branchResponse!
                                              .branchs[index].branchName;
                                      currentBrandID = branchResponse!
                                          .branchs[index].branchId;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      TextApp(
                                        text: branchResponse!
                                            .branchs[index].branchName,
                                        color: Colors.black,
                                        fontsize: 20.sp,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                height: 25.h,
                              )
                            ],
                          );
                  });
            },
            signatureServiceReceiverCheckBox: Checkbox(
              checkColor: Theme.of(context).colorScheme.background,
              value: signatureServiceReceiver,
              onChanged: (bool? value) {
                mounted
                    ? setState(() {
                        signatureServiceReceiver = value!;
                      })
                    : null;
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            agreePersonalDataCheckBox: Checkbox(
              checkColor: Theme.of(context).colorScheme.background,
              value: agreePersonalData,
              onChanged: (bool? value) {
                mounted
                    ? setState(() {
                        agreePersonalData = value!;
                      })
                    : null;
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            eventBackButton: () {
              mounted
                  ? setState(() {
                      currentForm = 1;
                    })
                  : null;
            },
            eventNextButton: () {
              if (_formField3.currentState!.validate() &&
                  agreePersonalData == true) {
                mounted
                    ? setState(() {
                        currentForm = 3;
                      })
                    : null;
              } else if (!agreePersonalData) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: "Vui lòng tuân thủ điều khoản của Kango Express",
                    title: "Thông báo",
                    colorButtonOk: Colors.blue,
                    btnOKText: "Xác nhận",
                    typeDialog: "info",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            });

      case 3:
        return FormShipment4(
            formField: _formField4,
            goodsNameTextController: controllers['goodsNameText']!,
            goodsInvoiceValueController: controllers['goodsInvoiceValue']!,
            itemCount: packageList?.length ?? 0,
            eventAddProduct: () {
              setState(() {
                editingPackageIndex = null;
                isEditGoods = false;
                controllers['goodsQuantity']!.clear();
                controllers['goodsTypeText']!.clear();
                controllers['goodsLengthValue']!.clear();
                controllers['goodsWidthValue']!.clear();
                controllers['goodsHeigthValue']!.clear();
                controllers['goodsWeightValue']!.clear();
              });
              showCreateGoods(index: null);
            },
            allUnitShipmentModel: allUnitShipmentModel,
            packageList: packageList,
            itemBuilder: (context, index) {
              final package = packageList![index];
              return Column(
                children: [
                  const Divider(
                    height: 1,
                  ),
                  Container(
                    width: 1.sw,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0.r),
                        // color:
                        //     Theme.of(context).colorScheme.primary,
                        color: Colors.white),
                    child: Slidable(
                      key: ValueKey(packageList![index]),
                      endActionPane: ActionPane(
                        extentRatio: 0.6,
                        dragDismissible: false,
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(onDismissed: () {}),
                        children: [
                          CustomSlidableAction(
                            onPressed: (context) {
                              setState(() {
                                isEditGoods = true;
                              });
                              editPackage(index);
                              showCreateGoods(index: index);
                              // setState(() {

                              // });
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sửa',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          CustomSlidableAction(
                            onPressed: (context) {
                              setState(() {
                                packageList!.removeAt(index);
                              });
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      child: ListTile(
                          title: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.w),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                child: Center(
                                  child: TextApp(
                                    text: (index + 1).toString(),
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontsize: 18.sp,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: "Số kiện: ",
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        TextApp(
                                          text: package.packageQuantity
                                              .toString(),
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextApp(
                                            text: "Type: ",
                                            fontsize: 14.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          TextApp(
                                            text: allUnitShipmentModel!
                                                    .data.packageTypes[
                                                package.packageType],
                                            fontsize: 14.sp,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: "Length: ",
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        TextApp(
                                          text:
                                              package.packageLength.toString(),
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: "Width: ",
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        TextApp(
                                          text: package.packageWidth.toString(),
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: "Heigth: ",
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        TextApp(
                                          text:
                                              package.packageHeight.toString(),
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: "Weight: ",
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        TextApp(
                                          text:
                                              package.packageWeight.toString(),
                                          fontsize: 14.sp,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                    ),
                  ),
                ],
              );
            },
            eventNextButton: () {
              if (_formField4.currentState!.validate() &&
                  packageList!.isNotEmpty) {
                mounted
                    ? setState(() {
                        currentForm = 4;
                      })
                    : null;
              } else if (packageList!.isEmpty) {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: "Thêm ít nhất 1 sản phẩm",
                    title: "Thông báo",
                    colorButtonOk: Colors.blue,
                    btnOKText: "Xác nhận",
                    typeDialog: "info",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              }
            },
            eventBackButton: () {
              mounted
                  ? setState(() {
                      currentForm = 2;
                    })
                  : null;
            });

      case 4:
        return FormShipment5(
            formField: _formField5,
            exportAsTextController: controllers['exportAsText']!,
            stateNameReceiverController: controllers['stateNameReceiver']!,
            allUnitShipmentModel: allUnitShipmentModel,
            invoiceList: invoiceList,
            isSale: widget.isSale,
            eventExportAs: () {
              showMyCustomModalBottomSheet(
                  context: context,
                  isScroll: true,
                  height: 0.6,
                  itemCount:
                      allUnitShipmentModel?.data.invoiceExportsAs.length ?? 0,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20.w),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              setState(() {
                                controllers['exportAsText']!.text =
                                    allUnitShipmentModel
                                            ?.data.invoiceExportsAs[index] ??
                                        '';
                                currentExportAsIndex = index;
                              });
                            },
                            child: Row(
                              children: [
                                TextApp(
                                  text: allUnitShipmentModel
                                          ?.data.invoiceExportsAs[index] ??
                                      '',
                                  color: Colors.black,
                                  fontsize: 20.sp,
                                )
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 25.h,
                        )
                      ],
                    );
                  });
            },
            eventAddInvoice: () {
              setState(() {
                isEditInvoice = false;
                editingInvoiceIndex = null;
                controllers['invoiceGoodsDetails']!.clear();
                controllers['invoiceQuantityText']!.clear();
                controllers['invoiceUnitText']!.clear();
                controllers['invoicePriceText']!.clear();
                controllers['invoiceTotalValue']!.clear();
              });
              showCreateInvoice();
            },
            isLoadingButtonCreateShipment: isLoadingButtonCreateShipment,
            itemCount: invoiceList?.length ?? 0,
            itemBuilder: (context, index) {
              final invoice = invoiceList![index];
              return Column(
                children: [
                  const Divider(
                    height: 1,
                  ),
                  Container(
                    width: 1.sw,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0.r),
                      color: Colors.white,
                    ),
                    child: Slidable(
                      key: ValueKey(invoiceList![index]),
                      endActionPane: ActionPane(
                        extentRatio: 0.6,
                        dragDismissible: false,
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(onDismissed: () {}),
                        children: [
                          CustomSlidableAction(
                            onPressed: (context) {
                              setState(() {
                                isEditInvoice = true;
                              });
                              editInvoice(index);
                              showCreateInvoice();
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Sửa',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          CustomSlidableAction(
                            onPressed: (context) {
                              setState(() {
                                invoiceList!.removeAt(index);
                              });
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      child: ListTile(
                          title: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.w),
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                child: Center(
                                  child: TextApp(
                                    text: (index + 1).toString(),
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontsize: 18.sp,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextApp(
                                        text: "Số lượng: ",
                                        fontsize: 14.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      TextApp(
                                        text:
                                            invoice.invoiceQuantity.toString(),
                                        fontsize: 14.sp,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextApp(
                                        text: "Đơn vị: ",
                                        fontsize: 14.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      TextApp(
                                        text: allUnitShipmentModel!.data
                                            .invoiceUnits[invoice.invoiceUnit],
                                        fontsize: 14.sp,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextApp(
                                        text: "Giá sản phẩm: ",
                                        fontsize: 14.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      TextApp(
                                        text: invoice.invoicePrice.toString(),
                                        fontsize: 14.sp,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextApp(
                                        text: "Tổng giá trị: ",
                                        fontsize: 14.sp,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      TextApp(
                                        text: invoice.invoiceTotalPrice
                                            .toString(),
                                        fontsize: 14.sp,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextApp(
                                text: "Chi tiết: ",
                                fontsize: 14.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              Expanded(
                                child: TextApp(
                                  // isOverFlow: false,
                                  // softWrap: true,
                                  text: invoice.invoiceGoodsDetails.toString(),
                                  fontsize: 14.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )
                        ],
                      )),
                    ),
                  ),
                ],
              );
            },
            shipmentCode: widget.shipmentCode,
            eventNextButton: () {
              if (_formField5.currentState!.validate()) {
                if (widget.shipmentCode != null || widget.isSale != true) {
                  handleCreateShipment();
                } else {
                  setState(() {
                    currentForm = 5;
                  });
                }
              }
            },
            eventBackButton: () {
              invoiceList!.isNotEmpty
                  ? mounted
                      ? setState(() {
                          currentForm = 3;

                          List<dynamic> totalPriceList =
                              invoiceList!.map((invoice) {
                            var price = invoice.invoiceTotalPrice.toDouble();

                            return price;
                          }).toList();
                          double totalSum =
                              totalPriceList.reduce((a, b) => a + b);
                          controllers['goodsInvoiceValue']!.text =
                              MoneyFormatter(amount: totalSum)
                                  .output
                                  .withoutFractionDigits
                                  .toString();
                        })
                      : null
                  : setState(() {
                      currentForm = 3;
                    });
            });

      case 5:
        return FormShipment6(
          formField: _formField6,
          initialPaymentMethod: selectedPaymentMethod, // Truyền giá trị đã chọn
          onPaymentMethodChanged: (value) {
            // Callback để cập nhật giá trị
            setState(() {
              selectedPaymentMethod = value;
            });
          },
          eventNextButton: () {
            if (_formField6.currentState!.validate()) {
              setState(() {
                currentForm = 6;
              });
            }
          },
          eventBackButton: () {
            setState(() {
              currentForm = 4;
            });
          },
        );

      case 6:
        return FormShipment7(
          formField: _formField7,
          cuocNoiDiaController: controllers['cuocNoiDia']!,
          cuocPhiBaoHiemController: controllers['cuocPhiBaoHiem']!,
          cuocThuHoController: controllers['cuocThuHo']!,
          giaCuocVATController: controllers['giaCuocVAT']!,
          cuocPhuThuController: controllers['cuocPhuThu']!,
          cuocGocController: controllers['cuocGoc']!,
          thuKhachController: controllers['thuKhach']!,
          isLoadingButtonCreateShipment: isLoadingButtonCreateShipment,
          shipmentCode: widget.shipmentCode,
          eventBackButton: () {
            setState(() {
              currentForm = 5;
            });
          },
          eventNextButton: () {
            setState(() {
              handleCreateShipment();
            });
          },
        );
    }
  }

  void showCreateGoods({required int? index}) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.r),
            topLeft: Radius.circular(15.r),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            maxChildSize: 0.8,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                  color: Colors.white,
                  child: Form(
                    key: _formGoods,
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
                          padding: EdgeInsets.all(10.w),
                          controller: scrollController,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            TextApp(
                                              text: " Số kiện ",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            TextApp(
                                              text: " *",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                                enabled: !(index != null &&
                                                    packageList![index]
                                                            .packageId !=
                                                        null),
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputFormatter: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9]")),
                                                ],
                                                controller: controllers[
                                                    'goodsQuantity']!,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Không được để trống";
                                                  }
                                                  final intValue =
                                                      int.tryParse(value);
                                                  if (intValue == null ||
                                                      intValue <= 0) {
                                                    return "Giá trị phải lớn hơn 0";
                                                  }
                                                  return null;
                                                },
                                                hintText: '')),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            TextApp(
                                              text: " Loại",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            TextApp(
                                              text: " *",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                              readonly: true,
                                              controller:
                                                  controllers['goodsTypeText']!,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Nội dung không được để trống';
                                                }
                                                return null;
                                              },
                                              hintText: '',
                                              onTap: () {
                                                showMyCustomModalBottomSheet(
                                                    context: context,
                                                    isScroll: true,
                                                    height: 0.6,
                                                    itemCount:
                                                        allUnitShipmentModel
                                                                ?.data
                                                                .packageTypes
                                                                .length ??
                                                            0,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20.w),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                setState(() {
                                                                  controllers[
                                                                          'goodsTypeText']!
                                                                      .text = allUnitShipmentModel
                                                                          ?.data
                                                                          .packageTypes[index] ??
                                                                      '';
                                                                  currentGoodTypeIndex =
                                                                      index;
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  TextApp(
                                                                    text: allUnitShipmentModel
                                                                            ?.data
                                                                            .packageTypes[index] ??
                                                                        '',
                                                                    color: Colors
                                                                        .black,
                                                                    fontsize:
                                                                        20.sp,
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 25.h,
                                                          )
                                                        ],
                                                      );
                                                    });
                                              },
                                              suffixIcon: Transform.rotate(
                                                angle: 90 * math.pi / 180,
                                                child: Icon(
                                                  Icons.chevron_right,
                                                  size: 32.sp,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: " Length(Cm)",
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      CustomTextFormField(
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          textInputFormatter: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.,]'),
                                            ),
                                          ],
                                          controller:
                                              controllers['goodsLengthValue']!,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Không được để trống";
                                            }
                                            final sanitizedValue =
                                                value.replaceAll(',', '.');
                                            final floatValue =
                                                double.tryParse(sanitizedValue);
                                            if (floatValue == null ||
                                                floatValue <= 0) {
                                              return "Giá trị phải lớn hơn 0";
                                            }
                                            return null;
                                          },
                                          hintText: '')
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: " Width(Cm)",
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      CustomTextFormField(
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          textInputFormatter: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.,]'),
                                            ),
                                          ],
                                          controller:
                                              controllers['goodsWidthValue']!,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Không được để trống";
                                            }
                                            final sanitizedValue =
                                                value.replaceAll(',', '.');
                                            final floatValue =
                                                double.tryParse(sanitizedValue);
                                            if (floatValue == null ||
                                                floatValue <= 0) {
                                              return "Giá trị phải lớn hơn 0";
                                            }
                                            return null;
                                          },
                                          hintText: '')
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: " Heigth(Cm)",
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      CustomTextFormField(
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          textInputFormatter: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.,]'),
                                            ),
                                          ],
                                          controller:
                                              controllers['goodsHeigthValue']!,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Không được để trống";
                                            }
                                            final sanitizedValue =
                                                value.replaceAll(',', '.');
                                            final floatValue =
                                                double.tryParse(sanitizedValue);
                                            if (floatValue == null ||
                                                floatValue <= 0) {
                                              return "Giá trị phải lớn hơn 0";
                                            }
                                            return null;
                                          },
                                          hintText: '')
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: " Weight(Kg)",
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      CustomTextFormField(
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          textInputFormatter: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.,]'),
                                            ),
                                          ],
                                          controller:
                                              controllers['goodsWeightValue']!,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Không được để trống";
                                            }
                                            final sanitizedValue =
                                                value.replaceAll(',', '.');
                                            final floatValue =
                                                double.tryParse(sanitizedValue);

                                            if (floatValue == null ||
                                                floatValue <= 0) {
                                              return "Giá trị phải lớn hơn 0";
                                            }
                                            return null;
                                          },
                                          hintText: '')
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25.h,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  // width: 150.w,
                                  child: ButtonApp(
                                    event: () {
                                      setState(() {
                                        if (_formGoods.currentState!
                                            .validate()) {
                                          Navigator.pop(context);
                                          var package = Package(
                                              packageId: null,
                                              shipmentId: null,
                                              packageQuantity: int.parse(
                                                  controllers['goodsQuantity']!
                                                      .text),
                                              packageType:
                                                  currentGoodTypeIndex!,
                                              packageLength: double.parse(
                                                  controllers['goodsLengthValue']!
                                                      .text),
                                              packageWidth: double.parse(
                                                  controllers['goodsWidthValue']!
                                                      .text),
                                              packageHeight: double.parse(
                                                  controllers['goodsHeigthValue']!
                                                      .text),
                                              packageWeight: double.parse(
                                                  controllers['goodsWeightValue']!.text));

                                          if (editingPackageIndex == null) {
                                            // Add new package
                                            packageList!.add(package);
                                          } else {
                                            packageList![editingPackageIndex!] =
                                                package;
                                            editingPackageIndex =
                                                null; // Reset after update
                                          }

                                          controllers['goodsQuantity']!.clear();
                                          controllers['goodsTypeText']!.clear();
                                          controllers['goodsLengthValue']!
                                              .clear();
                                          controllers['goodsWidthValue']!
                                              .clear();
                                          controllers['goodsHeigthValue']!
                                              .clear();
                                          controllers['goodsWeightValue']!
                                              .clear();
                                        }
                                      });
                                    },
                                    text: isEditGoods
                                        ? "Cập nhật"
                                        : "Tạo sản phẩm",
                                    fontsize: 14.sp,
                                    colorText: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    outlineColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                          ],
                        ))
                      ],
                    ),
                  ));
            },
          );
        });
  }

  void showCreateInvoice() {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.r),
            topLeft: Radius.circular(15.r),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            maxChildSize: 0.8,
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                  color: Colors.white,
                  child: Form(
                    key: _formInvoice,
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
                          padding: EdgeInsets.all(10.w),
                          controller: scrollController,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Chi tiết sản phẩm",
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                                controller: controllers[
                                                    'invoiceGoodsDetails']!,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Nội dung không được để trống';
                                                  }
                                                  return null;
                                                },
                                                hintText: '')),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Số lượng sản phẩm",
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                              onChange: (value) {
                                                if ((controllers[
                                                                'invoicePriceText']!
                                                            .text
                                                            .isNotEmpty &&
                                                        controllers['invoicePriceText']!
                                                                .text !=
                                                            '') &&
                                                    (controllers[
                                                                'invoiceQuantityText']!
                                                            .text
                                                            .isNotEmpty &&
                                                        controllers['invoiceQuantityText']!
                                                                .text !=
                                                            '')) {
                                                  setState(() {
                                                    var invoicePrice = double
                                                            .tryParse(controllers[
                                                                    'invoicePriceText']!
                                                                .text
                                                                .replaceAll(
                                                                    ',', '')) ??
                                                        0;
                                                    var invoiceQuantity = double
                                                            .tryParse(controllers[
                                                                    'invoiceQuantityText']!
                                                                .text
                                                                .replaceAll(
                                                                    ',', '')) ??
                                                        0;
                                                    controllers[
                                                            'invoiceTotalValue']!
                                                        .text = MoneyFormatter(
                                                            amount: (invoicePrice *
                                                                invoiceQuantity))
                                                        .output
                                                        .withoutFractionDigits
                                                        .toString();
                                                  });
                                                } else {
                                                  setState(() {
                                                    controllers[
                                                            'invoiceTotalValue']!
                                                        .text = '0';
                                                  });
                                                }
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              textInputFormatter: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[0-9]")),
                                              ],
                                              controller: controllers[
                                                  'invoiceQuantityText']!,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Không được để trống";
                                                }
                                                final intValue =
                                                    int.tryParse(value);
                                                if (intValue == null ||
                                                    intValue <= 0) {
                                                  return "Giá trị phải lớn hơn 0";
                                                }
                                                return null;
                                              },
                                              hintText: '',
                                            ))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Đơn vị",
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                          width: 1.sw,
                                          child: CustomTextFormField(
                                            readonly: true,
                                            controller:
                                                controllers['invoiceUnitText']!,
                                            validator: (value) {
                                              if (value != null &&
                                                  value.isNotEmpty) {
                                                return null;
                                              }
                                              return "Không được để trống";
                                            },
                                            hintText: '',
                                            suffixIcon: Transform.rotate(
                                              angle: 90 * math.pi / 180,
                                              child: Icon(
                                                Icons.chevron_right,
                                                size: 32.sp,
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                            onTap: () {
                                              showMyCustomModalBottomSheet(
                                                  context: context,
                                                  isScroll: true,
                                                  height: 0.6,
                                                  itemCount:
                                                      allUnitShipmentModel
                                                              ?.data
                                                              .invoiceUnits
                                                              .length ??
                                                          0,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20.w),
                                                          child: InkWell(
                                                            onTap: () async {
                                                              Navigator.pop(
                                                                  context);
                                                              setState(() {
                                                                controllers[
                                                                        'invoiceUnitText']!
                                                                    .text = allUnitShipmentModel
                                                                            ?.data
                                                                            .invoiceUnits[
                                                                        index] ??
                                                                    '';
                                                                currentInvoiceUnitIndex =
                                                                    index;
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                TextApp(
                                                                  text: allUnitShipmentModel
                                                                          ?.data
                                                                          .invoiceUnits[index] ??
                                                                      '',
                                                                  color: Colors
                                                                      .black,
                                                                  fontsize:
                                                                      20.sp,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Divider(
                                                          height: 25.h,
                                                        )
                                                      ],
                                                    );
                                                  });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Giá sản phẩm",
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                              onChange: (value) {
                                                if ((controllers[
                                                                'invoicePriceText']!
                                                            .text
                                                            .isNotEmpty &&
                                                        controllers['invoicePriceText']!
                                                                .text !=
                                                            '') &&
                                                    (controllers[
                                                                'invoiceQuantityText']!
                                                            .text
                                                            .isNotEmpty &&
                                                        controllers['invoiceQuantityText']!
                                                                .text !=
                                                            '')) {
                                                  setState(() {
                                                    var invoicePrice = double
                                                            .tryParse(controllers[
                                                                    'invoicePriceText']!
                                                                .text
                                                                .replaceAll(
                                                                    ',', '')) ??
                                                        0;
                                                    var invoiceQuantity = double
                                                            .tryParse(controllers[
                                                                    'invoiceQuantityText']!
                                                                .text
                                                                .replaceAll(
                                                                    ',', '')) ??
                                                        0;
                                                    controllers[
                                                            'invoiceTotalValue']!
                                                        .text = MoneyFormatter(
                                                            amount: (invoicePrice *
                                                                invoiceQuantity))
                                                        .output
                                                        .withoutFractionDigits
                                                        .toString();
                                                  });
                                                } else {
                                                  setState(() {
                                                    controllers[
                                                            'invoiceTotalValue']!
                                                        .text = '0';
                                                  });
                                                }
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              textInputFormatter: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp("[0-9]")),
                                                CurrencyInputFormatter()
                                              ],
                                              controller: controllers[
                                                  'invoicePriceText']!,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Không được để trống";
                                                }
                                                final intValue = int.tryParse(
                                                    value.replaceAll(',', ''));
                                                if (intValue == null ||
                                                    intValue <= 0) {
                                                  return "Giá trị phải lớn hơn 0";
                                                }
                                                return null;
                                              },
                                              hintText: '',
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: " Tổng giá trị",
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        SizedBox(
                                            width: 1.sw,
                                            child: CustomTextFormField(
                                                enabled: false,
                                                controller: controllers[
                                                    'invoiceTotalValue']!,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Không được để trống";
                                                  }
                                                  final intValue = int.tryParse(
                                                      value.replaceAll(
                                                          ',', ''));
                                                  if (intValue == null ||
                                                      intValue <= 0) {
                                                    return "Giá trị phải lớn hơn 0";
                                                  }
                                                  return null;
                                                },
                                                hintText: '')),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            SizedBox(
                              width: 150.w,
                              child: ButtonApp(
                                event: () {
                                  setState(() {
                                    if (_formInvoice.currentState!.validate()) {
                                      Navigator.pop(context);
                                      var invoice = Invoice(
                                          invoiceId: null,
                                          shipmentId: null,
                                          invoiceGoodsDetails:
                                              controllers['invoiceGoodsDetails']!
                                                  .text,
                                          invoiceQuantity: int.parse(
                                              controllers['invoiceQuantityText']!
                                                  .text),
                                          invoiceUnit: currentInvoiceUnitIndex!,
                                          invoicePrice: (double.tryParse(
                                                      controllers['invoicePriceText']!
                                                          .text
                                                          .replaceAll(
                                                              ',', '')) ??
                                                  0)
                                              .toInt(),
                                          invoiceTotalPrice: (double.tryParse(
                                                      controllers['invoiceTotalValue']!.text.replaceAll(',', '')) ??
                                                  0)
                                              .toInt());

                                      if (editingInvoiceIndex == null) {
                                        // Add new package
                                        invoiceList!.add(invoice);
                                      } else {
                                        // Update existing package
                                        invoiceList![editingInvoiceIndex!] =
                                            invoice;
                                        editingInvoiceIndex =
                                            null; // Reset after update
                                      }

                                      List<dynamic> totalPriceList =
                                          invoiceList!.map((invoice) {
                                        var price = invoice.invoiceTotalPrice
                                            .toDouble();
                                        return price;
                                      }).toList();
                                      double totalSum = totalPriceList
                                          .reduce((a, b) => a + b);
                                      controllers['goodsInvoiceValue']!.text =
                                          MoneyFormatter(amount: totalSum)
                                              .output
                                              .withoutFractionDigits
                                              .toString();
                                      controllers['invoiceGoodsDetails']!
                                          .clear();
                                      controllers['invoiceQuantityText']!
                                          .clear();
                                      controllers['invoiceUnitText']!.clear();
                                      controllers['invoicePriceText']!.clear();
                                      controllers['invoiceTotalValue']!.clear();
                                    }
                                  });
                                },
                                text:
                                    isEditInvoice ? "Cập nhật" : "Tạo Invoice",
                                fontsize: 14.sp,
                                fontWeight: FontWeight.bold,
                                colorText: Colors.white,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                outlineColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                          ],
                        ))
                      ],
                    ),
                  ));
            },
          );
        });
  }
}
