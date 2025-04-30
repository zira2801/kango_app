import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/data/models/sale_leader/user_sale_leader.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class AddSaleLeaderScreen extends StatefulWidget {
  final int? leaderId;
  const AddSaleLeaderScreen({super.key, this.leaderId});

  @override
  State<AddSaleLeaderScreen> createState() => _AddSaleLeaderScreenState();
}

class _AddSaleLeaderScreenState extends State<AddSaleLeaderScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<UserSaleLeader> _selectedUsers = [];
  Timer? _debounce;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadInitialData() {
    context.read<GetUsersSaleLeaderBloc>().add(
          const GetUsersSaleLeader(
            positionName: 'sale',
            userNotIn: [],
            keywords: null,
          ),
        );
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<GetUsersSaleLeaderBloc>().add(
            GetUsersSaleLeader(
              positionName: 'sale',
              userNotIn: _selectedUsers
                  .map((u) => u.userId)
                  .where((id) => id != null)
                  .cast<int>()
                  .toList(),
              keywords: query.isEmpty ? null : query,
            ),
          );
    });
  }

  void _addUser(UserSaleLeader user) {
    setState(() {
      _selectedUsers.add(user);
    });

    context.read<GetUsersSaleLeaderBloc>().add(
          GetUsersSaleLeader(
            positionName: 'sale',
            userNotIn: _selectedUsers
                .map((u) => u.userId)
                .where((id) => id != null)
                .cast<int>()
                .toList(),
            keywords:
                _searchController.text.isEmpty ? null : _searchController.text,
          ),
        );
  }

  void _removeUser(UserSaleLeader user) {
    setState(() {
      _selectedUsers.removeWhere((item) => item.userId == user.userId);
    });

    context.read<GetUsersSaleLeaderBloc>().add(
          GetUsersSaleLeader(
            positionName: 'sale',
            userNotIn: _selectedUsers
                .map((u) => u.userId)
                .where((id) => id != null)
                .cast<int>()
                .toList(),
            keywords:
                _searchController.text.isEmpty ? null : _searchController.text,
          ),
        );
  }

  Future<void> _addMemberToTeam() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.leaderId == null) {
      context.read<AddLeaderBloc>().add(
            AddLeader(
              userIds: _selectedUsers.map((u) => u.userId!).toList(),
            ),
          );
    } else {
      context.read<AddMemberToTeamBloc>().add(
            AddMemberToTeam(
              leaderId: widget.leaderId ?? 0,
              userIds: _selectedUsers.map((u) => u.userId!).toList(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextApp(
          text: 'Thêm sale leader',
          fontsize: 20.w,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 150.w,
              height: 40.w,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary)),
                onPressed: _isLoading
                    ? null // Disable button while loading
                    : () async {
                        showCustomDialogModal(
                            context: context,
                            textDesc: widget.leaderId != null
                                ? "Bạn có chắc muốn thêm member vào team ?"
                                : "Bạn có chắc muốn tạo Sale Leader ?",
                            title: "Thông báo",
                            colorButtonOk: Colors.blue,
                            btnOKText: "Xác nhận",
                            typeDialog: "question",
                            eventButtonOKPress: () async {
                              await _addMemberToTeam();
                            },
                            isTwoButton: true);
                      },
                child: _isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                          strokeWidth: 2.w,
                        ),
                      )
                    : TextApp(
                        text: 'Xác nhận',
                        color: Colors.white,
                        fontsize: 15.w,
                        fontWeight: FontWeight.w600,
                      ),
              ),
            ),
          )
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AddMemberToTeamBloc, SaleManagerState>(
            listener: (context, state) {
              if (state is AddMemberToTeamStateSuccess) {
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
                        _selectedUsers.clear();
                      });
                      BlocProvider.of<GetUsersSaleLeaderBloc>(context)
                          .add(const GetUsersSaleLeader(
                        positionName: 'sale',
                        userNotIn: [],
                        keywords: null,
                      ));
                    },
                    isTwoButton: false);
              } else if (state is AddMemberToTeamStateFailure) {
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
          ),
          BlocListener<AddLeaderBloc, SaleManagerState>(
            listener: (context, state) {
              if (state is AddLeaderStateSuccess) {
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
                        _selectedUsers.clear();
                      });
                      BlocProvider.of<GetUsersSaleLeaderBloc>(context)
                          .add(const GetUsersSaleLeader(
                        positionName: 'sale',
                        userNotIn: [],
                        keywords: null,
                      ));
                    },
                    isTwoButton: false);
              } else if (state is AddLeaderStateFailure) {
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
          ),
        ],
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Selected users section
              // Selected users section
              if (_selectedUsers.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextApp(
                        text: 'Các sale đã được chọn',
                        fontWeight: FontWeight.bold,
                        fontsize: 16.sp,
                      ),
                      TextApp(
                        text: '${_selectedUsers.length} người được chọn',
                        color: Colors.grey.shade600,
                        fontsize: 14.sp,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250.h,
                  child: ListView.builder(
                    itemCount: _selectedUsers.length,
                    itemBuilder: (context, index) {
                      final user = _selectedUsers[index];
                      final bool isEvenRow = index % 2 == 0;

                      return Container(
                        color: isEvenRow ? Colors.white : Colors.grey[100],
                        child: ListTile(
                          title: TextApp(
                            text: user.userContactName.toString(),
                            fontWeight: FontWeight.bold,
                            fontsize: 15.sp,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextApp(
                                text: 'Mã: ${user.userCode}',
                                fontsize: 14.sp,
                              ),
                              TextApp(
                                text: 'Email: ${user.userName}',
                                fontsize: 14.sp,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () => _removeUser(user),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(thickness: 1),
              ],

              // Search bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextApp(
                      text: 'Danh sách các sale',
                      fontWeight: FontWeight.bold,
                      fontsize: 16.sp,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(fontSize: 14.sp, fontFamily: 'OpenSans'),
                      decoration: InputDecoration(
                        hintText: 'Nhấn \'enter\' để tìm kiếm',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'OpenSans',
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Available users list
              Expanded(
                flex: _selectedUsers.isEmpty ? 1 : 3,
                child: BlocBuilder<GetUsersSaleLeaderBloc, SaleManagerState>(
                  builder: (context, state) {
                    if (state is GetUsersSaleLeaderStateLoading) {
                      return Center(
                        child: SizedBox(
                          width: 100.w,
                          height: 100.w,
                          child:
                              Lottie.asset('assets/lottie/loading_kango.json'),
                        ),
                      );
                    }

                    if (state is GetUsersSaleLeaderStateFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadInitialData,
                              child: TextApp(
                                text: 'Thử lại',
                                fontsize: 15.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is GetUsersSaleLeaderStateSuccess) {
                      if (state.data.isEmpty) {
                        return const Center(
                          child: Text('Không tìm thấy người dùng'),
                        );
                      }

                      return NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (!state.hasReachedMax &&
                              scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent) {
                            context.read<GetUsersSaleLeaderBloc>().add(
                                  LoadMoreUsersSaleLeader(
                                    positionName: 'sale',
                                    userNotIn: _selectedUsers
                                        .map((user) => user.userId)
                                        .where((id) => id != null)
                                        .cast<int>()
                                        .toList(),
                                    keywords: _searchController.text.isEmpty
                                        ? null
                                        : _searchController.text,
                                  ),
                                );
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount:
                              state.data.length + (state.hasReachedMax ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index >= state.data.length) {
                              return Center(
                                child: SizedBox(
                                  width: 100.w,
                                  height: 100.w,
                                  child: Lottie.asset(
                                      'assets/lottie/loading_kango.json'),
                                ),
                              );
                            }
                            final user = state.data[index];
                            final bool isAlreadySelected = _selectedUsers.any(
                                (selectedUser) =>
                                    selectedUser.userId == user.userId);
                            final bool isEvenRow = index % 2 == 0;
                            return Container(
                              color:
                                  isEvenRow ? Colors.white : Colors.grey[100],
                              child: ListTile(
                                title: TextApp(
                                  text: user.userContactName.toString(),
                                  fontWeight: FontWeight.bold,
                                  fontsize: 15.sp,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextApp(
                                      text: 'Mã: ${user.userCode}',
                                      fontsize: 14.sp,
                                    ),
                                    TextApp(
                                      text: 'Email: ${user.userName}',
                                      fontsize: 14.sp,
                                    ),
                                  ],
                                ),
                                // trailing: IconButton(
                                //   icon: Icon(
                                //     isAlreadySelected
                                //         ? Icons.check_circle
                                //         : Icons.add_circle_outline,
                                //     color: isAlreadySelected
                                //         ? Colors.green
                                //         : Colors.blue,
                                //   ),
                                //   onPressed: isAlreadySelected
                                //       ? null
                                //       : () => _addUser(user),
                                // ),
                                trailing: GestureDetector(
                                  onTap: () => _addUser(user),
                                  child: Container(
                                    height: 50.h,
                                    width: 50.w,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          235, 245, 245, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        Icons
                                            .add, // Convert icon string to IconData
                                        size:
                                            18, // Matches the previous width/height
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary, // Customize color if needed
                                      ),
                                    ),
                                  ),
                                ),
                                enabled: !isAlreadySelected,
                              ),
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
