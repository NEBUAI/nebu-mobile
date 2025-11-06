import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';

class QRScannerController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController(
    
  );

  final scannedCode = ''.obs;
  final isProcessing = false.obs;

  void handleQRCode(String? code) {
    if (code == null || code.isEmpty || isProcessing.value) return;

    isProcessing.value = true;
    scannedCode.value = code;

    // Process QR code (could be device ID, pairing code, etc.)
    _processQRCode(code);
  }

  void _processQRCode(String code) {
    // TODO: Implement QR code processing logic
    // Could be used for device pairing, configuration, etc.

    Get.dialog<void>(
      AlertDialog(
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
              Get.back<void>();
              isProcessing.value = false;
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back<void>();
              Get.back<void>(result: code);
            },
            child: const Text('Use Code'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}

class QRScannerScreen extends StatelessWidget {
  QRScannerScreen({super.key});

  final QRScannerController controller = Get.put(QRScannerController());

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('qr_scanner.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: controller.scannerController.switchCamera,
          ),
          IconButton(
            icon: Obx(
              () => Icon(
                controller.scannerController.torchEnabled
                    ? Icons.flash_on
                    : Icons.flash_off,
              ),
            ),
            onPressed: controller.scannerController.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller.scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                controller.handleQRCode(barcode.rawValue);
              }
            },
          ),
          _buildScannerOverlay(),
          _buildInstructions(),
        ],
      ),
    );

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
