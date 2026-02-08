class BleConstants {
  BleConstants._();

  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const String batteryServiceUuid =
      '0000180f-0000-1000-8000-00805f9b34fb';
  static const String batteryLevelCharUuid =
      '00002a19-0000-1000-8000-00805f9b34fb';
  static const String esp32WifiServiceUuid =
      '0000bc9a-7856-3412-3412-341278563412';
  static const String esp32SsidCharUuid =
      '0000bd9a-7856-3412-3412-341278563412';
  static const String esp32PasswordCharUuid =
      '0000be9a-7856-3412-3412-341278563412';
  static const String esp32StatusCharUuid =
      '0000bf9a-7856-3412-3412-341278563412';
  static const String esp32DeviceIdCharUuid =
      '0000c09a-7856-3412-3412-341278563412';
  static const String esp32VolumeCharUuid =
      '0000c19a-7856-3412-3412-341278563412';
  static const String esp32MuteCharUuid =
      '0000c29a-7856-3412-3412-341278563412';
}
