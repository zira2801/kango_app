import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scan_barcode_app/bloc/audit_epacket/audit_epacket_bloc.dart';
import 'package:scan_barcode_app/bloc/auth/logout_bloc/logout_bloc.dart';
import 'package:scan_barcode_app/bloc/debit/debit_bloc.dart';
import 'package:scan_barcode_app/bloc/home/home_bloc/home_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/mawb/list_mawb_bloc.dart';
import 'package:scan_barcode_app/bloc/menu/menu_bloc.dart';
import 'package:scan_barcode_app/bloc/notification/notification_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/delete_shipper_form_order/delete_shipper_form_order_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/details/details_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/details_bottom_modal/details_order_pickup_bottom_modal_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/get_fwd_list/get_fwd_list_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/get_shipper_list/get_shipper_list_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/screen/order_pickup_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/tracking_order_pickup/tracking_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/order_pickup/update/update_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/profile/change_password/change_password_bloc.dart';
import 'package:scan_barcode_app/bloc/profile/get_infor/get_infor_bloc.dart';
import 'package:scan_barcode_app/bloc/profile/update_account_key/update_account_key_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/check_payment_bank/check_payment_bank_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/content_payment/content_payment_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/create_sepay/create_sepay_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/get_infor_sepay/get_infor_sepay_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/recharge_USDT/rechargeUSDT_bloc.dart';
import 'package:scan_barcode_app/bloc/recharge/recharge_history/recharge_history_bloc.dart';
import 'package:scan_barcode_app/bloc/sale_manager/home_sale_manager/home_sale_manager_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/list_scan/list_scan_import/list_scan_import_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/list_scan/list_scan_over_48h/list_scan_import_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/details_bag_code/details_bag_code_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_bag_code/scan_bag_code_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_code_export/scan_code_export_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_code_import/scan_code_import_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_code_return/scan_code_return_bloc.dart';
import 'package:scan_barcode_app/bloc/scan/scan_code/scan_code_transit/scan_code_transit_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/create_new_shipment/create_new_shipment_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/details_tracking_shipment/details_tracking_shipment_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/get_sale_list/get_sale_list_bloc.dart';
import 'package:scan_barcode_app/bloc/shipment/list_shipment_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/choose_branch_return.dart/choose_branch_return_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/details_order_pickup_shipper/details_order_pickup_shipper_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/map_shipper/map_shipper_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_finish/shipper_finish_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_list_order/shipper_list_order_screen_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/shipper_start/shipper_start_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/take_order_pickup/take_order_pickup_bloc.dart';
import 'package:scan_barcode_app/bloc/shipper/update_status_order_shipper/update_status_order_shipper_bloc.dart';
import 'package:scan_barcode_app/bloc/test_map2/test_map2_bloc.dart';
import 'package:scan_barcode_app/bloc/ticket/create_ticket/create_ticket_bloc.dart';
import 'package:scan_barcode_app/bloc/ticket/details_ticket/details_ticket_bloc.dart';
import 'package:scan_barcode_app/bloc/ticket/list_ticket/list_ticket_bloc.dart';
import 'package:scan_barcode_app/bloc/transfer/transfer_bloc.dart';
import 'package:scan_barcode_app/bloc/wallet/wallet_bloc.dart';
import 'package:scan_barcode_app/bloc/wallet_fluctuations/wallet_fluctuations_bloc.dart';

class AppBlocProvider extends StatelessWidget {
  const AppBlocProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeScreenBloc()),
        BlocProvider(create: (_) => GetListOrderPickupScreenBloc()),
        BlocProvider(create: (_) => DetailsOrderPickupBloc()),
        BlocProvider(create: (_) => UpdateOrderPickupBloc()),
        BlocProvider(create: (_) => ListScanImportBloc()),
        BlocProvider(create: (_) => ListScanOver48HBloc()),
        BlocProvider(create: (_) => ListShipmentBloc()),
        BlocProvider(create: (_) => DeleteShipmentBloc()),
        BlocProvider(create: (_) => DetailsShipmentBloc()),
        BlocProvider(create: (_) => ScanImportBloc()),
        BlocProvider(create: (_) => ScanExportBloc()),
        BlocProvider(create: (_) => ScanReturnBloc()),
        BlocProvider(create: (_) => ScanInTransitBloc()),
        BlocProvider(create: (_) => ListTypeTicketBloc()),
        BlocProvider(create: (_) => ListTicketBloc()),
        BlocProvider(create: (_) => DetailsTicketBloc()),
        BlocProvider(create: (_) => ChangePasswordBloc()),
        BlocProvider(create: (_) => ReChargeHistoryBloc()),
        BlocProvider(create: (_) => DetailsReChargeHistoryBloc()),
        BlocProvider(create: (_) => ReChargeUSDTBloc()),
        BlocProvider(create: (_) => CreateNewShipmentBloc()),
        BlocProvider(create: (_) => GetDeliveryServiceBloc()),
        BlocProvider(create: (_) => GetListOldReceiverBloc()),
        BlocProvider(create: (_) => GetAllUnitShipmentBloc()),
        BlocProvider(create: (_) => HandleGetInforOldRecieveBloc()),
        BlocProvider(create: (_) => HandleGetInforUserBloc()),
        BlocProvider(create: (_) => HomeScreenDashBoardBloc()),
        BlocProvider(create: (_) => FilterDashBoardBloc()),
        BlocProvider(create: (_) => MapBloc2()),
        BlocProvider(create: (_) => GetInforProfileBloc()),
        BlocProvider(create: (_) => GetAreaVNBloc()),
        BlocProvider(create: (_) => UpdateProfileBloc()),
        BlocProvider(create: (_) => UpdateStatusOrderPickupShipperBloc()),
        BlocProvider(create: (_) => ChooseBranchReturnBloc()),
        BlocProvider(create: (_) => MapShipperBloc()),
        BlocProvider(create: (_) => DetailsOrderPickupModalBottomBloc()),
        BlocProvider(create: (_) => TakeOrderPickupBloc()),
        BlocProvider(create: (_) => GetShipperListOrderScreenBloc()),
        BlocProvider(create: (_) => DetailsOrderPickupShipperBloc()),
        BlocProvider(create: (_) => TrackingOrderPickupBloc()),
        BlocProvider(create: (_) => GetListFWDScreenBloc()),
        BlocProvider(create: (_) => GetListShipperFreeScreenBloc()),
        BlocProvider(create: (_) => ShipperFinishBloc()),
        BlocProvider(create: (_) => ShipperStartBloc()),
        BlocProvider(create: (_) => DetailsBagCodeBloc()),
        BlocProvider(create: (_) => ScanBagCodeBloc()),
        BlocProvider(create: (_) => DeleteScanImportBloc()),
        BlocProvider(create: (_) => DeleteShipperFormBloc()),
        BlocProvider(create: (_) => DetailsTrackingShipmentBloc()),
        BlocProvider(create: (_) => GetListSaleScreenBloc()),
        BlocProvider(create: (_) => CheckPaymentBankBloc()),
        BlocProvider(create: (_) => CreateSePayBloc()),
        BlocProvider(create: (_) => GetInforSePayBloc()),
        BlocProvider(create: (_) => MAWBListBloc()),
        BlocProvider(create: (_) => PaymentContentBloc()),
        BlocProvider(create: (_) => LogoutBloc()),
        BlocProvider(create: (_) => UpdateAccountKeyBloc()),
        BlocProvider(create: (_) => WalletBloc()),
        BlocProvider(create: (_) => MenuBloc()),
        BlocProvider(create: (_) => NotificationBloc()),
        BlocProvider(create: (_) => CreateNotificationBloc()),
        BlocProvider(create: (_) => DetailsNotificationBloc()),
        BlocProvider(create: (_) => UpdateNotificationBloc()),
        BlocProvider(
          create: (_) => DeleteNotificationBloc(),
        ),
        BlocProvider(create: (_) => GetListAuditEpacketBloc()),
        BlocProvider(create: (_) => DetailsAuditEpacketBloc()),
        BlocProvider(create: (_) => UpdateAuditEpacketBloc()),
        BlocProvider(create: (_) => GetListWalletFluctuationsBloc()),
        BlocProvider(create: (_) => GetListDebitBloc()),
        BlocProvider(create: (_) => GetListTransferBloc()),
        BlocProvider(create: (_) => ApproveTransferBloc()),
        BlocProvider(create: (_) => DeleteTransferBloc()),
        BlocProvider(create: (_) => CreateTransferBloc()),
        BlocProvider(create: (_) => SaleManagerBloc()),
        BlocProvider(create: (_) => GetListSaleTeamLeaderBloc()),
        BlocProvider(create: (_) => GetUsersSaleLeaderBloc()),
        BlocProvider(create: (_) => AddMemberToTeamBloc()),
        BlocProvider(create: (_) => GetSaleLeaderStatisticBloc()),
        BlocProvider(create: (_) => GetListShipmentSaleBloc()),
        BlocProvider(create: (_) => GetListSaleSupportFWDBloc()),
        BlocProvider(create: (_) => GetListFwdNoLinkBloc()),
        BlocProvider(create: (_) => LinkFwdToSaleBloc()),
        BlocProvider(create: (_) => GetDetailFwdSupportBloc()),
        BlocProvider(create: (_) => GetListCostFWDBloc()),
        BlocProvider(create: (_) => GetListShipmentFwdBloc()),
        BlocProvider(create: (_) => DeleteSaleSupportFWDBloc()),
        BlocProvider(create: (_) => CheckAccountainCodeDebitBloc()),
        BlocProvider(create: (_) => GetListDebitShipmentBloc()),
        BlocProvider(create: (_) => GetDetailDebitBloc()),
        BlocProvider(create: (_) => PaymentDebitBloc()),
        BlocProvider(create: (_) => AddLeaderBloc()),
        BlocProvider(create: (_) => AddMemberToTeamSaleBloc()),
        BlocProvider(create: (_) => UpdateStatusMemeberBloc()),
        BlocProvider(create: (_) => TransferMemberToTeamBloc()),
        BlocProvider(create: (_) => DeleteTeamBloc())
      ],
      child: child,
    );
  }
}
