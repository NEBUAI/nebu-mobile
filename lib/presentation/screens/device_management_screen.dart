import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('device_management.title'.tr()),
      ),
      body: Center(
        child: Text('device_management.coming_soon'.tr()),
      ),
    );
}
