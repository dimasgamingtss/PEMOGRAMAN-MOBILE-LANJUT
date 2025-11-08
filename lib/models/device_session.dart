class DeviceSession {
  final String deviceId;
  final String deviceName;
  final DateTime loginTime;
  final String? ipAddress;

  DeviceSession({
    required this.deviceId,
    required this.deviceName,
    required this.loginTime,
    this.ipAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'loginTime': loginTime.toIso8601String(),
      'ipAddress': ipAddress,
    };
  }

  factory DeviceSession.fromJson(Map<String, dynamic> json) {
    return DeviceSession(
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      loginTime: DateTime.parse(json['loginTime']),
      ipAddress: json['ipAddress'],
    );
  }
}

