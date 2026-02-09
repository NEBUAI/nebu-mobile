import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';
import '../providers/api_provider.dart';
import '../providers/auth_provider.dart';

// State
class QRScannerState {
  QRScannerState({
    required this.scannedCode,
    required this.isProcessing,
    required this.scannerController,
  });
  final String scannedCode;
  final bool isProcessing;
  final MobileScannerController scannerController;

  QRScannerState copyWith({
    String? scannedCode,
    bool? isProcessing,
    MobileScannerController? scannerController,
  }) => QRScannerState(
    scannedCode: scannedCode ?? this.scannedCode,
    isProcessing: isProcessing ?? this.isProcessing,
    scannerController: scannerController ?? this.scannerController,
  );
}

// Notifier
class QRScannerNotifier extends Notifier<QRScannerState> {
  @override
  QRScannerState build() {
    ref.onDispose(() {
      state.scannerController.dispose();
    });

    return QRScannerState(
      scannedCode: '',
      isProcessing: false,
      scannerController: MobileScannerController(),
    );
  }

  void handleQRCode(String? code, BuildContext context) {
    if (code == null || code.isEmpty || state.isProcessing) {
      return;
    }

    state = state.copyWith(isProcessing: true, scannedCode: code);

    _processQRCode(code, context);
  }

  Future<void> _processQRCode(String code, BuildContext context) async {
    // Check if code looks like a MAC address (e.g. AA:BB:CC:DD:EE:FF)
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:\-]){5}[0-9A-Fa-f]{2}$');
    final isMacAddress = macRegex.hasMatch(code.trim());

    if (isMacAddress) {
      await _assignToyByMac(code.trim(), context);
    } else {
      // Show generic scanned code dialog for non-MAC QR codes
      if (!context.mounted) {
        return;
      }
      showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('qr_scanner.scanned'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('qr_scanner.unrecognized_format'.tr()),
              const SizedBox(height: 8),
              Text(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                state = state.copyWith(isProcessing: false);
              },
              child: Text('qr_scanner.scan_again'.tr()),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _assignToyByMac(String macAddress, BuildContext context) async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      state = state.copyWith(isProcessing: false);
      return;
    }

    try {
      final toyService = ref.read(toyServiceProvider);
      final result = await toyService.assignToy(
        macAddress: macAddress,
        userId: user.id,
      );

      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: Text('qr_scanner.toy_assigned'.tr()),
          content: Text(
            'qr_scanner.toy_assigned_desc'.tr(
              args: [result.toy?.name ?? macAddress],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: Text('qr_scanner.done'.tr()),
            ),
          ],
        ),
      );
    } on Exception catch (e) {
      if (!context.mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red, size: 48),
          title: Text('qr_scanner.assignment_failed'.tr()),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                state = state.copyWith(isProcessing: false);
              },
              child: Text('qr_scanner.scan_again'.tr()),
            ),
          ],
        ),
      );
    }
  }
}

// Provider
final qrScannerProvider = NotifierProvider<QRScannerNotifier, QRScannerState>(
  QRScannerNotifier.new,
);

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrScannerProvider);
    final notifier = ref.read(qrScannerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('qr_scanner.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: state.scannerController.switchCamera,
          ),
          IconButton(
            icon: Icon(
              state.scannerController.torchEnabled
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
            onPressed: state.scannerController.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: state.scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                notifier.handleQRCode(barcode.rawValue, context);
              }
            },
          ),
          _buildScannerOverlay(),
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() => Center(
    child: Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryLight, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Corner indicators
          Positioned(top: 0, left: 0, child: _buildCorner(true, true)),
          Positioned(top: 0, right: 0, child: _buildCorner(true, false)),
          Positioned(bottom: 0, left: 0, child: _buildCorner(false, true)),
          Positioned(bottom: 0, right: 0, child: _buildCorner(false, false)),
        ],
      ),
    ),
  );

  Widget _buildCorner(bool top, bool left) => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      border: Border(
        top: top
            ? const BorderSide(color: AppTheme.primaryLight, width: 4)
            : BorderSide.none,
        left: left
            ? const BorderSide(color: AppTheme.primaryLight, width: 4)
            : BorderSide.none,
        bottom: !top
            ? const BorderSide(color: AppTheme.primaryLight, width: 4)
            : BorderSide.none,
        right: !left
            ? const BorderSide(color: AppTheme.primaryLight, width: 4)
            : BorderSide.none,
      ),
    ),
  );

  Widget _buildInstructions() => Positioned(
    bottom: 50,
    left: 0,
    right: 0,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Position the QR code within the frame to scan',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ),
  );
}
