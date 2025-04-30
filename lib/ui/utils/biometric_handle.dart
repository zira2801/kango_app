import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
    }
    return authenticated;
  }

  Future<bool> canCheckBiometrics() async {
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    return canCheckBiometrics;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics = [];
    try {
      availableBiometrics = await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    return availableBiometrics;
  }
}
