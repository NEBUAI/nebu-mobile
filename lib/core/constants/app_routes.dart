enum AppRoutes {
  splash('/'),
  welcome('/welcome'),
  login('/login'),
  signUp('/signup'),
  home('/home'),
  profile('/profile'),
  activityLog('/activity-log'),
  myToys('/my-toys'),
  deviceManagement('/device-management'),
  iotDevices('/iot-devices'),
  qrScanner('/qr-scanner'),
  editProfile('/edit-profile'),
  toySettings('/toy-settings'),
  notifications('/notifications'),
  privacySettings('/privacy-settings'),
  helpSupport('/help-support'),
  orders('/orders'),
  connectionSetup('/setup/connection'),
  toyNameSetup('/setup/toy-name'),
  wifiSetup('/setup/wifi'),
  ageSetup('/setup/age'),
  personalitySetup('/setup/personality'),
  voiceSetup('/setup/voice'),
  favoritesSetup('/setup/favorites'),
  worldInfoSetup('/setup/world-info'),
  localChildSetup('/setup/local-child');

  const AppRoutes(this.path);
  final String path;
}
