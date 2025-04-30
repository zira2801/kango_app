//auth
const String loginApi = 'login';
const String accuracyApi = 'accuracy';
const String registerApi = 'register';
const String logutApi = 'logout';

//menu
const String getMenu = 'menu-user';
//acount
const String getInforAccount = 'profile/info';
const String editInforAccount = 'profile/edit';
const String changePassword = 'profile/update-password';
const String updateAccountKey = 'update-user-accountant-key';
const String forgotPasswordApi = 'forgot-password';
//recharge money
const String requestRechangeMoney = 'recharge/create';
const String listRechangeMoney = 'recharge/list';
const String detailsRechangeMoney = 'recharge/detail';
const String createSePay = 'sepay/recharge';
const String checkSePay = 'sepay/check-payment';
const String walletApi = 'wallet/user';

//order pickup
const String orderPickUpPaginationApi = 'order-pickup/pagination';
const String detailsOrderPickUpAPI = 'order-pickup/detail';
const String deleteOrderPickUpAPI = 'order-pickup/delete';
const String updateOrderPickUpAPI = 'order-pickup/update';

//shipment
const String getListShipment = 'shipments/list';
const String createNewShipment = 'shipments/create';
const String getDetailsShipmentApi = 'shipments/detail';
const String getDataUpdateShipmentApi = 'shipments/edit';
const String updateShipmentApi = 'shipments/edit/handle';
const String deleteShipmentApi = 'shipments/delete';
const String getListOldReceiverApi = 'shipments/get-receivers';
const String getDeliveryServiceApi = 'services-by-country';
const String typeAndUnitShpment =
    'shipments/get-unit-create-package-and-invoice';
const String inforOldReceiverApi = 'shipments/get-detail-receiver';
const String shipmentOperatingCosts =
    'shipments/detail/shipment-operating-costs';
const String hanldeUpdateShipmentOperatingCosts =
    'shipments/detail/save-shipment-operating-costs';
const String shipmentUpdateFreight = 'shipments/update-freight';
const String updateLableShipment = 'shipments/update-label';
const String updatePaymentProofShipment = 'shipments/update-method';
const String getListTypeServiceShipement = 'shipments/service-type';
// utils
const String getBranchs = 'utils/branchs';
const String getAreaApi = 'countries';
const String getAreaVNApi = 'areas-in-viet-nam';

//deep link API

const String vnPayApi = 'recharge/vnpay';
const String checkStatusVNPayApi = 'recharge/detail';

//scan
const String updateScanStatus = 'scan/update-status';
const String historyScan = 'scan/list';
const String deleteScanImport = 'scan/cancel-status';
const String getDetailsPackage = 'scan/export/modal';
const String getListSurchangeGoods = 'scan/list/surchage-goods';
const String getListMAWBApi = 'mawb-manager/list-sm-tracktry';
const String scanBagCodeApi = 'scan/bag-code/check';
const String scanDetailsExportWithBagCode = 'scan/export/modal';

//ticket
const String getListTypeTicket = 'tickets/setup';
const String createTicketApi = 'tickets/add';
const String getlistTicketApi = 'tickets/me';
const String getDetailTicketApi = 'tickets/detail';
const String sendMessTicket = 'tickets/add-message';

//dashboard
const String getListDataDashboard = 'dashboard';
const String getSetupDataDashboard = 'dashboard-setup';
//shipper
const String listShipperFree = 'order-pickup/shippers-free';
const String shipperTakeOrderPickup = 'order-pickup/shipper-take';
const String getCurrentPositionOfShipper =
    'order-pickup/shipper-update-location';
const String shipperStart = 'order-pickup/shipper-start';
const String shipperFinish = 'order-pickup/shipper-finished';
const String deleteShipperFormOrder = 'order-pickup/shipper-cancel';
//fwd
const String getListFwd = 'manage/users-fwd';
//sale
const String getListSale = 'manage/users-sale';
//label
const String createLabel = 'shipments/create-label-reload';

//policy
const String getHTMLPolicy = 'terms-of-use';

//tracking shipment
const String getShipmentTrackingDetails = 'tracking';

//Notification
const String getListNotification = 'notifications';
const String detailNotification = 'notifications/detail/';
const String createNotification = 'notifications/create';
const String updateNotification = 'notifications/edit';
const String deleteNotification = 'notifications/delete';

//Audit E-Packet
const String getListAuditEpacket = 'audit-epacket/pagination';
const String getListServiceAuditEpacket = 'audit-epacket/epackage-services';
const String getListServicePackageManager =
    'audit-epacket/package-manager-services';
const String updateNoteAuditEpacket = 'audit-epacket/update-note';

//Bien dong so du
const String getListBienDongSoDu = 'accountant/wallet-fluctuations/paginate';

//Debit chuyến tuyến
const String getListDebitChuyenTuyen = 'debit/fwd-paginate';
const String verifyAccountainCode = 'debit/verify';
const String getShipmentDebit = 'debit/detail-shipment';
const String paymentDebit = 'debit/payment-fwd';
const String debitDetail = 'debit/detail/';

//Transfer List (KHAI HÀNG)
const String getListTransferList = 'transfer/pagination';
const String createTransferList =
    'transfer/update'; //Nếu mà có mã transfer thì là cập nhật
const String deleteTransfer = 'transfer/delete';
const String approveTransfer = 'transfer/approve';

//Sale Manager
const String getHomeSaleManager = 'sale';
const String getLeaderSale = 'sale/leader';
const String getSaleLeaderList = 'sale/leader-list';
const String getUsersSaleList = 'sale/leader-users';
const String addSaleMember = 'sale/add-miltiple-member';
const String addSaleLeader = 'sale/add-miltiple-leader';
const String updateMemberTeam = 'sale/update-member-team';
const String transferMemberToTeam = 'sale/transfer-to-team';
const String deleteTeam = 'sale/delete-team';
const String saleLeaderInfo = 'sale/detail';
const String getShipmentsSale = 'sale/detail/shipments';
const String getListSaleSupportFWD = 'sale/fwd/list-link';
const String getListFwdNoLink = 'sale/fwd/no-link';
const String linkFwdToSaleApi = 'sale/fwd/create-link';

//Fwd
const String getDetailFwdSupportAPI = 'sale/fwd/company';
const String getListShipmentFWD = 'sale/fwd/company/shipments';
const String getListCostFwd = 'sale/fwd/add-cost/list';
const String deleteSaleSupportFWD = 'manages/sale/fwd/delete-link';
