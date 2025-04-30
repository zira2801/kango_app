import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/shipment/details_tracking_shipment/details_tracking_shipment_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/list_shipment_bloc.dart';
import 'package:scan_barcode_app/bloc/transfer/transfer_bloc.dart';
import 'package:scan_barcode_app/data/models/shipment/all_unit_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/delivery_service.dart';
import 'package:scan_barcode_app/data/models/shipment/details_shipment.dart';
import 'package:scan_barcode_app/data/models/shipment/list_shipment.dart';
import 'package:scan_barcode_app/data/models/transfer/transfer_model.dart';
import 'package:scan_barcode_app/data/models/utils/list_branchs_model.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/shipment/create_new_shipment.dart';
import 'package:scan_barcode_app/ui/screen/shipment/fillter_wallet_fluctuation.dart';
import 'package:scan_barcode_app/ui/screen/shipment/filter_shipment.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab1_widget.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_info_tab2_widget.dart';
import 'package:scan_barcode_app/ui/screen/shipment/details_shipment_screen/tracking_shipment.dart';
import 'package:scan_barcode_app/ui/screen/transfer_list/filter_transfer.dart';
import 'package:scan_barcode_app/ui/screen/transfer_list/transfer_list_create.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/form/custom_form.dart';
import 'package:scan_barcode_app/ui/widgets/html/html_screen.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/api/index.dart';

import '../../../data/models/method_pay_character.dart/method_pay_character.dart';

class TransferListScreen extends StatefulWidget {
  final String? userPosition;
  final bool? canUploadLabel;
  final bool? canUploadPayment;
  const TransferListScreen({
    super.key,
    this.userPosition,
    this.canUploadLabel,
    this.canUploadPayment,
  });

  @override
  State<TransferListScreen> createState() => _PackageManagerScreenState();
}

class _PackageManagerScreenState extends State<TransferListScreen>
    with SingleTickerProviderStateMixin {
  List<ExpansionTileController> expansionTileControllers = [];
  final scrollListTransferController = ScrollController();
  final textSearchController = TextEditingController();
  final statusTextController = TextEditingController();
  final branchTextController = TextEditingController();
  final searchTypeTextController = TextEditingController();
  final statusPaymentTextController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  bool isMoreDetailShipment = false;
  String query = '';
  List<IconData> iconStatus = [
    Icons.all_inbox,
    Icons.add,
    Icons.create,
    Icons.outbond,
    Icons.refresh
  ];

  DetailsShipmentModel? detailsShipment;
  DeliveryServiceModel? deliveryServiceMode;
  AllUnitShipmentModel? allUnitShipmentModel;

  DateTime? _startDate; //type ngày bắt đầu
  DateTime? _endDate; //type ngày kết thúc
  String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
  int? branchID;
  BranchResponse? branchResponse;
  File? selectedImage;
  bool hasMore = false;
  final ImagePicker picker = ImagePicker();
  final MethodPayCharater? _methodPay = MethodPayCharater.bank;
  String? selectedFile;
  late TabController _tabController;
  // late SlidableController _slidableController;
  void editShipment({
    required String shipmentCode,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CreateShipmentScreen(shipmentCode: shipmentCode)),
    );
  }

  void handleDeleteShipment({required String? shipmentCode}) {
    context
        .read<DeleteShipmentBloc>()
        .add(HanldeDeleteShipment(shipmentCode: shipmentCode));
  }

  Future<void> getDetailsShipment(
      {required String? shipmentCode, required bool isMoreDetail}) async {
    context.read<DetailsShipmentBloc>().add(
          HanldeDetailsShipment(
              shipmentCode: shipmentCode, isMoreDetail: isMoreDetail),
        );
  }

  Future<void> approveTransfer({required int? transferID}) async {
    context.read<ApproveTransferBloc>().add(
          ApproveTransfer(transferID: transferID),
        );
  }

  Future<void> deleteTransfer({required int? transferID}) async {
    context.read<DeleteTransferBloc>().add(
          DeleteTransfer(transferID: transferID),
        );
  }

  Future<void> showDialogDetailsShipment({required String shipmentCode}) async {
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
                ScrollController scrollControllerMoreInfor) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(
                              child: TextApp(
                                text: 'Thông tin lô hàng',
                                fontsize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                            Tab(
                              child: TextApp(
                                text: 'Thông tin kiện hàng',
                                fontsize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              PackageInfoWidgetTab1(
                                shipmentCode: shipmentCode,
                                scrollController: scrollControllerMoreInfor,
                                detailsShipment: detailsShipment,
                                selectedPDFLabelString: selectedFile,
                                selectedImage: selectedImage,
                                methodPay: _methodPay,
                                userPosition: widget.userPosition,
                                canUploadLabel: widget.canUploadLabel,
                                canUploadPayment: widget.canUploadPayment,
                              ),
                              PackageInfoWidgetTab2(
                                scrollController: scrollControllerMoreInfor,
                                detailsShipment: detailsShipment,
                                allUnitShipmentModel: allUnitShipmentModel,
                              )
                            ],
                          ),
                        ),
                      ],
                    ));
              });
            },
          );
        });
  }

  void openDialogDetailTransfer({required Transfer transfer}) {
    // Tạo key cho form để validation
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Tiền xử lý dữ liệu trước khi hiển thị dialog
    final List<String> processedImages =
        transfer.transferImages != null && transfer.transferImages!.isNotEmpty
            ? [...transfer.parsedImages]
            : [];

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              insetPadding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.w),
              ),
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              child: SizedBox(
                width: 1200.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header section
                    Padding(
                      padding:
                          EdgeInsets.only(left: 5.w, right: 10.w, top: 5.w),
                      child: Row(
                        children: [
                          Text(
                            "CHI TIẾT KHAI HÀNG",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: "Icomoon",
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        ],
                      ),
                    ),

                    // Content Section
                    Flexible(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(left: 5.w, right: 10.w),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20.w),

                                    // Images section - optimized with memory image cache
                                    SizedBox(
                                      height: 120.h,
                                      child: processedImages.isNotEmpty
                                          ? ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: processedImages.length,
                                              itemBuilder: (context, index) {
                                                if (index < 0 ||
                                                    index >=
                                                        processedImages
                                                            .length) {
                                                  return const SizedBox();
                                                }

                                                final imageUrl =
                                                    processedImages[index];
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10.w),
                                                  child: _buildImageThumbnail(
                                                      context, imageUrl),
                                                );
                                              },
                                            )
                                          : Center(
                                              child: TextApp(
                                                text: "Không có hình ảnh",
                                                color: Colors.grey,
                                                fontsize: 14.sp,
                                              ),
                                            ),
                                    ),

                                    SizedBox(height: 20.w),

                                    // Receiver info section
                                    _buildInfoSection(
                                      title: "Người nhận: ",
                                      content: transfer.receiverName.toString(),
                                    ),

                                    SizedBox(height: 20.w),

                                    _buildInfoSection(
                                      title: "Số điện thoại: ",
                                      content:
                                          transfer.receiverPhone.toString(),
                                    ),

                                    SizedBox(height: 20.w),

                                    _buildInfoSection(
                                      title: "Địa chỉ: ",
                                      content:
                                          transfer.receiverAddress.toString(),
                                      maxLines: 2,
                                    ),

                                    SizedBox(height: 20.w),

                                    const Divider(height: 1),

                                    // Use optimized HTML viewer
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width -
                                                30.w,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: HtmlViewer(
                                          htmlData: transfer.transferContent
                                              .toString(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Footer with close button

                    // Actions Section
                    Padding(
                      padding: EdgeInsets.only(
                          left: 10.w, right: 10.w, bottom: 10.w, top: 10.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ButtonApp(
                            event: () {
                              Navigator.of(context).pop();
                            },
                            fontsize: 14.sp,
                            fontWeight: FontWeight.bold,
                            text: "OK",
                            colorText: Theme.of(context).colorScheme.background,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            outlineColor: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

// Tách thành phương thức riêng để tái sử dụng
  Widget _buildInfoSection({
    required String title,
    required String content,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextApp(
          text: title,
          fontsize: 17.sp,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: 5.h),
        TextApp(
          text: content,
          fontsize: 17.sp,
          maxLines: maxLines,
        ),
      ],
    );
  }

// Tối ưu hiển thị thumbnail với memory cache
  Widget _buildImageThumbnail(BuildContext context, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.w),
        child: GestureDetector(
          onTap: () => _showImageViewer(context, imageUrl),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            memCacheWidth: 240, // Giới hạn kích thước bộ nhớ cache
            placeholder: (context, url) => Container(
              width: 120.w,
              height: 120.h,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 120.w,
              height: 120.h,
              color: Colors.grey[200],
              child: Icon(Icons.error_outline, color: Colors.grey[400]),
            ),
            fit: BoxFit.cover,
            width: 120.w,
            height: 120.h,
          ),
        ),
      ),
    );
  }

// Tách logic hiển thị ảnh thành phương thức riêng
  void _showImageViewer(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Hero(
            tag: imageUrl, // Thêm hiệu ứng Hero transition
            child: Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showShipmentListDialog(
      {required List<ShipmentTransfer> transferShipments}) async {
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
          maxChildSize: 0.6,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 50.w,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: TextApp(
                        text: 'Danh sách đơn hàng',
                        fontsize: 18.w,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  transferShipments.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: transferShipments.length,
                            itemBuilder: (context, index) {
                              final shipment = transferShipments[index];
                              return Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 10.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.1), // Màu bóng nhẹ
                                      blurRadius: 8, // Độ mờ của bóng
                                      spreadRadius: 2, // Độ lan của bóng
                                      offset: Offset(
                                          0, 4), // Dịch chuyển bóng xuống dưới
                                    ),
                                  ],
                                ),
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.w),
                                  ),
                                  elevation:
                                      0, // Đặt elevation = 0 vì đã có boxShadow
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextApp(
                                              text: 'Mã đơn hàng:',
                                              fontsize: 16.w,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            TextApp(
                                              text: shipment.shipmentCode,
                                              fontsize: 16.w,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.w),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextApp(
                                              text: 'Ngày tạo:',
                                              fontsize: 16.w,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            TextApp(
                                              text: formatDate(
                                                  shipment.createAt.toString()),
                                              fontsize: 16.w,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.w),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                await getDetailsShipment(
                                                    shipmentCode:
                                                        shipment.shipmentCode,
                                                    isMoreDetail: false);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15.w),
                                              ),
                                              child: TextApp(
                                                text: 'Xem chi tiết',
                                                fontsize: 14.w,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: SizedBox(
                                width: 200.w,
                                height: 200.w,
                                child: Lottie.asset(
                                    'assets/lottie/empty_box.json',
                                    fit: BoxFit.contain),
                              ),
                            ),
                            TextApp(
                              text: "Chưa có đơn hàng",
                              fontsize: 18.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        )
                ],
              ),
            );
          },
        );
      },
    );
  }

// Helper function to format date
  String formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}   ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
    } catch (e) {
      return dateString;
    }
  }

  String _getPositionName(int positionID) {
    const statusMap = {
      1: 'ADMIN',
      2: 'Kế toán',
      3: 'OPS/Pickup',
      4: 'Sale',
      5: 'Fwd',
      7: 'Chứng từ',
      8: 'OPS trưởng',
      9: 'Tài xế'
    };
    return statusMap[positionID] ?? 'Unknown';
  }

  Color _getPositionColor(int positionID) {
    const statusMap = {
      1: Colors.black,
      // 2: 'Kế toán',
      // 3: 'OPS/Pickup',
      4: Color.fromRGBO(0, 214, 127, 1),
      5: Color.fromRGBO(24, 221, 239, 1),
      // 7: 'Chứng từ',
      // 8: 'OPS trưởng',
      // 9: 'Tài xế'
    };
    return statusMap[positionID] ?? const Color.fromRGBO(24, 221, 239, 1);
  }

  String _getStatusName(int statusID) {
    const statusMap = {
      0: 'Create Bill',
      1: 'Imported',
      2: 'Exported',
      3: 'Returned',
      4: 'Hold',
    };
    return statusMap[statusID] ?? 'Unknown';
  }

  Color _getStatusColor(int statusID) {
    const statusMap = {
      0: Colors.grey,
      1: Color.fromRGBO(24, 221, 239, 1),
      2: Color.fromRGBO(0, 214, 127, 1),
      3: Colors.red,
      4: Colors.red,
    };
    return statusMap[statusID] ?? Colors.grey;
  }

  Future<void> showDialogMoreDetailShipment(
      {required DetailsShipmentModel shipmentdetail}) async {
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
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
            maxChildSize: 0.6,
            initialChildSize: 0.5,
            minChildSize: 0.3,
            expand: false,
            builder: (BuildContext context,
                ScrollController scrollControllerMoreInfor) {
              return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 50.w,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0)),
                              color: Theme.of(context).colorScheme.primary),
                          child: Align(
                            alignment: Alignment.center,
                            child: TextApp(
                              text: 'Thông tin thêm',
                              fontsize: 18.w,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextApp(
                              fontsize: 17.w,
                              text:
                                  'Address: ${shipmentdetail.shipment.receiverAddress1}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              TextApp(fontsize: 17.w, text: 'Tài khoản tạo: '),
                              SizedBox(
                                width: 5.w,
                              ),
                              Container(
                                height: 40.w,
                                width: 80.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: _getPositionColor(
                                      shipmentdetail.shipment.user.positionId),
                                ),
                                child: Center(
                                  child: TextApp(
                                    fontsize: 14.w,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    text: _getPositionName(shipmentdetail
                                        .shipment.user.positionId),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              TextApp(
                                  fontsize: 17.w,
                                  maxLines: 2,
                                  text: shipmentdetail
                                      .shipment.user.userContactName),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5.w,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextApp(
                              fontsize: 17.w,
                              text:
                                  'Ref Code: ${shipmentdetail.shipment.shipmentReferenceCode ?? ''}'),
                        ),
                        SizedBox(
                          height: 5.w,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextApp(
                                text: 'Status: ',
                                fontsize: 17.w,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Transform.translate(
                                offset: Offset(
                                    0, -5.w), // Di chuyển lên trên 5 đơn vị
                                child: Container(
                                  height: 40.w,
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: _getStatusColor(
                                        shipmentdetail.shipment.shipmentStatus),
                                  ),
                                  child: Center(
                                    child: TextApp(
                                      fontsize: 14.w,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      text: _getStatusName(shipmentdetail
                                          .shipment.shipmentStatus),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextApp(
                                text: 'Thanh toán: ',
                                fontsize: 17.w,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              detailsShipment!.shipment.shipmentPaymentStatus ==
                                      0
                                  ? TextApp(
                                      fontsize: 17.w,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                      text: 'Chưa thanh toán',
                                    )
                                  : TextApp(
                                      fontsize: 17.w,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromRGBO(0, 214, 127, 1),
                                      text: 'Đã thanh toán',
                                    )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextApp(
                                text: 'Duyệt xuất: ',
                                fontsize: 17.w,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              detailsShipment!.shipment.accountantStatus == 0
                                  ? TextApp(
                                      fontsize: 17.w,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(
                                          111, 111, 111, 1),
                                      text: 'Đang chờ xác nhận',
                                    )
                                  : TextApp(
                                      fontsize: 17.w,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          const Color.fromRGBO(0, 214, 127, 1),
                                      text: 'Đã xác nhận',
                                    )
                            ],
                          ),
                        ),
                        isShipper!
                            ? Container()
                            : (detailsShipment!.shipment.service.serviceName
                                        ?.startsWith("EP-") ??
                                    false)
                                ? Container()
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextApp(
                                          text: 'Admin duyệt: ',
                                          fontsize: 16.w,
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        detailsShipment!.shipment
                                                    .shipmentCheckedPaymentStatus ==
                                                0
                                            ? TextApp(
                                                fontsize: 17.w,
                                                fontWeight: FontWeight.w600,
                                                color: const Color.fromRGBO(
                                                    255, 196, 0, 1),
                                                text: 'Chưa duyệt',
                                              )
                                            : TextApp(
                                                fontsize: 17.w,
                                                fontWeight: FontWeight.w600,
                                                color: const Color.fromRGBO(
                                                    0, 214, 127, 1),
                                                text: 'Đã duyệt',
                                              )
                                      ],
                                    ),
                                  )
                      ],
                    ));
              });
            },
          );
        });
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

  Future<void> getBranchKango() async {
    String? branchResponseJson =
        StorageUtils.instance.getString(key: 'branch_response');
    if (branchResponseJson != null) {
      branchResponse = BranchResponse.fromJson(jsonDecode(branchResponseJson));
      log("GET BRANCH OK LIST");
    }
  }

  void init() async {
    BlocProvider.of<GetListTransferBloc>(context).add(FetchListTransfer(
      startDate: null,
      endDate: null,
      keywords: query,
    ));
    await getBranchKango();
    await getAllUnitShipment();
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // _slidableController = SlidableController(vsync: this);
    init();
    for (int i = 0; i < 5; i++) {
      expansionTileControllers.add(ExpansionTileController());
    }
    scrollListTransferController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollListTransferController.position.maxScrollExtent ==
        scrollListTransferController.offset) {
      BlocProvider.of<GetListTransferBloc>(context).add(LoadMoreListTransfer(
        startDate: _startDate?.toString(),
        endDate: _endDate?.toString(),
        keywords: query,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    textSearchController.clear();
    statusTextController.clear();
    searchTypeTextController.clear();
    _dateStartController.clear();
    _dateEndController.clear();
    statusTextController.clear();
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<GetListTransferBloc>(context).add(FetchListTransfer(
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              keywords: query,
            ));
          })
        : null;
  }

  Future<void> applyFilterFuntion() async {
    // Kiểm tra nếu một trong hai ngày bị thiếu
    if ((_startDate != null && _endDate == null) ||
        (_startDate == null && _endDate != null)) {
      showCustomDialogModal(
        context: context,
        textDesc: "Vui lòng chọn cả ngày bắt đầu và ngày kết thúc.",
        title: "Thông báo",
        colorButtonOk: Colors.red,
        btnOKText: "Xác nhận",
        typeDialog: "error",
        eventButtonOKPress: () {},
        isTwoButton: false,
      );
      return; // Dừng hàm nếu không đủ điều kiện
    }

    log(_startDate.toString());
    log(_endDate.toString());
    Navigator.pop(context);

    BlocProvider.of<GetListTransferBloc>(context).add(FetchListTransfer(
      startDate: _startDate?.toString(),
      endDate: _endDate?.toString(),
      keywords: query,
    ));
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      statusTextController.clear();
      statusPaymentTextController.clear();
      searchTypeTextController.clear();
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
      branchID = null;
    });
    Navigator.pop(context);
    BlocProvider.of<GetListTransferBloc>(context).add(FetchListTransfer(
      startDate: _startDate?.toString(),
      endDate: _endDate?.toString(),
      keywords: query,
    ));
  }

  /// This builds cupertion date picker in iOS
  void buildCupertinoDateStartPicker(BuildContext context) {
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateStartController.text;
    DateTime? originalStartDate = _startDate;

    showCupertinoDatePicker(
      context,
      initialDate: _startDate,
      onDateChanged: (picked) {
        setState(() {
          _startDate = picked;
        });
      },
      onCancel: () {
        // Khôi phục lại giá trị ban đầu
        setState(() {
          _startDate = originalStartDate;
          _dateStartController.text = originalControllerText;
        });
        Navigator.of(context).pop();
      },
      onConfirm: () {
        setState(() {
          _dateStartController.text = formatDateMonthYear(
              (_startDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
          Navigator.of(context).pop();
        });
      },
    );
  }

  void buildCupertinoDateEndPicker(BuildContext context) {
    DateTime? originalEndDate = _endDate; // Store the original date

    showCupertinoDatePicker(
      context,
      initialDate: _endDate,
      onDateChanged: (picked) {
        setState(() {
          _endDate = picked;
        });
      },
      onCancel: () {
        // Restore the original date and clear the text field
        setState(() {
          _endDate = originalEndDate;
          _dateEndController.clear();
        });
        Navigator.of(context).pop();
      },
      onConfirm: () {
        if ((_endDate ?? DateTime.now())
            .isBefore(_startDate ?? DateTime.now())) {
          showCustomDialogModal(
              context: context,
              textDesc: "Nhỏ hơn ngày bắt đầu",
              title: "Thông báo",
              colorButtonOk: Colors.red,
              btnOKText: "Xác nhận",
              typeDialog: "error",
              eventButtonOKPress: () {},
              isTwoButton: false);
        } else {
          setState(() {
            _dateEndController.text = formatDateMonthYear(
                (_endDate ?? DateTime.now()).toString().split(" ")[0]);
            _endDateError = null;
            Navigator.of(context).pop();
          });
        }
      },
    );
  }

  /// This builds material date picker in Android
  Future<void> buildMaterialDateStartPicker(BuildContext context) async {
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateStartController.text;
    DateTime? originalStartDate = _startDate;

    await showMaterialDatePicker(
      context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      onDatePicked: (picked) {
        setState(() {
          _startDate = picked;
          _dateStartController.text = formatDateMonthYear(
              (_startDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
        });
      },
      onCancel: () {
        // Nếu đã có giá trị ban đầu, khôi phục lại giá trị đó
        setState(() {
          _startDate = originalStartDate;
          _dateStartController.text = originalControllerText;
        });
      },
    );
  }

  Future<void> buildMaterialDateEndPicker(BuildContext context) async {
    // Lưu lại giá trị ban đầu của controller
    String originalControllerText = _dateEndController.text;
    DateTime? originalEndDate = _endDate;

    await showMaterialDatePicker(
      context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      onDatePicked: (picked) {
        setState(() {
          _endDate = picked;
          _dateEndController.text = formatDateMonthYear(
              (_endDate ?? DateTime.now()).toString().split(" ")[0]);
          _endDateError = null;
        });
      },
      onCancel: () {
        // Nếu đã có giá trị ban đầu, khôi phục lại giá trị đó
        setState(() {
          _endDate = originalEndDate;
          _dateEndController.text = originalControllerText;
        });
      },
    );
  }

  Future<void> selectDayStart() async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDateStartPicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDateStartPicker(context);
      // return buildMaterialDateStartPicker(context);
    }
  }

  Future<void> selectDayEnd() async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDateEndPicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDateEndPicker(context);
      // return buildMaterialDateEndPicker(context);
    }
  }

  String _getNameBranch(int brandId) {
    final branch = branchResponse?.branchs.firstWhere(
      (branch) => branch.branchId == brandId,
    );
    if (branch != null) {
      return branch.branchName;
    } else {
      throw Exception('Branch not found');
    }
  }

// Helper widget cho Slidable Action
  Widget _buildSlidableAction({
    required IconData icon,
    required String label,
    required Color color,
    required void Function(BuildContext) onPressed,
  }) {
    return CustomSlidableAction(
      onPressed: onPressed,
      backgroundColor: color,
      foregroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: TextApp(
            text: text,
            fontsize: 14.sp,
            color: Colors.grey[800] ?? Colors.grey,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: TextApp(
            text: "Danh sách khai hàng",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
            listeners: [
              BlocListener<ListShipmentBloc, ListShipmentState>(
                listener: (context, state) {
                  if (state is ListShipmentStateSuccess) {}
                },
              ),
              BlocListener<DetailsShipmentBloc, DetailsShipmentState>(
                listener: (context, state) async {
                  if (state is DetailsShipmentStateSuccess) {
                    detailsShipment = state.detailsShipmentModel;

                    if (state.isMoreDetail) {
                      await showDialogMoreDetailShipment(
                          shipmentdetail: detailsShipment!);
                    } else {
                      await showDialogDetailsShipment(
                          shipmentCode: detailsShipment!.shipment.shipmentCode);
                    }
                  }
                },
              ),
              BlocListener<ApproveTransferBloc, ApproveTransfertState>(
                listener: (context, state) {
                  if (state is ApproveTransfertStateSuccess) {
                    showCustomDialogModal(
                        context: navigatorKey.currentContext!,
                        textDesc: state.message,
                        title: "Thông báo",
                        colorButtonOk: Colors.green,
                        btnOKText: "Xác nhận",
                        typeDialog: "success",
                        eventButtonOKPress: () {},
                        isTwoButton: false);
                    init();
                  } else if (state is ApproveTransfertStateFailure) {
                    showDialog(
                        context: navigatorKey.currentContext!,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            eventConfirm: () {
                              Navigator.pop(context);
                            },
                            errorText: state.message,
                          );
                        });
                  }
                },
              ),
              BlocListener<DeleteTransferBloc, DeleteTransferState>(
                listener: (context, state) {
                  if (state is DeleteTransferStateSuccess) {
                    showCustomDialogModal(
                        context: navigatorKey.currentContext!,
                        textDesc: state.message,
                        title: "Thông báo",
                        colorButtonOk: Colors.green,
                        btnOKText: "Xác nhận",
                        typeDialog: "success",
                        eventButtonOKPress: () {},
                        isTwoButton: false);
                    init();
                  } else if (state is DeleteTransferStateFailure) {
                    showDialog(
                        context: navigatorKey.currentContext!,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            eventConfirm: () {
                              Navigator.pop(context);
                            },
                            errorText: state.message,
                          );
                        });
                  }
                },
              ),
            ],
            child: BlocBuilder<GetListTransferBloc, GetListTransferState>(
              builder: (context, state) {
                if (state is GetListTransferStateloading) {
                  return Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Lottie.asset('assets/lottie/loading_kango.json'),
                    ),
                  );
                } else if (state is GetListTransferStateSuccess) {
                  return SlidableAutoCloseBehavior(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Close any open slidable when tapping outside
                        Slidable.of(context)?.close();
                      },
                      child: RefreshIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        onRefresh: () async {
                          // shipmentItemData.clear();
                          _endDateError = null;
                          statusTextController.clear();
                          statusPaymentTextController.clear();
                          _dateStartController.clear();
                          searchTypeTextController.clear();
                          _dateEndController.clear();
                          _startDate = null;
                          _endDate = null;
                          branchID = null;
                          BlocProvider.of<GetListTransferBloc>(context)
                              .add(FetchListTransfer(
                            startDate: null,
                            endDate: null,
                            keywords: query,
                          ));
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 1.sw,
                              padding: EdgeInsets.all(10.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: 1.sw,
                                      padding: EdgeInsets.all(10.w),
                                      child: TextFormField(
                                        onTapOutside: (event) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        // onChanged: searchProduct,
                                        controller: textSearchController,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black),
                                        cursorColor: Colors.black,
                                        onFieldSubmitted: (value) =>
                                            searchProduct(value),
                                        decoration: InputDecoration(
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                searchProduct(
                                                    textSearchController.text);
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
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  FilterTransferWidget(
                                      isPakageManger: false,
                                      dateStartController: _dateStartController,
                                      dateEndController: _dateEndController,
                                      selectDayStart: selectDayStart,
                                      selectDayEnd: selectDayEnd,
                                      getEndDateError: () => _endDateError,
                                      clearFliterFunction: clearFilterFuntion,
                                      applyFliterFunction: applyFilterFuntion),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: scrollListTransferController,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 300.w,
                                        height: 50.w,
                                        child: ButtonApp(
                                            event: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const TransferCreateScreen(
                                                    transfer: null,
                                                  ),
                                                ),
                                              );
                                            },
                                            text: "Thêm mới khai hàng",
                                            colorText: Colors.white,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            outlineColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                            fontsize: 14.sp),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.w,
                                    ),
                                    SizedBox(
                                      width: 1.sw,
                                      child: state.data.isEmpty
                                          ? const NoDataFoundWidget()
                                          : ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: state.hasReachedMax
                                                  ? state.data.length
                                                  : state.data.length + 1,
                                              itemBuilder: (context, index) {
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
                                                  final dataTransfer =
                                                      state.data[index];

                                                  return Column(
                                                    children: [
                                                      Divider(
                                                        height: 1,
                                                        color: Colors.grey[200],
                                                      ),
                                                      Container(
                                                        width: 1.sw,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.05),
                                                              blurRadius: 5,
                                                              offset:
                                                                  Offset(0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Slidable(
                                                          key: ValueKey(
                                                              dataTransfer),
                                                          endActionPane:
                                                              ActionPane(
                                                            extentRatio:
                                                                isShipper!
                                                                    ? 0.3
                                                                    : 0.9,
                                                            motion:
                                                                const ScrollMotion(),
                                                            children: [
                                                              _buildSlidableAction(
                                                                icon: Icons
                                                                    .visibility_outlined,
                                                                label:
                                                                    'Chi tiết',
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                                onPressed: (context) =>
                                                                    openDialogDetailTransfer(
                                                                        transfer:
                                                                            dataTransfer),
                                                              ),
                                                              _buildSlidableAction(
                                                                icon:
                                                                    Icons.edit,
                                                                label: 'Sửa',
                                                                color:
                                                                    Colors.blue,
                                                                onPressed:
                                                                    (context) =>
                                                                        Navigator
                                                                            .push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        TransferCreateScreen(
                                                                            transfer:
                                                                                dataTransfer),
                                                                  ),
                                                                ),
                                                              ),
                                                              if (dataTransfer
                                                                      .transferStatus ==
                                                                  0)
                                                                _buildSlidableAction(
                                                                  icon: Icons
                                                                      .check_circle,
                                                                  label:
                                                                      'Duyệt',
                                                                  color: const Color
                                                                      .fromRGBO(
                                                                      0,
                                                                      214,
                                                                      127,
                                                                      1),
                                                                  onPressed:
                                                                      (context) =>
                                                                          showCustomDialogModal(
                                                                    context:
                                                                        navigatorKey
                                                                            .currentContext!,
                                                                    textDesc:
                                                                        "Bạn có chắc muốn duyệt khai hàng này?",
                                                                    title:
                                                                        "Thông báo",
                                                                    colorButtonOk:
                                                                        Colors
                                                                            .blue,
                                                                    btnOKText:
                                                                        "Xác nhận",
                                                                    typeDialog:
                                                                        "question",
                                                                    eventButtonOKPress:
                                                                        () async {
                                                                      await approveTransfer(
                                                                          transferID:
                                                                              dataTransfer.transferId);
                                                                    },
                                                                    isTwoButton:
                                                                        true,
                                                                  ),
                                                                ),
                                                              _buildSlidableAction(
                                                                icon: Icons
                                                                    .delete,
                                                                label: 'Xóa',
                                                                color:
                                                                    Colors.red,
                                                                onPressed:
                                                                    (context) =>
                                                                        showCustomDialogModal(
                                                                  context:
                                                                      navigatorKey
                                                                          .currentContext!,
                                                                  textDesc:
                                                                      "Bạn có chắc muốn xóa khai hàng này?",
                                                                  title:
                                                                      "Thông báo",
                                                                  colorButtonOk:
                                                                      Colors
                                                                          .blue,
                                                                  btnOKText:
                                                                      "Xác nhận",
                                                                  typeDialog:
                                                                      "question",
                                                                  eventButtonOKPress:
                                                                      () async {
                                                                    await deleteTransfer(
                                                                        transferID:
                                                                            dataTransfer.transferId);
                                                                  },
                                                                  isTwoButton:
                                                                      true,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        12,
                                                                    horizontal:
                                                                        16),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Status Icon
                                                                Container(
                                                                  width: 60.w,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                        dataTransfer.transferStatus ==
                                                                                0
                                                                            ? Icons.circle_notifications
                                                                            : Icons.check_circle_rounded,
                                                                        color: dataTransfer.transferStatus ==
                                                                                0
                                                                            ? Colors.grey
                                                                            : Colors.green,
                                                                        size: 40
                                                                            .sp,
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              4),
                                                                      TextApp(
                                                                        text: dataTransfer.transferStatus ==
                                                                                0
                                                                            ? "Chưa xác nhận"
                                                                            : "Đã xác nhận",
                                                                        fontsize:
                                                                            13.sp,
                                                                        color: Colors.grey[600] ??
                                                                            Colors.grey,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width:
                                                                        12.w),
                                                                // Main Content
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      // User Name
                                                                      InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          await showShipmentListDialog(
                                                                              transferShipments: dataTransfer.transferShipments!);
                                                                        },
                                                                        child:
                                                                            TextApp(
                                                                          text: dataTransfer.user!.userContactName ??
                                                                              '',
                                                                          fontsize:
                                                                              18.sp,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .primary,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              8),
                                                                      // Info Rows
                                                                      _buildInfoRow(
                                                                        icon: Icons
                                                                            .person_outline,
                                                                        text:
                                                                            "Người nhận: ${dataTransfer.receiverName ?? ''}",
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              6),
                                                                      _buildInfoRow(
                                                                        icon: Icons
                                                                            .phone,
                                                                        text:
                                                                            "Số điện thoại: ${dataTransfer.receiverPhone ?? ''}",
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              6),
                                                                      _buildInfoRow(
                                                                        icon: Icons
                                                                            .verified_user,
                                                                        text:
                                                                            "Người duyệt: ${dataTransfer.reviewer?.userContactName ?? ''}",
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              6),
                                                                      _buildInfoRow(
                                                                        icon: Icons
                                                                            .calendar_today,
                                                                        text:
                                                                            "Ngày tạo: ${formatDateTime(dataTransfer.createdAt.toString())}",
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              }),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is GetListTransferStateFailure) {
                  return ErrorDialog(
                    eventConfirm: () {
                      Navigator.pop(context);
                    },
                    errorText: 'Có lỗi khi tải dữ liệu: ${state.message}',
                  );
                }
                return const Center(child: NoDataFoundWidget());
              },
            )));
  }
}
