// ignore_for_file: avoid_print

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Stream controller for connectivity status changes
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _updateConnectivityStatus();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _handleConnectivityChange(result);
      },
    );
  }

  // Handle connectivity changes
  void _handleConnectivityChange(ConnectivityResult result) async {
    print('Connectivity changed: $result');
    await _updateConnectivityStatus();
  }

  // Update connectivity status with actual internet check
  Future<void> _updateConnectivityStatus() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      print('Connectivity check result: $connectivityResult');

      // Check if we have any connection type
      final hasConnection = connectivityResult != ConnectivityResult.none;

      if (!hasConnection) {
        _setConnectivityStatus(false);
        return;
      }

      // Test actual internet connectivity
      final hasInternet = await _checkInternetConnectivity();
      _setConnectivityStatus(hasInternet);
    } catch (e) {
      print('Error checking connectivity: $e');
      _setConnectivityStatus(false);
    }
  }

  // Check actual internet connectivity by making a test request
  Future<bool> _checkInternetConnectivity() async {
    try {
      // Try multiple endpoints for better reliability
      final endpoints = [
        'https://www.google.com',
        'https://dns.google',
        'https://cloudflare.com',
      ];

      for (final endpoint in endpoints) {
        try {
          final response = await http
              .head(
                Uri.parse(endpoint),
              )
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            print('Internet connectivity confirmed via $endpoint');
            return true;
          }
        } catch (e) {
          print('Failed to connect to $endpoint: $e');
          continue;
        }
      }

      print('No internet connectivity confirmed');
      return false;
    } catch (e) {
      print('Error testing internet connectivity: $e');
      return false;
    }
  }

  // Set connectivity status and notify listeners
  void _setConnectivityStatus(bool isConnected) {
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      print(
          'Connectivity status changed: ${isConnected ? "Connected" : "Disconnected"}');
      _connectivityController.add(isConnected);
    }
  }

  // Manual connectivity check
  Future<bool> checkConnectivity() async {
    await _updateConnectivityStatus();
    return _isConnected;
  }

  // Get current connectivity type details
  Future<Map<String, dynamic>> getConnectivityDetails() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      return {
        'hasConnection': _isConnected,
        'connectionTypes': [connectivityResult.name],
        'isWifi': connectivityResult == ConnectivityResult.wifi,
        'isMobile': connectivityResult == ConnectivityResult.mobile,
        'isEthernet': connectivityResult == ConnectivityResult.ethernet,
      };
    } catch (e) {
      print('Error getting connectivity details: $e');
      return {
        'hasConnection': false,
        'connectionTypes': [],
        'isWifi': false,
        'isMobile': false,
        'isEthernet': false,
      };
    }
  }

  // Check if we should show offline message
  bool shouldShowOfflineMessage() {
    return !_isConnected;
  }

  // Get appropriate error message for no connectivity
  String getNoConnectivityMessage() {
    return 'No internet connection. Please check your network settings and try again.';
  }

  // Wait for connectivity before proceeding
  Future<bool> waitForConnectivity(
      {Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return true;

    final completer = Completer<bool>();
    late StreamSubscription subscription;

    // Set up timeout
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.complete(false);
      }
    });

    // Listen for connectivity
    subscription = connectivityStream.listen((isConnected) {
      if (isConnected && !completer.isCompleted) {
        timer.cancel();
        subscription.cancel();
        completer.complete(true);
      }
    });

    return completer.future;
  }

  // Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }
}

// Mixin for widgets that need connectivity monitoring
mixin ConnectivityMixin {
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  void initializeConnectivity() {
    final connectivityService = ConnectivityService();
    _isConnected = connectivityService.isConnected;

    _connectivitySubscription = connectivityService.connectivityStream.listen(
      (isConnected) {
        _isConnected = isConnected;
        onConnectivityChanged(isConnected);
      },
    );
  }

  void disposeConnectivity() {
    _connectivitySubscription?.cancel();
  }

  // Override this method to handle connectivity changes
  void onConnectivityChanged(bool isConnected) {
    print('Connectivity changed: $isConnected');
  }

  // Show connectivity error message
  void showConnectivityError() {
    // This should be overridden by the implementing widget
    print('No internet connection available');
  }

  // Check connectivity before network operations
  Future<bool> ensureConnectivity() async {
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.checkConnectivity();

    if (!isConnected) {
      showConnectivityError();
      return false;
    }

    return true;
  }
}
