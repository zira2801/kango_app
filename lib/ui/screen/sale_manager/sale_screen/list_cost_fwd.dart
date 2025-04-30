import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/data/models/sale_leader/cost_fwd.dart';
import 'package:scan_barcode_app/ui/widgets/no_data_widget.dart';
import 'package:scan_barcode_app/ui/widgets/text/text_app.dart';

class ListCostFwdScreen extends StatelessWidget {
  final int? companyID;
  final String? userPosition;
  final bool? canUploadLabel;
  final bool? canUploadPayment;
  const ListCostFwdScreen(
      {super.key,
      this.companyID,
      this.userPosition,
      this.canUploadLabel,
      this.canUploadPayment});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextApp(
          text: "BẢNG ÁP GIÁ COST CHO TỪNG DỊCH VỤ",
          fontWeight: FontWeight.bold,
          fontsize: 20.sp,
        ),
      ),
      body: BlocProvider(
        create: (context) =>
            GetListCostFWDBloc()..add(GetListCodeFWD(companyID: companyID)),
        child: _CostListView(companyID!),
      ),
    );
  }
}

class _CostListView extends StatelessWidget {
  final int companyID;
  const _CostListView(this.companyID);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetListCostFWDBloc, SaleManagerState>(
      builder: (context, state) {
        if (state is GetListCostStateLoading) {
          return Center(
            child: SizedBox(
              width: 100.w,
              height: 100.w,
              child: Lottie.asset('assets/lottie/loading_kango.json'),
            ),
          );
        }

        if (state is GetListCostStateFailure) {
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

        if (state is GetListCostStateSuccess) {
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<GetListCostFWDBloc>()
                  .add(GetListCodeFWD(companyID: companyID));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: state.data.length + 1,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index < state.data.length) {
                  final cost = state.data[index];
                  return _CostServiceCard(cost: cost);
                }

                if (!state.hasReachedMax) {
                  context
                      .read<GetListCostFWDBloc>()
                      .add(LoadMoreListCostFWD(companyID: companyID));
                  return Center(
                    child: SizedBox(
                      width: 100.w,
                      height: 100.w,
                      child: Lottie.asset('assets/lottie/loading_kango.json'),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        }

        return const NoDataFoundWidget();
      },
    );
  }
}

class _CostServiceCard extends StatelessWidget {
  final UserCost cost;

  const _CostServiceCard({required this.cost});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextApp(
                text: cost.serviceName ?? '',
                fontsize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            _buildCostRow('Cost Leader: ', cost.leaderCost ?? 0),
            _buildCostRow('Cost Member: ', cost.memberCost ?? 0),
            _buildCostRow('Cost Leader Member: ', cost.leaderMemberCost ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, int? value) {
    final formatter = NumberFormat("#,###", "vi_VN");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextApp(
            text: label,
            fontWeight: FontWeight.w500,
            fontsize: 15.sp,
          ),
          TextApp(
            text: value != null ? '${formatter.format(value)} /kg' : 'N/A',
            fontWeight: FontWeight.w600,
            fontsize: 15.sp,
          ),
        ],
      ),
    );
  }
}
