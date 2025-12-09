import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';

// State
class QRScannerState {
  final String scannedCode;
  final bool isProcessing;
  final MobileScannerController scannerController;

  QRScannerState({
    required this.scannedCode,
    required this.isProcessing,
    required this.scannerController,
  });

  QRScannerState copyWith({
    String? scannedCode,
    bool? isProcessing,
    MobileScannerController? scannerController,
  }) {
    return QRScannerState(
      scannedCode: scannedCode ?? this.scannedCode,
      isProcessing: isProcessing ?? this.isProcessing,
      scannerController: scannerController ?? this.scannerController,
    );
  }
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
    if (code == null || code.isEmpty || state.isProcessing) return;

    state = state.copyWith(isProcessing: true, scannedCode: code);

    // Process QR code (could be device ID, pairing code, etc.)
    _processQRCode(code, context);
  }

  void _processQRCode(String code, BuildContext context) {
    // TODO: Implement QR code processing logic
    // Could be used for device pairing, configuration, etc.

    showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scanned successfully!'),
            const SizedBox(height: 8),
            Text(
              'Code: $code',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              state = state.copyWith(isProcessing: false);
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(code);
            },
            child: const Text('Use Code'),
          ),
        ],
      ),
    );
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

  Widget _buildScannerOverlay() {
    return Center(
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
  }

  Widget _buildCorner(bool top, bool left) {
    return Container(
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
  }

  Widget _buildInstructions() {
    return Positioned(
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
}
