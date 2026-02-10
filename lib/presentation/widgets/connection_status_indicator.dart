import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({
    required this.phase,
    required this.isRemoteConnected,
    this.remoteName,
    super.key,
  });

  final String phase;
  final bool isRemoteConnected;
  final String? remoteName;

  @override
  Widget build(BuildContext context) {
    final (Color dotColor, String statusText) = switch (phase) {
      'connected' => (Colors.green, 'walkie_talkie.connected'.tr()),
      'connecting' => (Colors.orange, 'walkie_talkie.connecting'.tr()),
      'error' => (Colors.red, 'walkie_talkie.error'.tr()),
      _ => (Colors.grey, 'walkie_talkie.disconnected'.tr()),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: dotColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isRemoteConnected
              ? 'walkie_talkie.toy_connected'.tr()
              : 'walkie_talkie.waiting_for_toy'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
