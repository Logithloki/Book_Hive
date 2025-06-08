import 'package:flutter/material.dart';
import 'dart:async';
import '../services/connectivity_service.dart';

class ConnectivityStatus extends StatefulWidget {
  final Widget child;
  final bool showSnackBar;
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;

  const ConnectivityStatus({
    super.key,
    required this.child,
    this.showSnackBar = true,
    this.onConnected,
    this.onDisconnected,
  });

  @override
  State<ConnectivityStatus> createState() => _ConnectivityStatusState();
}

class _ConnectivityStatusState extends State<ConnectivityStatus> {
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isConnected = true;
  bool _hasShownOfflineMessage = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    _isConnected = _connectivityService.isConnected;

    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        setState(() {
          _isConnected = isConnected;
        });

        if (widget.showSnackBar) {
          _showConnectivitySnackBar(isConnected);
        }

        // Call callbacks
        if (isConnected) {
          widget.onConnected?.call();
          _hasShownOfflineMessage = false;
        } else {
          widget.onDisconnected?.call();
        }
      },
    );
  }

  void _showConnectivitySnackBar(bool isConnected) {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (isConnected) {
      if (_hasShownOfflineMessage) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi, color: Colors.white),
                SizedBox(width: 8),
                Text('Connection restored'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      _hasShownOfflineMessage = true;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text('No internet connection'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              _connectivityService.checkConnectivity();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isConnected)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'No internet connection',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _connectivityService.checkConnectivity();
                    },
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// Widget to show when there's no connectivity
class NoConnectivityWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NoConnectivityWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry ??
                  () {
                    ConnectivityService().checkConnectivity();
                  },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Loading widget that handles connectivity
class ConnectivityAwareLoader extends StatefulWidget {
  final Future<dynamic> future;
  final Widget Function(BuildContext context, dynamic data) builder;
  final Widget? loadingWidget;
  final Widget Function(BuildContext context, Object error)? errorBuilder;
  final bool checkConnectivity;

  const ConnectivityAwareLoader({
    super.key,
    required this.future,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.checkConnectivity = true,
  });

  @override
  State<ConnectivityAwareLoader> createState() =>
      _ConnectivityAwareLoaderState();
}

class _ConnectivityAwareLoaderState extends State<ConnectivityAwareLoader> {
  @override
  Widget build(BuildContext context) {
    if (widget.checkConnectivity) {
      return StreamBuilder<bool>(
        stream: ConnectivityService().connectivityStream,
        initialData: ConnectivityService().isConnected,
        builder: (context, connectivitySnapshot) {
          final isConnected = connectivitySnapshot.data ?? false;

          if (!isConnected) {
            return NoConnectivityWidget(
              onRetry: () {
                setState(() {
                  // Trigger rebuild
                });
              },
            );
          }

          return _buildFutureBuilder();
        },
      );
    }

    return _buildFutureBuilder();
  }

  Widget _buildFutureBuilder() {
    return FutureBuilder<dynamic>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingWidget ??
              const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, snapshot.error!);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'An error occurred',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Trigger rebuild
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data);
        }

        return const Center(child: Text('No data available'));
      },
    );
  }
}
