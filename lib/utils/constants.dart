class ApiConstants {
  static const String networkIp =
      "http://192.168.1.2:3050/api"; // for testing on physical device - needs network ip not localhost

  static const bool useNetworkIp = true;
  static String get apiUrl => useNetworkIp ? networkIp : baseUrl;
  static const String baseUrl = 'http://10.0.2.2:3050/api';

  // temp hardcode sessionId
  static const String sessionId = "zSWMPbpbr3Yre5R4z2hI";
  // static const String sessionId = "eM4zvPgXFi0goK1XNnvq";

  // Toggle this to switch between mock and real data
  static const bool useMockData = false;
}
