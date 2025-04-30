import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_bloc.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_event.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_state.dart';
import 'package:scan_barcode_app/bloc/home/home_bloc/home_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/home/home_bloc/home_screen_event.dart';
import 'package:scan_barcode_app/bloc/home/home_bloc/home_screen_state.dart';
import 'package:scan_barcode_app/bloc/menu/menu_bloc.dart';
import 'package:scan_barcode_app/data/models/home/home_chart_data_model.dart';
import 'package:scan_barcode_app/data/models/home/setup_dashboard_model.dart';
import 'package:scan_barcode_app/data/models/infor_account_model.dart';
import 'package:scan_barcode_app/data/models/menu/menu.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/audit_epacket/audit_epacket.dart';
import 'package:scan_barcode_app/ui/screen/debit/debit_screen.dart';
import 'package:scan_barcode_app/ui/screen/home/filter_dashboard_home.dart';
import 'package:scan_barcode_app/ui/screen/home/percent_indicator.dart';
import 'package:scan_barcode_app/ui/screen/home/title_menu_home.dart';
import 'package:scan_barcode_app/ui/screen/recharge/selected_method_screen.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/home_sale_manager.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/list_scan/list_scan_import_code.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/list_scan/list_scan_over_48h.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_bag_code_export_screen.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_return_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipment/package_manager_screen.dart';
import 'package:scan_barcode_app/ui/screen/shipment/create_new_shipment.dart';
import 'package:scan_barcode_app/ui/screen/order/faq_screen.dart';
import 'package:scan_barcode_app/ui/screen/order/order_pickup_screen.dart';
import 'package:scan_barcode_app/ui/screen/recharge/recharge_history.dart';
import 'package:scan_barcode_app/ui/screen/profile/change_password.dart';
import 'package:scan_barcode_app/ui/screen/ticket/ticket_manager.dart';
import 'package:scan_barcode_app/ui/screen/transfer_list/transfer_list_screen.dart';
import 'package:scan_barcode_app/ui/screen/wallet_fluctuations/wallet_fluctuations_screen.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/chart_home.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/screen/scan_code/scan_screen/scan_code_import_screen.dart';
import 'package:scan_barcode_app/ui/widgets/scan_screen/scan_screen.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InforAccountModel? dataUser;
  HomeChartDataModel? homeChartData;
  SetUpDashBoardModel? setUpDashBoardModel;
  MenuResponse? menuModel;
  bool isShowDashBoard = false;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _opacity = ValueNotifier<double>(1.0);

  final _dateStartController = TextEditingController();
  final _dateEndController = TextEditingController();
  final branchTextController = TextEditingController();
  final statusTextController = TextEditingController();
  final accountTypeTextController = TextEditingController();
  final serviceTypeTextController = TextEditingController();
  final dateTypeTextController = TextEditingController();
  final dashTypeTextController = TextEditingController();
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentIndex = 0;
  int? branchID;
  void vibrate() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  String currentDateType = "%d-%m-%Y";
  String currentDashType = "number_bill";
  int? currentPositionID;
  int? currentShipmentStatus;
  int? currentCurrentServicesID;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _endDateError;

  List<String> dateFormats = [];
  List<String> dateLabels = [];

  List<String> dashFormats = [];
  List<String> dashLabels = [];

  void getMenuUser() async {
    BlocProvider.of<MenuBloc>(context).add(const GetMenu());
  }

  void handleItemTap(int index, String primary) {
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    final String normalizedPosition = position!.trim().toLowerCase();
    switch (primary) {
      case 'create_shipment':
        vibrate();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => normalizedPosition == 'sale'
                    ? const CreateShipmentScreen(
                        shipmentCode: null,
                        isSale: true,
                      )
                    : const CreateShipmentScreen(
                        shipmentCode: null,
                        isSale: false,
                      )));

        break;
      case "package_manager":
        vibrate();

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
        break;
      case "ticket":
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TicketManagerScreen()),
        );
        break;
      // case "password":
      //   vibrate();

      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => const TransactionHistoryScreen()),
      //   );
      //   break;
      case "sale_manager":
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SaleManagerScreen()),
        );
        break;
      case "transaction":
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const TransactionHistoryScreen()),
        );
        break;
      case "quan_ly_bien_dong_vi":
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const WalletFluctuationsScreen()),
        );
        break;
      case "debit_accountant_fwd":
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DebitScreen()),
        );
        break;
      case "transfer_list":
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransferListScreen(
              // Pass user position as parameter
              userPosition: normalizedPosition,
              // Pass permissions as boolean flags
              canUploadLabel: normalizedPosition != 'sale' &&
                  normalizedPosition != 'fwd' &&
                  normalizedPosition != 'ops-leader' &&
                  normalizedPosition != 'ops_pickup',
              canUploadPayment: normalizedPosition != 'fwd',
            ),
          ),
        );
        break;
      case "password":
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
        );
        break;
      case "scan_nhap_hang":
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ScanCodeImportScreenWithController(
                  titleScrenn: titleMiniMenuTab1[4])),
        );
        break;
      case "audit_epacket":
        vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AuditEpacketScreen(
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
                  )),
        );

      case "list_scan_nhap":
        vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ListScanImportCodeScreen()),
        );

        break;
      case "list_hang_qua_48h":
        vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ListScanOver48HCodeScreen()),
        );

        break;
    }
  }

  void handleItemTap2(int index) {
    switch (index) {
      case 0:
        vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ListScanImportCodeScreen()),
        );

        break;
      case 1:
        vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ListScanOver48HCodeScreen()),
        );
        break;
      case 2:
        vibrate();
        break;
      case 3:
        vibrate();
        break;
    }
  }

  void init() async {
    BlocProvider.of<HomeScreenBloc>(context).add(
      HomeScreenButtonPressed(),
    );

    BlocProvider.of<HomeScreenDashBoardBloc>(context).add(
      GetHomeScreenDashBoard(
          chartTypeDate: currentDateType,
          chartTypeTotal: currentDashType,
          positionID: null,
          shipmentStatus: null,
          shipmentBranchId: null,
          shipmentServiceId: null,
          startDate: null,
          endDate: null),
    );

    BlocProvider.of<FilterDashBoardBloc>(context).add(
      GetDataFilterDashBoardEvent(),
    );
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
    }
  }

  void applyFilterFuntion() {
    setState(() {
      Navigator.pop(context);

      BlocProvider.of<HomeScreenDashBoardBloc>(context).add(
        GetHomeScreenDashBoard(
            chartTypeDate: currentDateType,
            chartTypeTotal: currentDashType,
            positionID: currentPositionID,
            shipmentStatus: currentShipmentStatus,
            shipmentBranchId: currentShipmentStatus,
            shipmentServiceId: currentCurrentServicesID,
            startDate: _startDate?.toString(),
            endDate: _endDate?.toString()),
      );
    });
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      _dateStartController.clear();
      _dateEndController.clear();
      dateTypeTextController.clear();
      dashTypeTextController.clear();
      branchTextController.clear();
      statusTextController.clear();
      accountTypeTextController.clear();
      serviceTypeTextController.clear();
      _startDate = null;
      _endDate = null;
      branchID = null;
      currentPositionID = null;
      currentShipmentStatus = null;
      currentCurrentServicesID = null;
      currentDateType = "%d-%m-%Y";
      currentDashType = "number_bill";
    });
    Navigator.pop(context);
    BlocProvider.of<HomeScreenDashBoardBloc>(context).add(
      GetHomeScreenDashBoard(
          chartTypeDate: currentDateType,
          chartTypeTotal: currentDashType,
          positionID: null,
          shipmentStatus: null,
          shipmentBranchId: null,
          shipmentServiceId: null,
          startDate: null,
          endDate: null),
    );
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    getMenuUser();
    super.initState();
    init();

    _scrollController.addListener(_onScroll);
  }

  void _updateBrandID(int newBrandID) {
    setState(() {
      branchID = newBrandID;
    });
  }

  void _updatePositionID(int newPositionID) {
    setState(() {
      currentPositionID = newPositionID;
    });
  }

  void _updateShipmentStatus(int newShipmentStatusID) {
    setState(() {
      currentShipmentStatus = newShipmentStatusID;
    });
  }

  void _updateServicesID(int newServicesID) {
    setState(() {
      currentCurrentServicesID = newServicesID;
    });
  }

  void _updateCurrentDateFormats(String newCurrentDateFormats) {
    setState(() {
      currentDateType = newCurrentDateFormats;
    });
  }

  void _updateCurrentDashFormats(String newCurrentDashFormats) {
    setState(() {
      currentDashType = newCurrentDashFormats;
    });
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    double newOpacity = 1.0 - (offset / 200.0);
    if (newOpacity < 0.0) newOpacity = 0.0;
    if (newOpacity > 1.0) newOpacity = 1.0;
    _opacity.value = newOpacity;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
  }

// Phương thức để tạo danh sách các items cho CarouselSlider
  // Phương thức để tạo danh sách các items cho CarouselSlider
  List<Widget> _buildCarouselItems() {
    List<Widget> carouselPages = [];
    List<MenuItem> allVisibleItems = [];

    // Check if menuModel is null
    if (menuModel != null) {
      // Thu thập tất cả các menu items có isShow = true từ tất cả danh mục
      for (var category in menuModel!.menu) {
        category.menus.forEach((key, item) {
          if (item.isShow &&
              item.primary != 'bulk_upload' &&
              item.primary != 'dashboard' &&
              item.primary != 'shipment_approve_manager' &&
              item.primary != 'order_pickup' &&
              item.primary != 'notifications' &&
              item.primary != 'create_nz_post' &&
              item.primary != 'mawb_manager' &&
              item.primary != 'label_history' &&
              item.primary != 'api_doccument' &&
              item.primary != 'upload_logo_service' &&
              item.primary != 'sms_kiki_manager' &&
              item.primary != 'scan_nhap_hang' &&
              item.primary != 'scan_xuat_hang' &&
              item.primary != 'scan_tra_hang' &&
              item.primary != 'scan_tra_hang' &&
              item.primary != 'list_bag_code' &&
              item.primary != 'list_bag_code_uk' &&
              item.primary != 'ticket' &&
              item.primary != 'quan_ly_he_thong' &&
              item.primary != 'scan_transit_hn' &&
              item.primary != 'quan_ly_shipment_pending' &&
              item.primary != 'quan_ly_debit_fwd' &&
              item.primary != 'quan_ly_credit' &&
              item.primary != 'quan_ly_statement' &&
              item.primary != 'quan_ly_chi_tieu' &&
              item.primary != 'manager_recharge') {
            allVisibleItems.add(item);
          }
        });
      }
    }

    // Thêm các items cố định vào cuối
    allVisibleItems.addAll([
      MenuItem(
          primary: 'ticket',
          title: "Ticket",
          icon: "airplane_ticket",
          route: "/ticket",
          isShow: true),
      MenuItem(
          primary: 'transaction',
          title: "Giao dịch",
          icon: "history",
          route: "/transaction",
          isShow: true),
      MenuItem(
          title: "Mật khẩu",
          icon: "lock",
          route: "/password",
          isShow: true,
          primary: 'password'),
    ]);

    // Chia thành các trang, mỗi trang đúng 8 items (2 hàng x 4 cột)
    int itemsPerPage = 8;
    int pageCount = (allVisibleItems.length / itemsPerPage).ceil();

    for (int i = 0; i < pageCount; i++) {
      int startIndex = i * itemsPerPage;
      int endIndex = math.min((i + 1) * itemsPerPage, allVisibleItems.length);
      List<MenuItem> pageItems = allVisibleItems.sublist(startIndex, endIndex);

      carouselPages.add(
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 cột
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.9, // Điều chỉnh để tránh overflow
          ),
          itemCount: pageItems.length,
          itemBuilder: (context, index) {
            return _buildMenuItem(pageItems[index], index);
          },
        ),
      );
    }

    return carouselPages;
  }

// Phương thức để xây dựng FWD Menu (cho người dùng với positionId 4 hoặc 5)
  Widget _buildFWDMenu() {
    // Lọc menu dành cho FWD users
    if (menuModel == null || menuModel!.menu == null) {
      return Container(); // Hoặc widget loading
    }

    List<MenuItem> fwdItems = [];
    for (var category in menuModel!.menu) {
      category.menus.forEach((key, item) {
        if (item.isShow &&
                item.primary != 'bulk_upload' &&
                item.primary != 'dashboard' &&
                item.primary != 'shipment_approve_manager' &&
                item.primary != 'order_pickup' &&
                item.primary != 'notifications' &&
                item.primary !=
                    'api_doccument' /*&&
            item.primary != 'package_manager'*/
            ) {
          fwdItems.add(item);
        }
      });
    }

    // Thêm các items cố định vào cuối
    fwdItems.addAll([
      MenuItem(
          primary: 'ticket',
          title: "Ticket",
          icon: "airplane_ticket",
          route: "/ticket",
          isShow: true),
      MenuItem(
          title: "Mật khẩu",
          icon: "lock",
          route: "/password",
          isShow: true,
          primary: 'password'),
      MenuItem(
          primary: 'transaction',
          title: "Giao dịch",
          icon: "history",
          route: "/transaction",
          isShow: true),
    ]);

    // Giới hạn hiển thị tối đa 2 dòng (8 items) và cho phép kéo ngang
    // nếu có nhiều hơn 8 items
    int itemsPerRow = 4;
    int maxRows = 2;
    int maxItemsVisible = itemsPerRow * maxRows;

    // Chia thành các trang
    int pageCount = (fwdItems.length / maxItemsVisible).ceil();

    if (pageCount <= 1) {
      // Nếu chỉ có 1 trang (≤ 8 items), hiển thị bình thường
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: 0.9, // Điều chỉnh để tránh overflow
        ),
        itemCount: fwdItems.length,
        itemBuilder: (context, index) {
          return _buildMenuItem(fwdItems[index], index);
        },
      );
    } else {
      // Nếu có nhiều hơn 1 trang, dùng PageView để cho phép kéo ngang
      return Column(
        children: [
          SizedBox(
            height: 230.h, // Điều chỉnh chiều cao để vừa 2 dòng
            child: PageView.builder(
              controller: PageController(),
              onPageChanged: (index) {
                // Cập nhật index để hiển thị dots indicator
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: pageCount,
              itemBuilder: (context, pageIndex) {
                int startIndex = pageIndex * maxItemsVisible;
                int endIndex = math.min(
                    (pageIndex + 1) * maxItemsVisible, fwdItems.length);
                List<MenuItem> pageItems =
                    fwdItems.sublist(startIndex, endIndex);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                    childAspectRatio: 0.9, // Điều chỉnh để tránh overflow
                  ),
                  itemCount: pageItems.length,
                  itemBuilder: (context, index) {
                    return _buildMenuItem(pageItems[index], index);
                  },
                );
              },
            ),
          ),
        ],
      );
    }
  }

// Phương thức để xây dựng từng menu item với SVG icon
  Widget _buildMenuItem(MenuItem item, int index) {
    // Xác định loại icon
    Widget iconWidget;

    if (item.icon.contains('fas fa-') || item.icon.contains('fa-')) {
      // Trường hợp icon là FontAwesome
      String iconName = _extractFontAwesomeIconName(item.icon);
      iconWidget = FaIcon(
        _getFontAwesomeIcon(iconName),
        size: 24.sp,
        color: Colors.white,
      );
    } else if (item.icon.contains('<svg') && item.icon.contains('</svg>')) {
      // Trường hợp icon là SVG
      iconWidget = SvgPicture.string(
        item.icon,
        width: 24.sp,
        height: 24.sp,
        color: Colors.white,
      );
    } else {
      // Trường hợp icon là tên icon thông thường (Material Icons)
      IconData iconData = _getIconData(item.icon);
      iconWidget = Icon(
        iconData,
        size: 24.sp,
        color: Colors.white,
      );
    }

    return InkWell(
      onTap: () {
        handleItemTap(index, item.primary);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: iconWidget,
            ),
          ),
          SizedBox(
            height: 5.h,
          ),
          SizedBox(
            width: 75.w,
            child: TextApp(
              isOverFlow: false,
              softWrap: true,
              textAlign: TextAlign.center,
              text: item.title,
              fontWeight: FontWeight.bold,
              fontsize: 12.sp,
              color: Colors.black,
              maxLines: 3,
            ),
          )
        ],
      ),
    );
  }

// Phương thức để trích xuất tên icon từ chuỗi HTML FontAwesome
  String _extractFontAwesomeIconName(String iconHtml) {
    // Xử lý chuỗi <i class=\"fas fa-wallet\"></i>
    RegExp regExp = RegExp(r'fa-([a-zA-Z0-9-]+)');
    var match = regExp.firstMatch(iconHtml);
    return match?.group(1) ?? 'question-circle'; // mặc định nếu không tìm thấy
  }

// Phương thức để chuyển đổi tên icon FontAwesome thành IconData
  IconData _getFontAwesomeIcon(String iconName) {
    // Bạn cần map tên icon với IconData tương ứng từ package font_awesome_flutter
    // Đây là một số ví dụ, bạn sẽ cần bổ sung thêm các icon khác
    switch (iconName) {
      case 'wallet':
        return FontAwesomeIcons.wallet;
      case 'chart-line':
        return FontAwesomeIcons.chartLine;
      case 'box':
        return FontAwesomeIcons.box;
      case 'truck':
        return FontAwesomeIcons.truck;
      case 'user':
        return FontAwesomeIcons.user;
      case 'cog':
      case 'gear':
        return FontAwesomeIcons.gear;
      case 'file':
        return FontAwesomeIcons.file;
      case 'file-invoice-dollar':
        return FontAwesomeIcons.fileInvoiceDollar;
      // Thêm các icon khác tùy theo nhu cầu
      default:
        return FontAwesomeIcons.circleQuestion; // Icon mặc định
    }
  }

// Phương thức chuyển đổi chuỗi tên icon thành IconData (cho Material Icons)
  IconData _getIconData(String iconName) {
    // Bạn có thể mở rộng phương thức này để hỗ trợ các loại icon khác
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'person':
        return Icons.person;
      case 'settings':
        return Icons.settings;

      case 'airplane_ticket':
        return Icons.airplane_ticket;
      case 'history':
        return Icons.history;
      case 'lock':
        return Icons.lock;
      // Thêm các icon khác tùy theo nhu cầu
      default:
        return Icons.help_outline; // Icon mặc định
    }
  }

  @override
  Widget build(BuildContext context) {
    final int? positionID = StorageUtils.instance.getInt(key: 'positionID');
    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<MenuBloc, MenuState>(listener: (context, state) {
            if (state is MenuStateSuccess) {
              setState(() {
                menuModel = state.menuResponse;
              });
            }
          }),
          BlocListener<HomeScreenDashBoardBloc, HomeScreenDashBoardState>(
            listener: (context, state) {
              if (state is HomeScreenDashBoardStateSuccess) {
                log("GET DASHBOARD SUCCESS");

                setState(() {
                  homeChartData = state.homeChartDataModel;
                  isShowDashBoard = true;
                });
              } else if (state is HomeScreenDashBoardStateFailure) {
                isShowDashBoard = false;
              }
            },
          ),
          BlocListener<FilterDashBoardBloc, FilterDashBoardState>(
            listener: (context, state) {
              if (state is FilterDashBoardStateSuccess) {
                setUpDashBoardModel = state.setUpDashBoardModel;
                Map<String, String> filtersByDate =
                    setUpDashBoardModel!.filtersByDate.toMap();
                filtersByDate.forEach((key, value) {
                  dateFormats.add(key);
                  dateLabels.add(value);
                });
                Map<String, String> filtersByDash =
                    setUpDashBoardModel!.filtersByType.toMap();
                filtersByDash.forEach((key, value) {
                  dashFormats.add(key);
                  dashLabels.add(value);
                });
              } else if (state is FilterDashBoardStateFailure) {}
            },
          ),
        ],
        child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
            builder: (context, state) {
          if (state is HomeScreenLoading) {
            return Center(
              child: SizedBox(
                width: 100.w,
                height: 100.w,
                child: Lottie.asset('assets/lottie/loading_kango.json'),
              ),
            );
          } else if (state is HomeScreenFailure) {
            return AlertDialog(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.w),
              ),
              actionsPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.only(
                  top: 35.w, bottom: 30.w, left: 35.w, right: 35.w),
              titlePadding: EdgeInsets.all(15.w),
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextApp(
                    text: "CÓ LỖI XẢY RA !",
                    fontsize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: SizedBox(
                      width: 250.w,
                      height: 250.w,
                      child: Lottie.asset('assets/lottie/error_dialog.json',
                          fit: BoxFit.contain),
                    ),
                  ),
                  TextApp(
                    text: "Đã có lỗi xảy ra! \nVui lòng liên hệ quản trị viên.",
                    fontsize: 18.sp,
                    softWrap: true,
                    isOverFlow: false,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Container(
                    width: 150.w,
                    height: 50.h,
                    child: ButtonApp(
                      event: () {
                        StorageUtils.instance.removeKey(key: 'token');
                        StorageUtils.instance.removeKey(key: 'branch_response');
                        navigatorKey.currentContext?.go('/');
                      },
                      text: "Xác nhận",
                      fontsize: 14.sp,
                      colorText: Colors.white,
                      backgroundColor: Colors.black,
                      outlineColor: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is HomeScreenSuccess) {
            dataUser = state.dataInforAccount;
            return SafeArea(
                child: Stack(children: [
              ValueListenableBuilder<double>(
                valueListenable: _opacity,
                builder: (context, opacity, child) {
                  return AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/test_bg_2.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              RefreshIndicator(
                color: Theme.of(context).colorScheme.primary,
                onRefresh: () async {
                  init();
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
                        child: Container(
                            height: 100.h,
                            color: Colors.transparent,
                            child: Column(
                              children: [
                                // Row(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     SizedBox(
                                //       width: 100.w,
                                //       height: 50.w,
                                //       child: Image.asset(
                                //         "assets/images/logo_kango_2.png",
                                //         fit: BoxFit.cover,
                                //       ),
                                //     ),
                                //     BlocProvider(
                                //       create: (context) => LogoutBloc(),
                                //       child:
                                //           BlocListener<LogoutBloc, LogoutState>(
                                //         listener: (context, state) {
                                //           if (state is LogoutSuccess) {
                                //             navigatorKey.currentContext
                                //                 ?.go('/');
                                //           } else if (state is LogoutFailure) {
                                //             showCustomDialogModal(
                                //                 context: navigatorKey
                                //                     .currentContext!,
                                //                 textDesc: state.errorText ??
                                //                     'Không thể kết nối đến máy chủ',
                                //                 title: "Thông báo",
                                //                 colorButtonOk: Colors.red,
                                //                 btnOKText: "Xác nhận",
                                //                 typeDialog: "error",
                                //                 eventButtonOKPress: () {},
                                //                 isTwoButton: false);
                                //           }
                                //         },
                                //         child: BlocBuilder<LogoutBloc,
                                //             LogoutState>(
                                //           builder: (context, state) {
                                //             return InkWell(
                                //               onTap: () {
                                //                 showCustomDialogModal(
                                //                     context: navigatorKey
                                //                         .currentContext!,
                                //                     textDesc:
                                //                         "Bạn có chắc muốn đăng xuất ?",
                                //                     title: "Thông báo",
                                //                     colorButtonOk: Colors.blue,
                                //                     btnOKText: "Xác nhận",
                                //                     typeDialog: "question",
                                //                     eventButtonOKPress: () {
                                //                       context
                                //                           .read<LogoutBloc>()
                                //                           .add(
                                //                             LogoutButtonPressed(),
                                //                           );
                                //                     },
                                //                     isTwoButton: true);
                                //               },
                                //               child: Padding(
                                //                   padding: EdgeInsets.all(8.w),
                                //                   child: Container(
                                //                     // width: 1.sw,
                                //                     padding: EdgeInsets.only(
                                //                         left: 5.w, right: 5.w),
                                //                     decoration: BoxDecoration(
                                //                       borderRadius:
                                //                           BorderRadius.circular(
                                //                               5.r),
                                //                       color: Colors.white,
                                //                       boxShadow: [
                                //                         BoxShadow(
                                //                           color: Colors.grey
                                //                               .withOpacity(0.5),
                                //                           spreadRadius: 2,
                                //                           blurRadius: 4,
                                //                           offset: const Offset(
                                //                               0,
                                //                               3), // changes position of shadow
                                //                         ),
                                //                       ],
                                //                     ),
                                //                     child: Row(
                                //                       children: [
                                //                         TextApp(
                                //                           text: "Đăng xuất",
                                //                           color: Colors.black,
                                //                           fontsize: 14.sp,
                                //                         ),
                                //                         SizedBox(width: 5.w),
                                //                         SizedBox(
                                //                             width: 30.w,
                                //                             height: 30.w,
                                //                             child: const Icon(
                                //                               Icons.logout,
                                //                               color: Colors.red,
                                //                             )),
                                //                       ],
                                //                     ),
                                //                   )),
                                //             );
                                //           },
                                //         ),
                                //       ),
                                //     )
                                //   ],
                                // ),
                                // // SizedBox(
                                // //   height: 15.h,
                                // // ),
                                // Row(
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //     Container(
                                //       width: 50.w,
                                //       height: 50.w,
                                //       decoration: BoxDecoration(
                                //           borderRadius:
                                //               BorderRadius.circular(25.w),
                                //           border: Border.all(
                                //               width: 2.w, color: Colors.white),
                                //           color: Colors.black),
                                //       child: ClipRRect(
                                //         borderRadius:
                                //             BorderRadius.circular(30.w),
                                //         child: dataUser?.data.userLogo == null
                                //             ? Image.asset(
                                //                 'assets/images/user_avatar.png',
                                //                 fit: BoxFit.contain,
                                //               )
                                //             : Container(
                                //                 width: 50.w,
                                //                 height: 50.w,
                                //                 child: ClipRRect(
                                //                   borderRadius:
                                //                       BorderRadius.circular(
                                //                           30.w),
                                //                   child: CachedNetworkImage(
                                //                     fit: BoxFit.cover,
                                //                     imageUrl: httpImage +
                                //                         dataUser!
                                //                             .data.userLogo!,
                                //                     placeholder:
                                //                         (context, url) =>
                                //                             SizedBox(
                                //                       height: 20.w,
                                //                       width: 20.w,
                                //                       child: const Center(
                                //                           child:
                                //                               CircularProgressIndicator()),
                                //                     ),
                                //                     errorWidget: (context, url,
                                //                             error) =>
                                //                         const Icon(Icons.error),
                                //                   ),
                                //                 ),
                                //               ),
                                //       ),
                                //     ),
                                //     SizedBox(
                                //       width: 15.w,
                                //     ),
                                //     Column(
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.start,
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.center,
                                //       children: [
                                //         Row(
                                //           children: [
                                //             TextApp(
                                //               text: "Xin chào, ",
                                //               color: Colors.black,
                                //               fontsize: 14.sp,
                                //             ),
                                //             TextApp(
                                //               text: dataUser
                                //                       ?.data.userContactName ??
                                //                   '',
                                //               color: Theme.of(context)
                                //                   .colorScheme
                                //                   .primary,
                                //               fontsize: 14.sp,
                                //               fontWeight: FontWeight.bold,
                                //             ),
                                //           ],
                                //         ),
                                //         SizedBox(
                                //           height: 5.w,
                                //         ),
                                //         Container(
                                //           width: 300.w,
                                //           height: 50.h,
                                //           child: TextApp(
                                //             text: dataUser
                                //                     ?.data.userCompanyName ??
                                //                 '',
                                //             color: Colors.black,
                                //             fontsize: 14.sp,
                                //             maxLines: 2,
                                //             fontWeight: FontWeight.bold,
                                //           ),
                                //         ),
                                //       ],
                                //     )
                                //   ],
                                // ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // User Avatar Section
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 50.w,
                                            height: 50.w,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25.w),
                                                border: Border.all(
                                                    width: 2.w,
                                                    color: Colors.white),
                                                color: Colors.black),
                                            child: Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(30.w),
                                                child: dataUser
                                                            ?.data.userLogo ==
                                                        null
                                                    ? Image.asset(
                                                        'assets/images/user_avatar.png',
                                                        fit: BoxFit.contain,
                                                      )
                                                    : SizedBox(
                                                        width: 50.w,
                                                        height: 50.w,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30.w),
                                                          child:
                                                              CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl: httpImage +
                                                                dataUser!.data
                                                                    .userLogo!,
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    SizedBox(
                                                              height: 20.w,
                                                              width: 20.w,
                                                              child: const Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                            ),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextApp(
                                                      text: "Xin chào, ",
                                                      color: Colors.black,
                                                      fontsize: 14.sp,
                                                    ),
                                                    Flexible(
                                                      child: TextApp(
                                                        text: dataUser?.data
                                                                .userContactName ??
                                                            '',
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        fontsize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        isOverFlow: true,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5.w),
                                                TextApp(
                                                  text: dataUser?.data
                                                          .userCompanyName ??
                                                      '',
                                                  color: Colors.black,
                                                  fontsize: 14.sp,
                                                  maxLines: 2,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    // Logout Button Section
                                    BlocProvider(
                                      create: (context) => LogoutBloc(),
                                      child:
                                          BlocListener<LogoutBloc, LogoutState>(
                                        listener: (context, state) {
                                          if (state is LogoutSuccess) {
                                            navigatorKey.currentContext
                                                ?.go('/');
                                          } else if (state is LogoutFailure) {
                                            showCustomDialogModal(
                                                context: navigatorKey
                                                    .currentContext!,
                                                textDesc: state.errorText ??
                                                    'Không thể kết nối đến máy chủ',
                                                title: "Thông báo",
                                                colorButtonOk: Colors.red,
                                                btnOKText: "Xác nhận",
                                                typeDialog: "error",
                                                eventButtonOKPress: () {},
                                                isTwoButton: false);
                                          }
                                        },
                                        child: BlocBuilder<LogoutBloc,
                                            LogoutState>(
                                          builder: (context, state) {
                                            return InkWell(
                                              onTap: () {
                                                showCustomDialogModal(
                                                    context: navigatorKey
                                                        .currentContext!,
                                                    textDesc:
                                                        "Bạn có chắc muốn đăng xuất ?",
                                                    title: "Thông báo",
                                                    colorButtonOk: Colors.blue,
                                                    btnOKText: "Xác nhận",
                                                    typeDialog: "question",
                                                    eventButtonOKPress: () {
                                                      context
                                                          .read<LogoutBloc>()
                                                          .add(
                                                            LogoutButtonPressed(),
                                                          );
                                                    },
                                                    isTwoButton: true);
                                              },
                                              child: Padding(
                                                  padding: EdgeInsets.all(8.w),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5.w,
                                                            vertical: 2.w),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.r),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                          spreadRadius: 2,
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        TextApp(
                                                          text: "Đăng xuất",
                                                          color: Colors.black,
                                                          fontsize: 14.sp,
                                                        ),
                                                        SizedBox(width: 5.w),
                                                        SizedBox(
                                                            width: 30.w,
                                                            height: 30.w,
                                                            child: const Icon(
                                                              Icons.logout,
                                                              color: Colors.red,
                                                            )),
                                                      ],
                                                    ),
                                                  )),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )),
                      ),
                    ),
                    SliverLayoutBuilder(
                        builder: (BuildContext context, constraints) {
                      final scrolled = constraints.scrollOffset > 0;

                      return SliverAppBar(
                        shadowColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        foregroundColor: Colors.white,
                        bottom: PreferredSize(
                          // Add this code
                          preferredSize: Size.fromHeight(50.h), // Add this code
                          child: Container(), // Add this code
                        ),
                        expandedHeight: 150.h,
                        pinned: true,
                        floating: false,
                        backgroundColor:
                            scrolled ? Colors.white : Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          expandedTitleScale: 1.1,
                          centerTitle: true,
                          titlePadding: EdgeInsets.only(top: 20.h),
                          title: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  vibrate();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SelectedMethodRechargeScreen()),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50.w,
                                      height: 50.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25.w),
                                          color: scrolled
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.white),
                                      child: Center(
                                        child: Icon(
                                          Icons.currency_exchange,
                                          size: 28.sp,
                                          color: scrolled
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    !scrolled
                                        ? TextApp(
                                            text: "Nạp tiền",
                                            fontWeight: FontWeight.bold,
                                            fontsize: 14.sp,
                                            color: scrolled
                                                ? Colors.black
                                                : Colors.white,
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 50.w,
                              ),
                              InkWell(
                                onTap: () {
                                  vibrate();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OrderPickUpScreen(
                                              fwdID:
                                                  dataUser!.data.positionId == 5
                                                      ? dataUser!.data.userId
                                                      : null,
                                            )),
                                  );
                                  /*context.push('/home/order_pickup', extra: {
                                    'fwdID': dataUser!.data.positionId == 5
                                        ? dataUser!.data.userId
                                        : null,
                                  });*/
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50.w,
                                      height: 50.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25.w),
                                          color: scrolled
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.white),
                                      child: Center(
                                        child: Icon(
                                          Icons.local_shipping,
                                          size: 28.sp,
                                          color: scrolled
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    !scrolled
                                        ? TextApp(
                                            text: "Pickup",
                                            fontWeight: FontWeight.bold,
                                            fontsize: 14.sp,
                                            color: scrolled
                                                ? Colors.black
                                                : Colors.white,
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //   width: 20.w,
                              // ),
                              // InkWell(
                              //   onTap: () {
                              //     final String? position = StorageUtils.instance
                              //         .getString(key: 'user_position');
                              //     final String normalizedPosition =
                              //         position?.trim().toLowerCase() ?? '';

                              //     vibrate();
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) =>
                              //             PackageManagerScreen(
                              //           // Pass user position as parameter
                              //           userPosition: normalizedPosition,
                              //           // Pass permissions as boolean flags
                              //           canUploadLabel: normalizedPosition !=
                              //                   'sale' &&
                              //               normalizedPosition != 'fwd' &&
                              //               normalizedPosition !=
                              //                   'ops-leader' &&
                              //               normalizedPosition != 'ops_pickup',
                              //           canUploadPayment:
                              //               normalizedPosition != 'fwd',
                              //         ),
                              //       ),
                              //     );
                              //   },
                              //   child: Column(
                              //     mainAxisAlignment: MainAxisAlignment.center,
                              //     crossAxisAlignment: CrossAxisAlignment.center,
                              //     children: [
                              //       Container(
                              //         width: 50.w,
                              //         height: 50.w,
                              //         decoration: BoxDecoration(
                              //             borderRadius:
                              //                 BorderRadius.circular(25.w),
                              //             color: scrolled
                              //                 ? Theme.of(context)
                              //                     .colorScheme
                              //                     .primary
                              //                 : Colors.white),
                              //         child: Center(
                              //           child: Icon(
                              //             Icons.pin_drop,
                              //             size: 28.sp,
                              //             color: scrolled
                              //                 ? Colors.white
                              //                 : Colors.black,
                              //           ),
                              //         ),
                              //       ),
                              //       SizedBox(
                              //         height: 5.h,
                              //       ),
                              //       !scrolled
                              //           ? TextApp(
                              //               text: "Shipment",
                              //               fontWeight: FontWeight.bold,
                              //               fontsize: 14.sp,
                              //               color: scrolled
                              //                   ? Colors.black
                              //                   : Colors.white,
                              //             )
                              //           : Container()
                              //     ],
                              //   ),
                              // ),
                              SizedBox(
                                width: 50.w,
                              ),
                              InkWell(
                                onTap: () {
                                  vibrate();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const FAQScreen()),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50.w,
                                      height: 50.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25.w),
                                          color: scrolled
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.white),
                                      child: Center(
                                        child: Icon(
                                          Icons.info,
                                          size: 28.sp,
                                          color: scrolled
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    !scrolled
                                        ? TextApp(
                                            text: "FAQ",
                                            fontWeight: FontWeight.bold,
                                            fontsize: 14.sp,
                                            color: scrolled
                                                ? Colors.black
                                                : Colors.white,
                                          )
                                        : Container()
                                  ],
                                ),
                              )
                            ],
                          )),
                          background: ClipRRect(
                            borderRadius: BorderRadius.circular(15.r),
                            child: Container(
                              margin: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.r),
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Color.fromARGB(255, 13, 81, 101)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Column(
                          children: [
                            SizedBox(
                              height: 20.h,
                            ),
                            Container(
                              width: 1.sw,
                              child: Column(
                                children: [
                                  // !(dataUser!.data.positionId == 5 ||
                                  //         dataUser!.data.positionId == 4)
                                  //     ? CarouselSlider(
                                  //         controller: _controller,
                                  //         options: CarouselOptions(
                                  //           aspectRatio: 2.0,
                                  //           viewportFraction: 1,
                                  //           enlargeCenterPage: true,
                                  //           enableInfiniteScroll: false,
                                  //           onPageChanged: (index, reason) {
                                  //             setState(() {
                                  //               _currentIndex = index;
                                  //             });
                                  //           },
                                  //         ),
                                  //         items: [
                                  //           //Tab Menu Tab 1
                                  //           GridView.builder(
                                  //             shrinkWrap: true,
                                  //             physics:
                                  //                 const NeverScrollableScrollPhysics(),
                                  //             gridDelegate:
                                  //                 const SliverGridDelegateWithFixedCrossAxisCount(
                                  //               crossAxisCount:
                                  //                   4, // Number of columns
                                  //               crossAxisSpacing: 4.0,
                                  //               mainAxisSpacing: 4.0,
                                  //             ),
                                  //             itemCount: iconListMiniMenuTab1
                                  //                 .length, // Number of items in the grid
                                  //             itemBuilder: (context, index) {
                                  //               return InkWell(
                                  //                 onTap: () {
                                  //                   handleItemTap(index);
                                  //                 },
                                  //                 child: Column(
                                  //                   children: [
                                  //                     Container(
                                  //                       width: 50.w,
                                  //                       height: 50.w,
                                  //                       decoration:
                                  //                           BoxDecoration(
                                  //                         borderRadius:
                                  //                             BorderRadius
                                  //                                 .circular(
                                  //                                     8.r),
                                  //                         color:
                                  //                             Theme.of(context)
                                  //                                 .colorScheme
                                  //                                 .primary,
                                  //                       ),
                                  //                       child: Center(
                                  //                         child: Icon(
                                  //                           size: 24.sp,
                                  //                           iconListMiniMenuTab1[
                                  //                               index],
                                  //                           color: Colors.white,
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                     SizedBox(
                                  //                       height: 5.h,
                                  //                     ),
                                  //                     SizedBox(
                                  //                       width: 75.w,
                                  //                       child: TextApp(
                                  //                         isOverFlow: false,
                                  //                         softWrap: true,
                                  //                         textAlign:
                                  //                             TextAlign.center,
                                  //                         text:
                                  //                             titleMiniMenuTab1[
                                  //                                 index],
                                  //                         fontWeight:
                                  //                             FontWeight.bold,
                                  //                         fontsize: 12.sp,
                                  //                         color: Colors.black,
                                  //                         maxLines: 3,
                                  //                       ),
                                  //                     )
                                  //                   ],
                                  //                 ),
                                  //               );
                                  //             },
                                  //           ),
                                  //           //Tab Menu Tab 2
                                  //           GridView.builder(
                                  //             shrinkWrap: true,
                                  //             physics:
                                  //                 const NeverScrollableScrollPhysics(),
                                  //             gridDelegate:
                                  //                 const SliverGridDelegateWithFixedCrossAxisCount(
                                  //               crossAxisCount:
                                  //                   4, // Number of columns
                                  //               crossAxisSpacing: 4,
                                  //               mainAxisSpacing: 4,
                                  //             ),
                                  //             itemCount: iconListMiniMenuTab2
                                  //                 .length, // Number of items in the grid
                                  //             itemBuilder: (context, index) {
                                  //               return InkWell(
                                  //                 onTap: () {
                                  //                   handleItemTap2(index);
                                  //                 },
                                  //                 child: Column(
                                  //                   children: [
                                  //                     Container(
                                  //                       width: 50.w,
                                  //                       height: 50.w,
                                  //                       decoration:
                                  //                           BoxDecoration(
                                  //                         borderRadius:
                                  //                             BorderRadius
                                  //                                 .circular(
                                  //                                     8.r),
                                  //                         color:
                                  //                             Theme.of(context)
                                  //                                 .colorScheme
                                  //                                 .primary,
                                  //                       ),
                                  //                       child: Center(
                                  //                         child: Icon(
                                  //                           size: 24.sp,
                                  //                           iconListMiniMenuTab2[
                                  //                               index],
                                  //                           color: Colors.white,
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                     SizedBox(
                                  //                       height: 5.h,
                                  //                     ),
                                  //                     SizedBox(
                                  //                       width: 75.w,
                                  //                       child: TextApp(
                                  //                         isOverFlow: false,
                                  //                         softWrap: true,
                                  //                         textAlign:
                                  //                             TextAlign.center,
                                  //                         text:
                                  //                             titleMiniMenuTab2[
                                  //                                 index],
                                  //                         fontWeight:
                                  //                             FontWeight.bold,
                                  //                         maxLines: 3,
                                  //                         fontsize: 12.sp,
                                  //                         color: Colors.black,
                                  //                       ),
                                  //                     )
                                  //                   ],
                                  //                 ),
                                  //               );
                                  //             },
                                  //           )
                                  //         ],
                                  //       )
                                  //     : GridView.builder(
                                  //         shrinkWrap: true,
                                  //         physics:
                                  //             const NeverScrollableScrollPhysics(),
                                  //         gridDelegate:
                                  //             const SliverGridDelegateWithFixedCrossAxisCount(
                                  //           crossAxisCount:
                                  //               4, // Number of columns
                                  //           crossAxisSpacing: 4.0,
                                  //           mainAxisSpacing: 4.0,
                                  //         ),
                                  //         itemCount: iconListMiniMenuTabFWD
                                  //             .length, // Number of items in the grid
                                  //         itemBuilder: (context, index) {
                                  //           return InkWell(
                                  //             onTap: () {
                                  //               handleItemTap(index);
                                  //             },
                                  //             child: Column(
                                  //               mainAxisSize: MainAxisSize.min,
                                  //               children: [
                                  //                 Container(
                                  //                   width: 50.w,
                                  //                   height: 50.w,
                                  //                   decoration: BoxDecoration(
                                  //                     borderRadius:
                                  //                         BorderRadius.circular(
                                  //                             8.r),
                                  //                     color: Theme.of(context)
                                  //                         .colorScheme
                                  //                         .primary,
                                  //                   ),
                                  //                   child: Center(
                                  //                     child: Icon(
                                  //                       size: 24.sp,
                                  //                       iconListMiniMenuTabFWD[
                                  //                           index],
                                  //                       color: Colors.white,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 SizedBox(
                                  //                   height: 5.h,
                                  //                 ),
                                  //                 SizedBox(
                                  //                   width: 75.w,
                                  //                   child: TextApp(
                                  //                     isOverFlow: false,
                                  //                     softWrap: true,
                                  //                     textAlign:
                                  //                         TextAlign.center,
                                  //                     text: titleMiniMenuTabFWD[
                                  //                         index],
                                  //                     fontWeight:
                                  //                         FontWeight.bold,
                                  //                     fontsize: 12.sp,
                                  //                     color: Colors.black,
                                  //                     maxLines: 3,
                                  //                   ),
                                  //                 )
                                  //               ],
                                  //             ),
                                  //           );
                                  //         },
                                  //       ),
                                  // !(dataUser!.data.positionId == 5 ||
                                  //         dataUser!.data.positionId == 4)
                                  //     ? DotsIndicator(
                                  //         dotsCount: 2,
                                  //         position: _currentIndex,
                                  //         decorator: DotsDecorator(
                                  //           size: Size.square(9.w),
                                  //           activeSize: Size(18.w, 9.w),
                                  //           activeShape: RoundedRectangleBorder(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(5.r)),
                                  //         ),
                                  //       )
                                  //     : Container(),
                                  !(dataUser!.data.positionId == 5 ||
                                          dataUser!.data.positionId == 4)
                                      ? CarouselSlider(
                                          controller: _controller,
                                          options: CarouselOptions(
                                            aspectRatio: 1.9,
                                            viewportFraction: 1,
                                            enlargeCenterPage: true,
                                            enableInfiniteScroll: false,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            },
                                          ),
                                          items: _buildCarouselItems(),
                                        )
                                      : _buildFWDMenu(),
                                ],
                              ),
                            ),

                            // Other widgets below the GridView
                            SizedBox(height: 10.h),

                            Padding(
                              padding: EdgeInsets.all(20.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextApp(
                                        text: "Biểu đồ tổng quan",
                                        fontWeight: FontWeight.bold,
                                        fontsize: 16.sp,
                                      ),
                                      // TextApp(
                                      //   text:
                                      //       "từ 01/05/2024 đến 31/08/2024",
                                      //   fontWeight: FontWeight.bold,
                                      //   fontsize: 16.sp,
                                      // ),
                                    ],
                                  ),
                                  FillterDashBoardHomeWidget(
                                    dateStartController: _dateStartController,
                                    dateEndController: _dateEndController,
                                    statusTextController: statusTextController,
                                    branchTextController: branchTextController,
                                    accountTypeTextController:
                                        accountTypeTextController,
                                    serviceTypeTextController:
                                        serviceTypeTextController,
                                    dateTypeTextController:
                                        dateTypeTextController,
                                    dashTypeTextController:
                                        dashTypeTextController,
                                    // brandIDParam: branchID,
                                    listStatus:
                                        setUpDashBoardModel?.shipmentStatus ??
                                            [],
                                    listServices:
                                        setUpDashBoardModel?.services ?? [],
                                    listTypeAccount:
                                        setUpDashBoardModel?.positions ?? [],
                                    listBranch:
                                        setUpDashBoardModel?.branchs ?? [],
                                    listdateType: dateLabels,
                                    listdateFormats: dateFormats,
                                    listdashType: dashLabels,
                                    listdashFormats: dashFormats,
                                    selectDayStart: selectDayStart,
                                    selectDayEnd: selectDayEnd,
                                    getEndDateError: () => _endDateError,
                                    clearFliterFunction: clearFilterFuntion,
                                    applyFliterFunction: applyFilterFuntion,
                                    onBrandIDChanged: _updateBrandID,
                                    onCurrentDateTypeChanged:
                                        _updateCurrentDateFormats,
                                    onCurrentDashTypeChanged:
                                        _updateCurrentDashFormats,
                                    onPositionChanged: _updatePositionID,
                                    onShipmentStatusChanged:
                                        _updateShipmentStatus,
                                    onServicesChanged: _updateServicesID,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20.w, right: 20.w),
                              child: const Divider(
                                height: 1,
                                color: Colors.black,
                              ),
                            ),
                            isShowDashBoard
                                ? Padding(
                                    padding: EdgeInsets.all(20.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                TextApp(
                                                  text: "Tổng đơn: ",
                                                  fontWeight: FontWeight.bold,
                                                  fontsize: 16.sp,
                                                ),
                                                TextApp(
                                                  text: homeChartData!
                                                      .totalNumberBill
                                                      .toString(),
                                                  fontsize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextApp(
                                                  text: "Tổng cân nặng: ",
                                                  fontWeight: FontWeight.bold,
                                                  fontsize: 16.sp,
                                                ),
                                                TextApp(
                                                  text: homeChartData!
                                                          .totalWeight
                                                          .toString() ??
                                                      '0',
                                                  fontsize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                TextApp(
                                                  text: "Doanh thu: ",
                                                  fontWeight: FontWeight.bold,
                                                  fontsize: 16.sp,
                                                ),
                                                TextApp(
                                                  text: homeChartData!
                                                          .totalPrice
                                                          .toString() ??
                                                      '0',
                                                  fontsize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                )
                                              ],
                                            ),
                                            // Row(
                                            //   children: [
                                            //     TextApp(
                                            //       text: "Lợi nhuận: ",
                                            //       fontWeight: FontWeight.bold,
                                            //       fontsize: 16.sp,
                                            //     ),
                                            //     TextApp(
                                            //       text: formatNumber(
                                            //           homeChartData!
                                            //               .totalPriceCustomer
                                            //               .toString()),
                                            //       fontsize: 16.sp,
                                            //       fontWeight: FontWeight.bold,
                                            //       color: Theme.of(context)
                                            //           .colorScheme
                                            //           .primary,
                                            //     )
                                            //   ],
                                            // )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            isShowDashBoard
                                ? HomeChart(
                                    homeChartData: homeChartData!,
                                  )
                                : Container(),
                            SizedBox(
                              height: 30.h,
                            ),
                            positionID != 7
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(20.w),
                                        child: Row(
                                          children: [
                                            TextApp(
                                              text: "Công nợ",
                                              fontWeight: FontWeight.bold,
                                              fontsize: 16.sp,
                                            )
                                          ],
                                        ),
                                      ),
                                      isShowDashBoard
                                          ? PercentIndicator(
                                              userLimitAmountForSale:
                                                  homeChartData!.user
                                                      .userLimitAmountForSale,
                                              remainingLimit: homeChartData!
                                                  .user.userRemainingLimit
                                                  .round(),
                                              currentPercent: homeChartData!
                                                          .user
                                                          .userLimitAmountForSale ==
                                                      0
                                                  ? 0.0 // Tránh chia cho 0
                                                  : (homeChartData!.user
                                                          .userRemainingLimit
                                                          .round() /
                                                      homeChartData!.user
                                                          .userLimitAmountForSale
                                                          .round()),
                                            )
                                          : Container(),
                                    ],
                                  )
                                : Container(),

                            SizedBox(height: 50.h),
                          ],
                        ),
                        childCount: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ]));
          } else {
            log("HomeScreenFailure 22");
            return AlertDialog(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.w),
              ),
              actionsPadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.only(
                  top: 35.w, bottom: 30.w, left: 35.w, right: 35.w),
              titlePadding: EdgeInsets.all(15.w),
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              //
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: SizedBox(
                      width: 250.w,
                      height: 250.w,
                      child: Lottie.asset('assets/lottie/error_dialog.json',
                          fit: BoxFit.contain),
                    ),
                  ),
                  TextApp(
                    text: "Hết phiên đăng nhập \nVui lòng đăng nhập lại.",
                    fontsize: 18.sp,
                    softWrap: true,
                    isOverFlow: false,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Container(
                    width: 150.w,
                    height: 50.h,
                    child: ButtonApp(
                      event: () {
                        StorageUtils.instance.removeKey(key: 'token');
                        StorageUtils.instance.removeKey(key: 'branch_response');
                        navigatorKey.currentContext?.go('/');
                      },
                      text: "Xác nhận",
                      fontsize: 14.sp,
                      colorText: Colors.white,
                      backgroundColor: Colors.black,
                      outlineColor: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }
}
