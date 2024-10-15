class ConnectivityService {
  static connectionStatusServises(connectionStatus) {
    String value;
    int number;
    switch (connectionStatus) {
      case 'ConnectivityResult.wifi':
        value = 'Connected to WiFi';
        number = 3;
        break;
      case 'ConnectivityResult.mobile':
        value = 'Connected to Mobile Network';
        number = 2;
        break;
      case 'ConnectivityResult.none':
        value = 'No internet connection';
        number = 1;
        break;
      default:
        value = 'Unknown';
        number = 0;
        break;
    }
    return [{'msj': value, 'status': number}];
  }
}