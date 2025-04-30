import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/data/api/index.dart';
import 'package:scan_barcode_app/data/env/index.dart';
import 'package:scan_barcode_app/data/models/sale_leader/sale_leader_model.dart';
import 'package:scan_barcode_app/data/models/sale_leader/sale_team_leader.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/admin_screen/add_member_to_team_sale.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/add_user_leader.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/filter_sale_team_manager.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/manager_leader_sale.dart';
import 'package:scan_barcode_app/ui/screen/shipment/filter_shipment.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/utils/date_time_picker.dart';
import 'package:scan_barcode_app/ui/utils/header_api.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/button/button_app.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';
import 'package:http/http.dart' as http;

class SaleTeamLeaderManager extends StatefulWidget {
  SaleResponse? saleResponse;
  SaleTeamLeaderManager({super.key, required this.saleResponse});

  @override
  State<SaleTeamLeaderManager> createState() => _SaleTeamManagerState();
}

class _SaleTeamManagerState extends State<SaleTeamLeaderManager> {
  final TextEditingController _monthYearController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final scrollListSaleLeaderController = ScrollController();
  String? _endDateError; //text lỗi khi ngày kết thúc nhỏ hơn ngày bắt đầu
  final textSearchController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  String query = '';
  final formatter = NumberFormat("#,###", "vi_VN");

  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isLoadingNotifierTransferMember =
      ValueNotifier<bool>(false);
  List<SaleTeamLeader> listSaleTeamLeader = [];
  @override
  void initState() {
    BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(
        const GetSaleTeamLeader(
            startDate: null, endDate: null, keywords: null));
    scrollListSaleLeaderController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _isLoadingNotifier.dispose();
    _dateEndController.clear();
    _dateStartController.clear();
    super.dispose();
  }

  void _onScroll() {
    final state = BlocProvider.of<GetListSaleTeamLeaderBloc>(context).state;

    // Chỉ load more nếu chưa đạt max và không đang load
    if (state is GetSaleTeamLeaderStateSuccess && !state.hasReachedMax) {
      if (scrollListSaleLeaderController.position.maxScrollExtent ==
          scrollListSaleLeaderController.offset) {
        final String formattedStartDate = formatStartDateForAPI(_startDate);
        final String formattedEndDate = formatEndDateForAPI(_endDate);

        BlocProvider.of<GetListSaleTeamLeaderBloc>(context)
            .add(LoadMoreSaleTeamLeader(
          startDate: formattedStartDate.isNotEmpty ? formattedStartDate : null,
          endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
          keywords: query,
        ));
      }
    }
  }

  String formatEndDateForAPI(DateTime? date) {
    if (date == null) return '';
    // Format as DD-MM-YYYY with end of day (same format but conceptually representing end of day)
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String formatStartDateForAPI(DateTime? date) {
    if (date == null) return '';
    // Format as DD-MM-YYYY with beginning of day
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> applyFilterFuntion() async {
    final String formattedStartDate = formatStartDateForAPI(_startDate);
    final String formattedEndDate = formatEndDateForAPI(_endDate);

    log('Start date formatted: $formattedStartDate');
    log('End date formatted: $formattedEndDate');

    Navigator.pop(context);

    BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(GetSaleTeamLeader(
      startDate: formattedStartDate.isNotEmpty ? formattedStartDate : null,
      endDate: formattedEndDate.isNotEmpty ? formattedEndDate : null,
      keywords: query,
    ));
  }

  void searchProduct(String query) {
    mounted
        ? setState(() {
            this.query = query;

            BlocProvider.of<GetListSaleTeamLeaderBloc>(context)
                .add(GetSaleTeamLeader(
              startDate: _startDate?.toString(),
              endDate: _endDate?.toString(),
              keywords: query,
            ));
          })
        : null;
  }

  Future<void> clearFilterFuntion() async {
    setState(() {
      _endDateError = null;
      _monthYearController.clear();
      _dateStartController.clear();
      _dateEndController.clear();
      _startDate = null;
      _endDate = null;
    });
    Navigator.pop(context);
    BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(GetSaleTeamLeader(
      startDate: null,
      endDate: null,
      keywords: query,
    ));
  }

  void onDateRangeSelected(DateTime firstDay, DateTime lastDay) {
    setState(() {
      _startDate = firstDay;
      _endDate = lastDay;
    });
  }

  /// This builds cupertion date picker in iOS
  void buildCupertinoDateStartPicker(BuildContext context) {
    showCupertinoDatePicker(
      context,
      initialDate: _startDate,
      onDateChanged: (picked) {
        setState(() {
          _startDate = picked;
        });
      },
      onCancel: () {
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
    showCupertinoDatePicker(
      context,
      initialDate: _endDate,
      onDateChanged: (picked) {
        setState(() {
          _endDate = picked;
        });
      },
      onCancel: () {
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
    showMaterialDatePicker(
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
    );
  }

  Future<void> buildMaterialDateEndPicker(BuildContext context) async {
    showMaterialDatePicker(
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

  Future<void> _updateStatusMember({
    int? memberID,
    int? teamID,
    required int kind,
  }) async {
    if (_isLoadingNotifier.value) return; // Tránh gửi request khi đang load
    _isLoadingNotifier.value = true;

    context.read<UpdateStatusMemeberBloc>().add(
          UpdateStatusMember(
            memberID: memberID ?? 0,
            teamId: teamID ?? 0,
            kind: kind,
          ),
        );
  }

  // Loại bỏ phương thức trùng lặp và tối ưu hóa luồng xử lý
  Future<void> _transferMemberToTeam({
    required int? memberID,
    required int? teamID,
  }) async {
    // Ngăn chặn nhiều lần gọi khi đang xử lý
    if (_isLoadingNotifierTransferMember.value) return;

    _isLoadingNotifierTransferMember.value = true;

    // Thực hiện chuyển thành viên
    context.read<TransferMemberToTeamBloc>().add(
          TransferMemberToTeam(
            memberID: memberID ?? 0,
            teamId: teamID ?? 0,
          ),
        );
  }

  Future<void> _deleteTeamSale({
    required int? teamID,
  }) async {
    // Thực hiện chuyển thành viên
    context.read<DeleteTeamBloc>().add(
          DeleteTeamSale(
            teamId: teamID ?? 0,
          ),
        );
  }

  Future<void> showSaleTeamSelectionDialog(
      BuildContext context, int? memberID) async {
    SaleTeamLeader? selectedTeam;
    bool isDropdownOpen = false;

    Future<List<SaleTeamLeader>> fetchSaleTeamLeaders(int page) async {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl$getSaleLeaderList'),
          headers: ApiUtils.getHeaders(isNeedToken: true),
          body: jsonEncode({
            'is_api': true,
            'paginate': {'limit': 10, 'page': page},
            'filters': {
              'date_range': {'start_date': null, 'end_date': null},
              'keywords': null,
            },
          }),
        );
        final data = jsonDecode(response.body);
        if (data['status'] == 200) {
          final saleResponse = SaleLeaderListResponse.fromJson(data);
          return saleResponse.teams ?? [];
        } else {
          throw Exception(data['message']['text']);
        }
      } catch (e) {
        throw Exception('Lỗi khi lấy danh sách: $e');
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        int currentPage = 1;
        bool hasReachedMax = false;
        List<SaleTeamLeader> allTeams = [];
        final ScrollController scrollController = ScrollController();

        // Truyền setState vào loadMore
        Future<void> loadMore(void Function(void Function()) setState) async {
          if (scrollController.position.pixels ==
                  scrollController.position.maxScrollExtent &&
              !hasReachedMax) {
            final newData = await fetchSaleTeamLeaders(currentPage + 1);
            final filteredNewData = newData
                .where((newItem) => !allTeams
                    .any((oldItem) => oldItem.saleTeamId == newItem.saleTeamId))
                .toList();

            if (newData.isEmpty || filteredNewData.isEmpty) {
              hasReachedMax =
                  true; // Không có dữ liệu mới hoặc toàn bộ trùng lặp
              setState(() {}); // Cập nhật để dừng loading
            } else if (newData.length < 10) {
              hasReachedMax = true; // Ít hơn limit, đánh dấu hết dữ liệu
              allTeams.addAll(filteredNewData);
              setState(() {});
            } else {
              allTeams.addAll(filteredNewData);
              currentPage++;
              setState(() {});
            }
          }
        }

        return StatefulBuilder(
          builder: (context, setState) {
            // Gắn listener với setState
            scrollController.removeListener(() {}); // Xóa listener cũ nếu có
            scrollController.addListener(() async {
              loadMore(setState);
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              titlePadding: EdgeInsets.all(20.w),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.w),
              actionsPadding: EdgeInsets.all(10.w),
              title: Center(
                child: TextApp(
                  text: 'Chọn Team Sale',
                  fontsize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              content: SizedBox(
                width: 400.w,
                child: FutureBuilder<List<SaleTeamLeader>>(
                  future: fetchSaleTeamLeaders(1),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        allTeams.isEmpty) {
                      return SizedBox(
                        height: 100.h,
                        child: Center(
                          child: Lottie.asset(
                              'assets/lottie/loading_kango.json',
                              width: 100.w,
                              height: 100.w),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return SizedBox(
                        height: 100.h,
                        child: Center(
                          child: TextApp(
                            text: 'Lỗi: ${snapshot.error}',
                            fontsize: 16.sp,
                            color: Colors.red,
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SizedBox(
                        height: 100.h,
                        child: Center(
                          child: TextApp(
                            text: 'Không có dữ liệu',
                            fontsize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    if (allTeams.isEmpty) {
                      allTeams.addAll(snapshot.data!);
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDropdownOpen = !isDropdownOpen;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDropdownOpen
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextApp(
                                    text: selectedTeam != null
                                        ? "${selectedTeam?.userContactName} [${selectedTeam?.userCode}]"
                                        : "Chọn nhóm bạn muốn chuyển sang",
                                    fontsize: 16.sp,
                                    color: selectedTeam != null
                                        ? Colors.black87
                                        : Colors.grey.shade600,
                                    fontWeight: selectedTeam != null
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                                Icon(
                                  isDropdownOpen
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: isDropdownOpen
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade600,
                                  size: 24.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isDropdownOpen)
                          Container(
                            height: 250.h,
                            margin: EdgeInsets.only(top: 10.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Scrollbar(
                              controller: scrollController, // Đồng bộ Scrollbar
                              thumbVisibility: true,
                              child: ListView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                itemCount:
                                    allTeams.length + (hasReachedMax ? 0 : 1),
                                itemBuilder: (context, index) {
                                  if (index == allTeams.length &&
                                      !hasReachedMax) {
                                    return Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.h),
                                        child: SizedBox(
                                          width: 50.w,
                                          height: 50.h,
                                          child: Lottie.asset(
                                              'assets/lottie/loading_kango.json'),
                                        ),
                                      ),
                                    );
                                  }

                                  final team = allTeams[index];
                                  final bool isSelected =
                                      selectedTeam?.saleTeamId ==
                                          team.saleTeamId;

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedTeam = team;
                                        isDropdownOpen = false;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.1)
                                            : Colors.white,
                                        borderRadius: index == 0
                                            ? BorderRadius.vertical(
                                                top: Radius.circular(10.r))
                                            : index == allTeams.length - 1 &&
                                                    hasReachedMax
                                                ? BorderRadius.vertical(
                                                    bottom:
                                                        Radius.circular(10.r))
                                                : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextApp(
                                              text:
                                                  "${team.userContactName} [${team.userCode}]",
                                              fontsize: 15.sp,
                                              color: isSelected
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Colors.black87,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
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
                      ],
                    );
                  },
                ),
              ),
              actions: [
                ValueListenableBuilder<bool>(
                    valueListenable: _isLoadingNotifierTransferMember,
                    builder: (context, isLoading, child) {
                      return isLoading
                          ? Center(
                              child: SizedBox(
                                width: 40.w,
                                height: 40.w,
                                child: Lottie.asset(
                                    'assets/lottie/loading_kango.json'),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ButtonApp(
                                    event: () {
                                      Navigator.of(context).pop();
                                    },
                                    text: "Hủy",
                                    colorText: Colors.black87,
                                    backgroundColor: Colors.grey.shade200,
                                    outlineColor: Colors.grey.shade400,
                                    fontWeight: FontWeight.w500,
                                    fontsize: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                    child: ButtonApp(
                                  event: selectedTeam == null
                                      ? () {}
                                      : () async {
                                          showCustomDialogModal(
                                            context: context,
                                            textDesc:
                                                "Bạn có chắc chắn muốn chuyển thành viên sang nhóm khác không?",
                                            title: "Thông báo",
                                            colorButtonOk: Colors.blue,
                                            btnOKText: "Xác nhận",
                                            typeDialog: "question",
                                            isTwoButton: true,
                                            eventButtonOKPress: () async {
                                              // Gọi hàm chuyển thành viên để bật loading và thực hiện chuyển
                                              await _transferMemberToTeam(
                                                memberID: memberID,
                                                teamID:
                                                    selectedTeam?.saleTeamId ??
                                                        0,
                                              );
                                            },
                                          );
                                        },
                                  text: "Xác nhận",
                                  colorText: Colors.white,
                                  backgroundColor: selectedTeam == null
                                      ? Colors.grey.shade400
                                      : Theme.of(context).colorScheme.primary,
                                  outlineColor: selectedTeam == null
                                      ? Colors.grey.shade400
                                      : Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontsize: 14.sp,
                                )),
                              ],
                            );
                    }),
              ],
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        print("Selected team: ${value.userContactName} [${value.userCode}]");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: TextApp(
            text: "SALE LEADER MANAGER",
            fontWeight: FontWeight.bold,
            fontsize: 20.sp,
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<UpdateStatusMemeberBloc, SaleManagerState>(
              listener: (context, state) {
                if (state is UpdateStatusMemeberStateSuccess) {
                  _isLoadingNotifier.value = false;
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {
                      BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(
                        const GetSaleTeamLeader(
                          startDate: null,
                          endDate: null,
                          keywords: null,
                        ),
                      );
                    },
                    isTwoButton: false,
                  );
                } else if (state is UpdateStatusMemeberStateFailure) {
                  _isLoadingNotifier.value = false;
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
            BlocListener<TransferMemberToTeamBloc, SaleManagerState>(
              listener: (context, state) {
                if (state is TransferMemberToTeamStateSuccess) {
                  _isLoadingNotifierTransferMember.value = false;
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {
                      Navigator.pop(context);
                      BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(
                        const GetSaleTeamLeader(
                          startDate: null,
                          endDate: null,
                          keywords: null,
                        ),
                      );
                    },
                    isTwoButton: false,
                  );
                } else if (state is TransferMemberToTeamStateFailure) {
                  _isLoadingNotifierTransferMember.value = false;
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
            BlocListener<DeleteTeamBloc, SaleManagerState>(
              listener: (context, state) {
                if (state is DeleteTeamSaleStateSuccess) {
                  _isLoadingNotifier.value = false;
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {
                      BlocProvider.of<GetListSaleTeamLeaderBloc>(context).add(
                        const GetSaleTeamLeader(
                          startDate: null,
                          endDate: null,
                          keywords: null,
                        ),
                      );
                    },
                    isTwoButton: false,
                  );
                } else if (state is DeleteTeamSaleStateFailure) {
                  _isLoadingNotifier.value = false;
                  showCustomDialogModal(
                    context: context,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<GetListSaleTeamLeaderBloc, SaleManagerState>(
            builder: (context, state) {
              if (state is GetSaleTeamLeaderStateLoading) {
                return Center(
                  child: SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: Lottie.asset('assets/lottie/loading_kango.json'),
                  ),
                );
              } else if (state is GetSaleTeamLeaderStateSuccess) {
                listSaleTeamLeader = state.data;
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
                              _endDateError = null;
                              _dateStartController.clear();
                              _dateEndController.clear();
                              _startDate = null;
                              _endDate = null;
                              BlocProvider.of<GetListSaleTeamLeaderBloc>(
                                      context)
                                  .add(const GetSaleTeamLeader(
                                      startDate: null,
                                      endDate: null,
                                      keywords: null));
                            },
                            child: Column(children: [
                              Container(
                                  width: 1.sw,
                                  padding: EdgeInsets.all(10.w),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          onTapOutside: (event) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          // onChanged: searchProduct,
                                          controller: textSearchController,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                          cursorColor: Colors.black,
                                          onFieldSubmitted: (value) {
                                            searchProduct(
                                                textSearchController.text);
                                          },
                                          decoration: InputDecoration(
                                              suffixIcon: InkWell(
                                                onTap: () {
                                                  searchProduct(
                                                      textSearchController
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
                                                    BorderRadius.circular(8.r),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              isDense: true,
                                              hintText: "Tìm kiếm:...",
                                              contentPadding:
                                                  const EdgeInsets.all(15)),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15.w,
                                      ),
                                      FilterSaleTeamManagerWidget(
                                          monthYearController:
                                              _monthYearController,
                                          onDateRangeSelected:
                                              onDateRangeSelected,
                                          clearFilterFunction:
                                              clearFilterFuntion,
                                          applyFilterFunction:
                                              applyFilterFuntion),
                                    ],
                                  )),
                              SizedBox(
                                height: 8.h,
                              ),
                              Expanded(
                                  child: SingleChildScrollView(
                                controller: scrollListSaleLeaderController,
                                physics: const AlwaysScrollableScrollPhysics(),
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
                                                          const AddSaleLeaderScreen()));
                                            },
                                            text: "Thêm Sale leader",
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
                                      height: 15.w,
                                    ),
                                    SizedBox(
                                      width: 1.sw,
                                      child: state.data.isEmpty
                                          ? const NoDataFoundWidget()
                                          : ListView.builder(
                                              itemCount: state.hasReachedMax
                                                  ? state.data.length
                                                  : state.data.length + 1,
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
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
                                                  final dataTeamLeader =
                                                      state.data[index];

                                                  return _itemSaleTeamLeader(
                                                      dataTeamLeader);
                                                }
                                              }),
                                    )
                                  ],
                                ),
                              ))
                            ]))));
              } else if (state is GetSaleTeamLeaderStateFailure) {
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
                        text: state.message,
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
                      // Container(
                      //   width: 150.w,
                      //   height: 50.h,
                      //   child: ButtonApp(
                      //     event: () {},
                      //     text: "Xác nhận",
                      //     fontsize: 14.sp,
                      //     colorText: Colors.white,
                      //     backgroundColor: Colors.black,
                      //     outlineColor: Colors.black,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      width: 200.w,
                      height: 200.w,
                      child: Lottie.asset('assets/lottie/empty_box.json',
                          fit: BoxFit.contain),
                    ),
                  ),
                  TextApp(
                    text: "Không tìm thấy dữ liệu!",
                    fontsize: 18.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              );
            },
          ),
        ));
  }

  Widget _itemSaleTeamLeader(SaleTeamLeader dataTeamLeader) {
    final String? saleCode = StorageUtils.instance.getString(key: 'userCode');
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    final String normalizedPosition = position!.trim().toLowerCase();

    int? getLeaderUserId() {
      final leaderMember = dataTeamLeader.members?.firstWhere(
        (member) => member.memberKind == 1,
        orElse: () => Member(
          saleMemberId: 0,
          memberKind: 0,
          userContactName: '',
          userId: 0,
          userCode: '',
          memberProfit: 0,
        ), // Giá trị mặc định nếu không tìm thấy
      );
      return leaderMember?.memberKind == 1 ? leaderMember?.userId : null;
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with creator info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24.sp,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 180.w,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ManagerLeaderSale(
                                            // Pass user position as parameter
                                            userPosition: normalizedPosition,
                                            // Pass permissions as boolean flags
                                            canUploadLabel:
                                                normalizedPosition != 'sale' &&
                                                    normalizedPosition !=
                                                        'fwd' &&
                                                    normalizedPosition !=
                                                        'ops-leader' &&
                                                    normalizedPosition !=
                                                        'ops_pickup',
                                            canUploadPayment:
                                                normalizedPosition != 'fwd',
                                            saleCode: dataTeamLeader.userCode,
                                            userId: getLeaderUserId(),
                                          )));
                            },
                            child: TextApp(
                              text: dataTeamLeader.userContactName ?? "",
                              fontsize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddMembertoTeamSaleScreen(
                                            saleTeamId:
                                                dataTeamLeader.saleTeamId,
                                            saleTeamNameLeader:
                                                dataTeamLeader.userContactName,
                                          )));
                            },
                            icon: Icon(
                              Icons.person_add_alt_1,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24.sp,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.settings, size: 20),
                            constraints: BoxConstraints(
                              minWidth: 200.w,
                              maxWidth: 250.w,
                            ),
                            padding: EdgeInsets.zero,
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            position: PopupMenuPosition.under,
                            offset: const Offset(0, 10),
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                height: 40.h,
                                value: 'details',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(FontAwesomeIcons.userCog,
                                        size: 20.sp, color: Colors.black),
                                    SizedBox(width: 10.w),
                                    Flexible(
                                      child: TextApp(
                                        text: 'Thông tin chi tiết',
                                        fontsize: 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                height: 40.h,
                                value: 'delete',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(FontAwesomeIcons.trash,
                                        size: 18.sp, color: Colors.red),
                                    SizedBox(width: 10.w),
                                    Flexible(
                                      child: TextApp(
                                        text: 'Xóa',
                                        color: Colors.red,
                                        fontsize: 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (String value) async {
                              // final renderBox =
                              //     context.findRenderObject() as RenderBox;
                              // final offset =
                              //     renderBox.localToGlobal(Offset.zero);
                              // final screenHeight =
                              //     MediaQuery.of(context).size.height;
                              // const menuHeight = 100.0;

                              // if (offset.dy +
                              //         renderBox.size.height +
                              //         menuHeight >
                              //     screenHeight) {
                              //   await Scrollable.of(context)
                              //       .position
                              //       .ensureVisible(
                              //         renderBox,
                              //         alignment: 0.5,
                              //         duration:
                              //             const Duration(milliseconds: 300),
                              //       );
                              // }

                              switch (value) {
                                case 'details':
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ManagerLeaderSale(
                                                  // Pass user position as parameter
                                                  userPosition:
                                                      normalizedPosition,
                                                  // Pass permissions as boolean flags
                                                  canUploadLabel:
                                                      normalizedPosition !=
                                                              'sale' &&
                                                          normalizedPosition !=
                                                              'fwd' &&
                                                          normalizedPosition !=
                                                              'ops-leader' &&
                                                          normalizedPosition !=
                                                              'ops_pickup',
                                                  canUploadPayment:
                                                      normalizedPosition !=
                                                          'fwd',
                                                  saleCode:
                                                      dataTeamLeader.userCode,
                                                  userId: getLeaderUserId())));

                                  break;
                                case 'delete':
                                  showCustomDialogModal(
                                      context: context,
                                      textDesc:
                                          "Bạn có chắc chắn muốn xóa team này không ?",
                                      title: "Thông báo",
                                      colorButtonOk: Colors.blue,
                                      btnOKText: "Xác nhận",
                                      typeDialog: "question",
                                      eventButtonOKPress: () async {
                                        await _deleteTeamSale(
                                            teamID: dataTeamLeader.saleTeamId);
                                      },
                                      isTwoButton: true);
                                  break;
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Date info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    TextApp(
                      text: "Ngày tạo: ",
                      fontsize: 14.sp,
                      color: Colors.black54,
                    ),
                    TextApp(
                      text: _formatDate(dataTeamLeader.createdAt),
                      fontsize: 14.sp,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Table header
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: const Border(
                    bottom: BorderSide(color: Colors.black12),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      flex: 3,
                      child: TextApp(
                        text: "Tên",
                        fontWeight: FontWeight.w500,
                        fontsize: 14.sp,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextApp(
                        text: "Mã",
                        fontWeight: FontWeight.w500,
                        fontsize: 14.sp,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextApp(
                        text: "Lợi nhuận",
                        fontWeight: FontWeight.w500,
                        fontsize: 14.sp,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    // Add placeholder width for the three icons
                    const SizedBox(width: 20 * 3),
                  ],
                ),
              ),
              // Team members list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataTeamLeader.members?.length ?? 0,
                itemBuilder: (context, index) {
                  final member = dataTeamLeader.members![index];
                  final isEven = index % 2 == 1;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.white : Colors.grey[50],
                      border: const Border(
                        bottom: BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ManagerLeaderSale(
                                            // Pass user position as parameter
                                            userPosition: normalizedPosition,
                                            // Pass permissions as boolean flags
                                            canUploadLabel:
                                                normalizedPosition != 'sale' &&
                                                    normalizedPosition !=
                                                        'fwd' &&
                                                    normalizedPosition !=
                                                        'ops-leader' &&
                                                    normalizedPosition !=
                                                        'ops_pickup',
                                            canUploadPayment:
                                                normalizedPosition != 'fwd',
                                            saleCode: member.userCode,
                                            userId: member.userId,
                                          )));
                            },
                            child: Row(
                              children: [
                                member.memberKind == 1
                                    ? Icon(
                                        FontAwesomeIcons.userTie,
                                        size: 16.sp,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : Container(),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: TextApp(
                                    text: member.userContactName ?? "",
                                    fontsize: 13.sp,
                                    maxLines: 3,
                                    fontWeight: member.memberKind == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          flex: 2,
                          child: TextApp(
                            text: member.userCode ?? "",
                            fontsize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: TextApp(
                            text:
                                "${formatter.format(member.memberProfit ?? 0)} VND",
                            fontsize: 13.sp,
                            maxLines: 3,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        member.memberKind != 1
                            ? SizedBox(
                                width: 40.w,
                              )
                            : SizedBox(
                                width: 80.w,
                              ),
                        // Add the three icons here
                        member.memberKind != 1
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          235, 245, 245, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        FontAwesomeIcons.userTie,
                                        size: 12,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: _isLoadingNotifier.value
                                          ? null
                                          : () async {
                                              showCustomDialogModal(
                                                  context: context,
                                                  textDesc:
                                                      "Bạn có chắc muốn chuyển thành viên này thành leader không?",
                                                  title: "Thông báo",
                                                  colorButtonOk: Colors.blue,
                                                  btnOKText: "Xác nhận",
                                                  typeDialog: "question",
                                                  eventButtonOKPress: () async {
                                                    await _updateStatusMember(
                                                        memberID:
                                                            member.saleMemberId,
                                                        teamID: dataTeamLeader
                                                            .saleTeamId,
                                                        kind: 1);
                                                    _isLoadingNotifier.value =
                                                        false; // Tắt trạng thái loading
                                                  },
                                                  isTwoButton: true);
                                            },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          237, 252, 254, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        FontAwesomeIcons.reply,
                                        size: 12,
                                        color: Color.fromRGBO(24, 221, 239, 1),
                                      ),
                                      onPressed: () async {
                                        await showSaleTeamSelectionDialog(
                                            context, member.saleMemberId);
                                        // Handle delete action
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  Container(
                                    width: 40.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          255, 235, 235, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        FontAwesomeIcons.signOutAlt,
                                        size: 12,
                                        color: Color.fromRGBO(255, 0, 0, 1),
                                      ),
                                      onPressed: _isLoadingNotifier.value
                                          ? null // Disable button while loading
                                          : () async {
                                              showCustomDialogModal(
                                                  context: context,
                                                  textDesc:
                                                      "Bạn có chắc muốn xóa thành viên này ra khỏi team không không ?",
                                                  title: "Thông báo",
                                                  colorButtonOk: Colors.blue,
                                                  btnOKText: "Xác nhận",
                                                  typeDialog: "question",
                                                  eventButtonOKPress: () async {
                                                    await _updateStatusMember(
                                                        memberID:
                                                            member.saleMemberId,
                                                        teamID: dataTeamLeader
                                                            .saleTeamId,
                                                        kind: 0);
                                                  },
                                                  isTwoButton: true);
                                            },
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                height: 130.h,
                              )
                      ],
                    ),
                  );
                },
              ),
              SizedBox(
                height: 15.h,
              )
            ],
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

// Helper function to format date
  String _formatDate(String? dateString) {
    if (dateString == null) return "";
    try {
      final dateTime = DateTime.parse(dateString);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}
