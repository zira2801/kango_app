import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_barcode_app/ui/screen/auth/confirm_otp_login.dart';
import 'package:scan_barcode_app/ui/screen/auth/forgot_password_screen.dart';
import 'package:scan_barcode_app/ui/screen/auth/sign_in_screen.dart';
import 'package:scan_barcode_app/ui/screen/auth/sign_up_customer_screen.dart';
import 'package:scan_barcode_app/ui/screen/driver/driver_list_order.dart';
import 'package:scan_barcode_app/ui/screen/driver/index_driver.dart';
import 'package:scan_barcode_app/ui/screen/home/index.dart';
import 'package:scan_barcode_app/ui/screen/order/create_new_order_pick_up.dart';
import 'package:scan_barcode_app/ui/screen/order/order_pickup_screen.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/manager_leader_sale.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/manager_support_fwd.dart';
import 'package:scan_barcode_app/ui/screen/sale_manager/sale_screen/sale_team_manager.dart';
import 'package:scan_barcode_app/ui/screen/shipper/index_shipper.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';

// GoRouter configuration
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign_up_customer',
      builder: (context, state) => const SignUpCustomerScreen(),
    ),
    GoRoute(
      path: '/confirm_otp_login',
      builder: (context, state) => const ManagerConfirmOTP(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const IndexHome(),
    ),
    GoRoute(
      path: '/home_shipper',
      builder: (context, state) => const IndexHomeShipper(),
    ),
    GoRoute(
      path: '/home_driver',
      builder: (context, state) => const DriverOrderScreen(),
    ),
    GoRoute(
      path: '/order_pickup',
      builder: (context, state) => const OrderPickUpScreen(),
    ),
    GoRoute(
      path: '/create_order_pickup',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>?;
        return CreateNewOrderPickUpScreen(
          orderPickupID: params?['orderPickupID'],
          isShipper: params?['isShipper'] ?? false,
          isOpsLead: params?['isOpsLead'] ?? false,
          isSale: params?['isSale'] ?? false,
        );
      },
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final String? token = StorageUtils.instance.getString(key: 'token');
    final bool? isShipper = StorageUtils.instance.getBool(key: 'is_shipper');
    final String? position =
        StorageUtils.instance.getString(key: 'user_position');
    log("POSITION ID");
    log(position.toString());
    if (token != null && isShipper == false && position != 'driver') {
      log("SCREEN USER");
      return '/home';
    } else if (token != null && isShipper == true && position != 'driver') {
      log("SCREEN SHIPPER");
      return '/home_shipper';
    } else if (token != null && position == 'driver') {
      log("SCREEN DRIVER");
      return '/home_driver';
    }
    return null;
  },
);
