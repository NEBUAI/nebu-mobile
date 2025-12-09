import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../data/services/api_service.dart';
import '../../data/services/health_service.dart';

/// Screen for testing backend connectivity
class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  late final HealthService _healthService;
  bool _isLoading = false;
  String? _errorMessage;
  HealthStatus? _healthStatus;

  @override
  void initState() {
    super.initState();
    // Initialize health service with dependencies
    // Note: In a real app, these would be injected via dependency injection
    final logger = Logger();
    final apiService = ApiService(
      dio: getDio(),
      secureStorage: getSecureStorage(),
      logger: logger,
    );
    _healthService = HealthService(
      apiService: apiService,
      logger: logger,
    );
  }

  // Helper methods - replace with actual dependency injection
  Dio getDio() => Dio();

  FlutterSecureStorage getSecureStorage() => const FlutterSecureStorage();

  Future<void> _checkHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _healthStatus = null;
    });

    try {
      final status = await _healthService.getDetailedHealthStatus();
      setState(() {
        _healthStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Backend Health Check'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkHealth,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isLoading ? 'Checking...' : 'Check Backend Health'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ],
                  ),
                ),
              ),
            if (_healthStatus != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusHeader(),
                          const Divider(height: 32),
                          _buildInfoSection(),
                          const Divider(height: 32),
                          _buildMemorySection(),
                          const Divider(height: 32),
                          _buildHealthChecksSection(),
                          const Divider(height: 32),
                          _buildPerformanceSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

  Widget _buildStatusHeader() {
    final status = _healthStatus!;
    final isHealthy = status.status == 'ok';

    return Row(
      children: [
        Icon(
          isHealthy ? Icons.check_circle : Icons.warning,
          color: isHealthy ? Colors.green : Colors.orange,
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.service,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Status: ${status.status.toUpperCase()}',
                style: TextStyle(
                  fontSize: 16,
                  color: isHealthy ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    final status = _healthStatus!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Version', status.version),
        _buildInfoRow('Environment', status.environment),
        _buildInfoRow(
          'Uptime',
          _formatUptime(status.uptime),
        ),
        _buildInfoRow('Timestamp', status.timestamp),
      ],
    );
  }

  Widget _buildMemorySection() {
    final memory = _healthStatus!.memory;
    if (memory == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Memory Usage',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Heap Used', '${memory.heapUsed.toStringAsFixed(2)} MB'),
        _buildInfoRow(
          'Heap Total',
          '${memory.heapTotal.toStringAsFixed(2)} MB',
        ),
        _buildProgressRow('Usage', memory.heapUsedPercent),
      ],
    );
  }

  Widget _buildHealthChecksSection() {
    final checks = _healthStatus!.checks;
    if (checks == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Checks',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildCheckRow('Database', checks.database),
        _buildCheckRow('Redis', checks.redis),
        _buildCheckRow('Configuration', checks.configuration),
      ],
    );
  }

  Widget _buildPerformanceSection() {
    final performance = _healthStatus!.performance;
    if (performance == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Response Time', '${performance.responseTime}ms'),
        _buildInfoRow('Process ID', '${performance.pid}'),
        _buildInfoRow('Platform', performance.platform),
        _buildInfoRow('Node Version', performance.nodeVersion),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );

  Widget _buildProgressRow(String label, int percent) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  '$label:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text('$percent%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              percent > 80 ? Colors.orange : Colors.blue,
            ),
          ),
        ],
      ),
    );

  Widget _buildCheckRow(String label, CheckStatus check) {
    final isHealthy = check.status == 'ok';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: isHealthy ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            check.status.toUpperCase(),
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatUptime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
