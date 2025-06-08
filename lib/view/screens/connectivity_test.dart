import 'package:flutter/material.dart';
import 'package:book_store/services/connectivity_service.dart';
import 'package:book_store/widgets/connectivity_status.dart';

class ConnectivityTestPage extends StatefulWidget {
  const ConnectivityTestPage({super.key});

  @override
  State<ConnectivityTestPage> createState() => _ConnectivityTestPageState();
}

class _ConnectivityTestPageState extends State<ConnectivityTestPage>
    with ConnectivityMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  Map<String, dynamic> _connectivityDetails = {};
  bool _isLoading = false;
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    initializeConnectivity();
    _checkConnectivity();
  }

  @override
  void dispose() {
    disposeConnectivity();
    super.dispose();
  }

  @override
  void onConnectivityChanged(bool isConnected) {
    setState(() {
      _lastMessage = isConnected
          ? 'Connection restored at ${DateTime.now()}'
          : 'Connection lost at ${DateTime.now()}';
    });

    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isConnected ? 'Connected to internet' : 'No internet connection'),
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Refresh connectivity details
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final details = await _connectivityService.getConnectivityDetails();
      setState(() {
        _connectivityDetails = details;
      });
    } catch (e) {
      setState(() {
        _lastMessage = 'Error checking connectivity: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testApiCall() async {
    setState(() {
      _isLoading = true;
      _lastMessage = 'Testing API call...';
    });

    try {
      // Simulate an API call
      await Future.delayed(const Duration(seconds: 1));

      final hasConnection = await _connectivityService.checkConnectivity();
      setState(() {
        _lastMessage = hasConnection
            ? 'API call would succeed - Connection available'
            : 'API call would fail - No connection';
      });
    } catch (e) {
      setState(() {
        _lastMessage = 'API test error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityStatus(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connectivity Test'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Card
              Card(
                color: isConnected ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        isConnected ? Icons.wifi : Icons.wifi_off,
                        color: isConnected ? Colors.green : Colors.red,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isConnected ? 'Connected' : 'Disconnected',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isConnected ? Colors.green : Colors.red,
                              ),
                            ),
                            Text(
                              isConnected
                                  ? 'Internet connection is available'
                                  : 'No internet connection',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Connectivity Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Connection Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Column(
                          children: [
                            _buildDetailRow(
                                'Has Connection',
                                _connectivityDetails['hasConnection']
                                        ?.toString() ??
                                    'Unknown'),
                            _buildDetailRow(
                                'Connection Types',
                                _connectivityDetails['connectionTypes']
                                        ?.join(', ') ??
                                    'None'),
                            _buildDetailRow(
                                'WiFi',
                                _connectivityDetails['isWifi']?.toString() ??
                                    'Unknown'),
                            _buildDetailRow(
                                'Mobile Data',
                                _connectivityDetails['isMobile']?.toString() ??
                                    'Unknown'),
                            _buildDetailRow(
                                'Ethernet',
                                _connectivityDetails['isEthernet']
                                        ?.toString() ??
                                    'Unknown'),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _checkConnectivity,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testApiCall,
                      icon: const Icon(Icons.cloud),
                      label: const Text('Test API'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Last Message
              if (_lastMessage.isNotEmpty)
                Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _lastMessage,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // Instructions
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Test Instructions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Turn off WiFi/Mobile data to test offline behavior\n'
                        '• Turn on connection to see reconnection\n'
                        '• Watch the status change in real-time\n'
                        '• Test API calls with and without connection',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
