class NotificationManager {
  // Privat konstruktor
  NotificationManager._privateConstructor();

  // Singleton-instans
  static final NotificationManager _instance = NotificationManager._privateConstructor();

  // Publik getter för att komma åt instansen
  static NotificationManager get instance => _instance;

  // Variabel för att hålla reda på om det finns olästa notiser
  bool _hasUnreadNotifications = false;

  // Getter för att få värdet på _hasUnreadNotifications
  bool get hasUnreadNotifications => _hasUnreadNotifications;

  // Setter för att sätta värdet på _hasUnreadNotifications
  set hasUnreadNotifications(bool value) {
    _hasUnreadNotifications = value;
  }
}
