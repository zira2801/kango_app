import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/data/models/sale_leader/fwd_no_link.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class LinkSaleToFwdScreen extends StatefulWidget {
  const LinkSaleToFwdScreen({super.key});

  @override
  State<LinkSaleToFwdScreen> createState() => _LinkSaleToFwdScreenState();
}

class _LinkSaleToFwdScreenState extends State<LinkSaleToFwdScreen> {
  List<UserFwdNoLink> selectedFwdItems = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<UserFwdNoLink> _filteredFwdItems = [];
  List<UserFwdNoLink> _allFwdItems = [];
  bool _isSearchFocused = false;
  Timer? _debounce;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    context.read<GetListFwdNoLinkBloc>().add(const GetListFWDNoLink(
        startDate: null, endDate: null, companyID: null));
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchTextChanged);
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<GetListFwdNoLinkBloc>().add(const LoadMoreListFWDNoLink(
          startDate: null, endDate: null, companyID: null));
    }
  }

  void _onFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  void _onSearchTextChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterFwdItems();
    });
  }

  void _filterFwdItems() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFwdItems = List.from(_allFwdItems);
      } else {
        final keywords = query.split(RegExp(r'\s+'));
        _filteredFwdItems = _allFwdItems.where((item) {
          final userCode = item.userCode?.toLowerCase() ?? '';
          final companyName = item.userCompanyName?.toLowerCase() ?? '';
          final combinedText = '$userCode $companyName';
          return keywords.every((keyword) => combinedText.contains(keyword));
        }).toList();
      }
    });
  }

  void _toggleFwdItemSelection(UserFwdNoLink item) {
    setState(() {
      if (selectedFwdItems.contains(item)) {
        selectedFwdItems.remove(item);
      } else {
        selectedFwdItems.add(item);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    selectedFwdItems.clear();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _onHandleLinkFwdToSale() async {
    if (selectedFwdItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Vui lòng chọn ít nhất một FWD để liên kết',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 6,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    final int? saleID = StorageUtils.instance.getInt(key: 'user_ID');

    // Lấy danh sách ID của các FWD được chọn
    List<int>? fwdIds =
        selectedFwdItems.map((item) => item.userId!.toInt()).toList();

    // Gọi sự kiện liên kết
    context
        .read<LinkFwdToSaleBloc>()
        .add(LinkFWDToSale(fwdIds: fwdIds, saleId: saleID!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LinkFwdToSaleBloc, SaleManagerState>(
      listener: (context, state) {
        if (state is LinkFWDToSaleStateSuccess) {
          setState(() {
            _isLoading = false;
          });
          showCustomDialogModal(
              context: context,
              textDesc: state.message,
              title: "Thông báo",
              colorButtonOk: Colors.green,
              btnOKText: "Xác nhận",
              typeDialog: "success",
              eventButtonOKPress: () {
                setState(() {
                  selectedFwdItems.clear();
                });
                context.read<GetListFwdNoLinkBloc>().add(const GetListFWDNoLink(
                    startDate: null, endDate: null, companyID: null));
              },
              isTwoButton: false);
        } else if (state is LinkFWDToSaleStateFailure) {
          setState(() {
            _isLoading = false;
          });
          showCustomDialogModal(
              context: context,
              textDesc: state.message,
              title: "Thông báo",
              colorButtonOk: Colors.red,
              btnOKText: "Xác nhận",
              typeDialog: "error",
              eventButtonOKPress: () {},
              isTwoButton: false);
        }
      },
      builder: (BuildContext context, state) {
        // Sử dụng state để xác định trạng thái loading
        bool isLoading = state is LinkFWDToSaleStateLoading;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: TextApp(
              text: "Link Sale to FWD",
              fontWeight: FontWeight.bold,
              fontsize: 20.sp,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: SizedBox(
                  height: 40.w,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            Theme.of(context).colorScheme.primary)),
                    onPressed: isLoading
                        ? null // Disable button while loading
                        : () async {
                            showCustomDialogModal(
                                context: context,
                                textDesc:
                                    "Bạn có chắc muốn liên kết FWD với Sale ?",
                                title: "Thông báo",
                                colorButtonOk: Colors.blue,
                                btnOKText: "Xác nhận",
                                typeDialog: "question",
                                eventButtonOKPress: () async {
                                  await _onHandleLinkFwdToSale();
                                },
                                isTwoButton: true);
                          },
                    child: isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                              strokeWidth: 2.w,
                            ),
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.add_circle,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 3.w,
                              ),
                              TextApp(
                                text: 'Liên kết',
                                color: Colors.white,
                                fontsize: 15.w,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                  ),
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ô hiển thị danh sách đã chọn (giới hạn chiều cao và cho phép cuộn)
                    selectedFwdItems.isNotEmpty
                        ? Container(
                            height: 300
                                .h, // Giới hạn chiều cao của danh sách đã chọn
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedFwdItems.map((item) {
                                    return Chip(
                                      label: TextApp(
                                        text:
                                            '[${item.userCode}] ${item.userCompanyName}',
                                        fontsize: 14.sp,
                                      ),
                                      backgroundColor: Colors.grey.shade200,
                                      deleteIcon:
                                          const Icon(Icons.close, size: 16),
                                      onDeleted: () =>
                                          _toggleFwdItemSelection(item),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          )
                        : Container(),

                    // Tiêu đề "Lựa chọn Fwd liên kết"
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextApp(
                          text: 'Lựa chọn Fwd liên kết',
                          fontsize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Ô tìm kiếm
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm FWD...',
                          hintStyle: TextStyle(
                              fontFamily: 'OpenSans', fontSize: 15.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          _searchFocusNode.unfocus();
                        },
                      ),
                    ),

                    // Danh sách FWD (chỉ hiển thị khi ô tìm kiếm đang focus)
                    if (_isSearchFocused)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, bottom: 15.0),
                        child: SizedBox(
                          height: 300.h, // Giới hạn chiều cao của danh sách FWD
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: BlocBuilder<GetListFwdNoLinkBloc,
                                SaleManagerState>(
                              builder: (context, state) {
                                if (state is GetListFWDNoLinkStateLoading) {
                                  return Center(
                                    child: SizedBox(
                                      width: 100.w,
                                      height: 100.w,
                                      child: Lottie.asset(
                                          'assets/lottie/loading_kango.json'),
                                    ),
                                  );
                                }

                                if (state is GetListFWDNoLinkStateFailure) {
                                  return AlertDialog(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.w),
                                    ),
                                    actionsPadding: EdgeInsets.zero,
                                    contentPadding: EdgeInsets.only(
                                        top: 35.w,
                                        bottom: 30.w,
                                        left: 35.w,
                                        right: 35.w),
                                    titlePadding: EdgeInsets.all(15.w),
                                    surfaceTintColor: Colors.white,
                                    backgroundColor: Colors.white,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                            child: Lottie.asset(
                                                'assets/lottie/error_dialog.json',
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
                                      ],
                                    ),
                                  );
                                }

                                if (state is GetListFWDNoLinkStateSuccess) {
                                  _allFwdItems = state.data;
                                  if (_filteredFwdItems.isEmpty &&
                                      _searchController.text.isEmpty) {
                                    _filteredFwdItems = List.from(_allFwdItems);
                                  }

                                  return ListView.separated(
                                    controller: _scrollController,
                                    itemCount: _filteredFwdItems.length +
                                        (state.hasReachedMax ? 0 : 1),
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                      color: Colors.grey.shade300,
                                      height: 1,
                                      thickness: 1,
                                      indent: 16,
                                      endIndent: 16,
                                    ),
                                    itemBuilder: (context, index) {
                                      if (index >= _filteredFwdItems.length) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      final item = _filteredFwdItems[index];
                                      final isSelected =
                                          selectedFwdItems.contains(item);

                                      return Container(
                                        color: isSelected
                                            ? Colors.grey.shade400
                                            : null,
                                        child: ListTile(
                                          title: Text(
                                            '[${item.userCode}] ${item.userCompanyName}',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          onTap: () =>
                                              _toggleFwdItemSelection(item),
                                        ),
                                      );
                                    },
                                  );
                                }

                                return Center(
                                    child: TextApp(
                                  text: 'Dữ liệu không có sẵn',
                                  fontsize: 16.sp,
                                ));
                              },
                            ),
                          ),
                        ),
                      ),
                    // Thêm khoảng trống để tránh che khuất nội dung khi bàn phím mở
                    SizedBox(height: 100.h),
                  ],
                ),
              ),

              // Nút "Đóng" và "Liên Kết" cố định ở dưới cùng
              // Positioned(
              //   left: 0,
              //   right: 0,
              //   bottom: 0,
              //   child: Container(
              //     color: Colors.white,
              //     padding: const EdgeInsets.all(16.0),
              //     child: Row(
              //       children: [
              //         Expanded(
              //           child: GestureDetector(
              //             onTap: () {
              //               Navigator.of(context).pop();
              //             },
              //             child: Container(
              //               width: 150.w,
              //               height: 60.h,
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(15.0),
              //                 color: Colors.grey,
              //               ),
              //               child: Center(
              //                 child: TextApp(
              //                   text: 'Đóng',
              //                   color: Colors.white,
              //                   fontsize: 16.sp,
              //                   fontWeight: FontWeight.w600,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //         const SizedBox(width: 16),
              //         Expanded(
              //           child: GestureDetector(
              //             onTap: selectedFwdItems.isNotEmpty
              //                 ? () {
              //                     ScaffoldMessenger.of(context).showSnackBar(
              //                       SnackBar(
              //                         content: Text(
              //                             'Linking ${selectedFwdItems.length} items'),
              //                       ),
              //                     );
              //                   }
              //                 : null,
              //             child: Container(
              //               width: 150.w,
              //               height: 60.h,
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(15.0),
              //                 color: selectedFwdItems.isNotEmpty
              //                     ? Theme.of(context).colorScheme.primary
              //                     : Colors.grey.shade400,
              //               ),
              //               child: Center(
              //                 child: TextApp(
              //                   text: 'Liên Kết',
              //                   color: Colors.white,
              //                   fontsize: 16.sp,
              //                   fontWeight: FontWeight.w600,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
