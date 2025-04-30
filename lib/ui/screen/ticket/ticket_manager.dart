import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/ticket/list_ticket/list_ticket_bloc.dart';
import 'package:scan_barcode_app/ui/screen/ticket/chat_ticket.dart';
import 'package:scan_barcode_app/ui/screen/ticket/create_ticket.dart';
import 'package:scan_barcode_app/ui/utils/date_time_format.dart';
import 'package:scan_barcode_app/ui/widgets/dialog/custom_dialog.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class TicketManagerScreen extends StatefulWidget {
  const TicketManagerScreen({super.key});

  @override
  State<TicketManagerScreen> createState() => _TicketManagerScreenState();
}

class _TicketManagerScreenState extends State<TicketManagerScreen>
    with SingleTickerProviderStateMixin {
  final scrollListPendingController = ScrollController();
  final scrollListProcessingController = ScrollController();
  final scrollListDoneController = ScrollController();
  late TabController controllerTab;
  int _selectedIndex = 0;

  List<Widget> listTab = [
    Tab(
      child: TextApp(
        text: 'Đang xử lý',
        fontsize: 16.sp,
        color: Colors.black,
      ),
    ),
    Tab(
      child: TextApp(
        text: 'Chưa xử lý',
        fontsize: 16.sp,
        color: Colors.black,
      ),
    ),
    Tab(
      child: TextApp(
        text: 'Đã xong',
        fontsize: 16.sp,
        color: Colors.black,
      ),
    ),
  ];
  void _onScrollPending() {
    if (scrollListPendingController.position.maxScrollExtent ==
        scrollListPendingController.offset) {
      BlocProvider.of<ListTicketBloc>(context)
          .add(LoadMoreListTicketStatusPending());
    }
  }

  void _onScrollProcessing() {
    if (scrollListProcessingController.position.maxScrollExtent ==
        scrollListProcessingController.offset) {
      BlocProvider.of<ListTicketBloc>(context)
          .add(LoadMoreListTicketStatusProcessing());
    }
  }

  void _onScrollDone() {
    if (scrollListDoneController.position.maxScrollExtent ==
        scrollListDoneController.offset) {
      BlocProvider.of<ListTicketBloc>(context)
          .add(LoadMoreListTicketStatusDone());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllerTab = TabController(length: listTab.length, vsync: this);

    controllerTab.addListener(() {
      // setState(() {
      //   _selectedIndex = controllerTab.index;
      // });
      _selectedIndex = controllerTab.index;
      if (_selectedIndex == 0) {
        BlocProvider.of<ListTicketBloc>(context)
            .add(FetchListTicketStatusProcessing());
      } else if (_selectedIndex == 1) {
        BlocProvider.of<ListTicketBloc>(context)
            .add(FetchListTicketStatusPending());
      } else {
        BlocProvider.of<ListTicketBloc>(context)
            .add(FetchListTicketStatusDone());
      }
    });
    // BlocProvider.of<ListTicketBloc>(context)
    //     .add(FetchListTicketStatusPending());
    BlocProvider.of<ListTicketBloc>(context)
        .add(FetchListTicketStatusProcessing());
    // BlocProvider.of<ListTicketBloc>(context).add(FetchListTicketStatusDone());
    scrollListPendingController.addListener(_onScrollPending);
    scrollListProcessingController.addListener(_onScrollProcessing);
    scrollListDoneController.addListener(_onScrollDone);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollListPendingController.dispose();
    scrollListProcessingController.dispose();
    scrollListDoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
              text: "Danh Sách Ticket",
              fontsize: 20.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            bottom: TabBar(
              controller: controllerTab,
              // onTap: (int index) {
              //   if (index == 0) {
              //     BlocProvider.of<ListTicketBloc>(context)
              //         .add(FetchListTicketStatusProcessing());
              //   } else if (index == 1) {
              //     BlocProvider.of<ListTicketBloc>(context)
              //         .add(FetchListTicketStatusPending());
              //   } else {
              //     BlocProvider.of<ListTicketBloc>(context)
              //         .add(FetchListTicketStatusDone());
              //   }
              // },
              tabs: listTab,
            ),
          ),
          body: Stack(
            children: [
              TabBarView(
                controller: controllerTab,
                children: [
                  MultiBlocListener(
                      listeners: [
                        BlocListener<ListTicketBloc, ListTicketState>(
                          listener: (context, state) {
                            if (state
                                is ListTicketStatusProcessingStateSuccess) {}
                          },
                        )
                      ],
                      child: BlocBuilder<ListTicketBloc, ListTicketState>(
                        builder: (context, state) {
                          if (state is ListTicketStatusProcessingStateLoading) {
                            return Center(
                              child: SizedBox(
                                width: 100.w,
                                height: 100.w,
                                child: Lottie.asset(
                                    'assets/lottie/loading_kango.json'),
                              ),
                            );
                          } else if (state
                              is ListTicketStatusProcessingStateSuccess) {
                            return SingleChildScrollView(
                                controller: scrollListProcessingController,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    state.data.isEmpty
                                        ? const Center(
                                            child: NoDataFoundWidget(),
                                          )
                                        : SizedBox(
                                            width: 1.sw,
                                            child: ListView.builder(
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
                                                    final dataTicket =
                                                        state.data[index];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.all(10.w),
                                                      child: Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                isScrollControlled:
                                                                    true,
                                                                builder:
                                                                    (context) =>
                                                                        ChatTicketBottomSheet(
                                                                  ticketID:
                                                                      dataTicket
                                                                          .ticketId,
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              // width: 1.sw,
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5.w,
                                                                      right:
                                                                          5.w),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.r),
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        4,
                                                                    offset: const Offset(
                                                                        0,
                                                                        3), // changes position of shadow
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(10
                                                                            .w),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .airplane_ticket,
                                                                      size:
                                                                          36.sp,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          10.w,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        TextApp(
                                                                          text:
                                                                              dataTicket.ticketTitle,
                                                                          fontsize:
                                                                              14.sp,
                                                                        ),
                                                                        TextApp(
                                                                            text:
                                                                                formatDateTime(
                                                                              dataTicket.createdAt.toString(),
                                                                            ),
                                                                            fontsize:
                                                                                14.sp),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                }),
                                          )
                                  ],
                                ));
                          } else if (state
                              is ListTicketStatusProcessingStateFailure) {
                            return ErrorDialog(
                              eventConfirm: () {
                                Navigator.pop(context);
                              },
                              errorText:
                                  'Failed to fetch orders: ${state.message}',
                            );
                          }
                          return Container();
                        },
                      )),
                  MultiBlocListener(
                      listeners: [
                        BlocListener<ListTicketBloc, ListTicketState>(
                          listener: (context, state) {
                            if (state is ListTicketStatusPendingStateSuccess) {}
                          },
                        )
                      ],
                      child: BlocBuilder<ListTicketBloc, ListTicketState>(
                        builder: (context, state) {
                          log("STATE PENDING");
                          if (state is ListTicketStatusPendingStateLoading) {
                            return Center(
                              child: SizedBox(
                                width: 100.w,
                                height: 100.w,
                                child: Lottie.asset(
                                    'assets/lottie/loading_kango.json'),
                              ),
                            );
                          } else if (state
                              is ListTicketStatusPendingStateSuccess) {
                            return SingleChildScrollView(
                                controller: scrollListPendingController,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    state.data.isEmpty
                                        ? const Center(
                                            child: NoDataFoundWidget())
                                        : SizedBox(
                                            width: 1.sw,
                                            child: ListView.builder(
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
                                                    final dataTicket =
                                                        state.data[index];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.all(10.w),
                                                      child: Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                isScrollControlled:
                                                                    true,
                                                                builder:
                                                                    (context) =>
                                                                        ChatTicketBottomSheet(
                                                                  ticketID:
                                                                      dataTicket
                                                                          .ticketId,
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              // width: 1.sw,
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5.w,
                                                                      right:
                                                                          5.w),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.r),
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        4,
                                                                    offset: const Offset(
                                                                        0,
                                                                        3), // changes position of shadow
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(10
                                                                            .w),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .airplane_ticket,
                                                                      size:
                                                                          36.sp,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          10.w,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        TextApp(
                                                                          text:
                                                                              dataTicket.ticketTitle,
                                                                          fontsize:
                                                                              14.sp,
                                                                        ),
                                                                        TextApp(
                                                                            text:
                                                                                formatDateTime(
                                                                              dataTicket.createdAt.toString(),
                                                                            ),
                                                                            fontsize:
                                                                                14.sp),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                }),
                                          )
                                  ],
                                ));
                          } else if (state
                              is ListTicketStatusPendingStateFailure) {
                            return ErrorDialog(
                              eventConfirm: () {
                                Navigator.pop(context);
                              },
                              errorText:
                                  'Failed to fetch orders: ${state.message}',
                            );
                          }
                          return Container();
                        },
                      )),
                  MultiBlocListener(
                      listeners: [
                        BlocListener<ListTicketBloc, ListTicketState>(
                          listener: (context, state) {
                            if (state is ListTicketStatusDoneStateSuccess) {}
                          },
                        )
                      ],
                      child: BlocBuilder<ListTicketBloc, ListTicketState>(
                        builder: (context, state) {
                          log("STATE DONE");
                          if (state is ListTicketStatusDoneStateLoading) {
                            return Center(
                              child: SizedBox(
                                width: 100.w,
                                height: 100.w,
                                child: Lottie.asset(
                                    'assets/lottie/loading_kango.json'),
                              ),
                            );
                          } else if (state
                              is ListTicketStatusDoneStateSuccess) {
                            return SingleChildScrollView(
                                controller: scrollListDoneController,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    state.data.isEmpty
                                        ? const Center(
                                            child: NoDataFoundWidget())
                                        : SizedBox(
                                            width: 1.sw,
                                            child: ListView.builder(
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
                                                    final dataTicket =
                                                        state.data[index];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.all(10.w),
                                                      child: Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                isScrollControlled:
                                                                    true,
                                                                builder:
                                                                    (context) =>
                                                                        ChatTicketBottomSheet(
                                                                  ticketID:
                                                                      dataTicket
                                                                          .ticketId,
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              // width: 1.sw,
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left: 5.w,
                                                                      right:
                                                                          5.w),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.r),
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    spreadRadius:
                                                                        2,
                                                                    blurRadius:
                                                                        4,
                                                                    offset: const Offset(
                                                                        0,
                                                                        3), // changes position of shadow
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(10
                                                                            .w),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .airplane_ticket,
                                                                      size:
                                                                          36.sp,
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          10.w,
                                                                    ),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        TextApp(
                                                                          text:
                                                                              dataTicket.ticketTitle,
                                                                          fontsize:
                                                                              14.sp,
                                                                        ),
                                                                        TextApp(
                                                                            text:
                                                                                formatDateTime(
                                                                              dataTicket.createdAt.toString(),
                                                                            ),
                                                                            fontsize:
                                                                                14.sp),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                }),
                                          )
                                  ],
                                ));
                          } else if (state
                              is ListTicketStatusDoneStateFailure) {
                            return ErrorDialog(
                              eventConfirm: () {
                                Navigator.pop(context);
                              },
                              errorText:
                                  'Failed to fetch orders: ${state.message}',
                            );
                          }
                          return Container();
                        },
                      ))
                ],
              ),
              Positioned(
                  bottom: 100.h,
                  right: 50.h,
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CreateTicketScreen()),
                        );
                      },
                      child: Icon(
                        Icons.add,
                        size: 32.0,
                        color: Colors.white,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                  ))
            ],
          )),
    );
  }
}
