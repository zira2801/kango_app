import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:scan_barcode_app/bloc/bloc_provider.dart';
import 'package:scan_barcode_app/copytessdata.dart';
import 'package:scan_barcode_app/data/providers/theme_provider.dart';
import 'package:scan_barcode_app/data/router/index.dart';
import 'package:scan_barcode_app/ui/screen/no_internet/index.dart';
import 'package:scan_barcode_app/ui/utils/storage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initTimeAgo();
  await StorageUtils.instance.init();

// Gọi hàm copy dữ liệu TessData
  await copyTessDataToAppDirectory();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

Future<void> initTimeAgo() async {
  timeago.setLocaleMessages('vi', timeago.ViMessages());
  timeago.setDefaultLocale('vi');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool isConnected = true;
  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    if (!mounted) {
      return;
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet) ||
        result.contains(ConnectivityResult.vpn) ||
        result.contains(ConnectivityResult.bluetooth) ||
        result.contains(ConnectivityResult.other)) {
      setState(() {
        isConnected = true;
      });
    } else if (result.contains(ConnectivityResult.none)) {
      setState(() {
        isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return ScreenUtilInit(
        designSize: screenWidth > 600 ? Size(600, 1024) : Size(430, 932),
        builder: (BuildContext context, Widget? child) {
          return child!;
        },
        child: AppBlocProvider(
          child: !isConnected
              ? const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: NoInternetScreen(),
                )
              : Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return MaterialApp.router(
                      debugShowCheckedModeBanner: false,
                      theme: themeProvider.themeDataStyle,
                      localizationsDelegates: const [
                        // Delegate của Flutter
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,

                        // Delegate của Flutter Quill
                        quill.FlutterQuillLocalizations.delegate,
                      ],
                      supportedLocales: const [
                        Locale(
                            'en'), // Thêm ngôn ngữ bạn muốn hỗ trợ (VD: Tiếng Anh)
                        Locale('vi'), // Thêm Tiếng Việt nếu cần
                      ],
                      routerConfig: router,
                    );
                  },
                ),
        ));
  }
}
