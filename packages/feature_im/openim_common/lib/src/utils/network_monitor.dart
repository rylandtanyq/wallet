import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkMonitor {
  // Singleton instance
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>>
      _subscription; // Subscription to network changes
  List<ConnectivityResult> _currentStatus =
      <ConnectivityResult>[]; // Current network status
  Function(List<ConnectivityResult>)?
      _onStatusChanged; // Callback for status changes

  // Private constructor for singleton pattern
  NetworkMonitor._internal() {
    _init();
  }

  /// Initialize network monitoring
  void _init() {
    // Listen to network changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _currentStatus = result;
      _onStatusChanged?.call(result);
    });
    _checkInitialStatus();
  }

  /// Check initial network status
  Future<void> _checkInitialStatus() async {
    _currentStatus = await _connectivity.checkConnectivity();
    _onStatusChanged?.call(_currentStatus);
  }

  /// Get current network status
  List<ConnectivityResult> get currentStatus => _currentStatus;

  /// Register callback for network status changes
  void onNetworkChanged(Function(List<ConnectivityResult>) callback) {
    _onStatusChanged = callback;
  }

  /// Check if the network is actually available (requires internet access)
  Future<bool> isNetworkAvailable() async {
    if (_currentStatus.contains(ConnectivityResult.none)) return false;
    try {
      final result = await InternetAddress.lookup('www.openim.io');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription.cancel();
  }
}
