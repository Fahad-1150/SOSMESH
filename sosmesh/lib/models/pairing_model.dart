class PairingModel {
  final String id;
  final String device1Id;
  final String device1Name;
  final String device2Id;
  final String device2Name;
  final DateTime pairingTime;
  final bool isActive;
  final String connectionType; // 'bluetooth' or 'wifi'

  PairingModel({
    required this.id,
    required this.device1Id,
    required this.device1Name,
    required this.device2Id,
    required this.device2Name,
    required this.pairingTime,
    this.isActive = true,
    required this.connectionType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device1Id': device1Id,
      'device1Name': device1Name,
      'device2Id': device2Id,
      'device2Name': device2Name,
      'pairingTime': pairingTime.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'connectionType': connectionType,
    };
  }

  factory PairingModel.fromMap(Map<String, dynamic> map) {
    return PairingModel(
      id: map['id'] as String,
      device1Id: map['device1Id'] as String,
      device1Name: map['device1Name'] as String,
      device2Id: map['device2Id'] as String,
      device2Name: map['device2Name'] as String,
      pairingTime: DateTime.parse(map['pairingTime'] as String),
      isActive: (map['isActive'] as int) == 1,
      connectionType: map['connectionType'] as String,
    );
  }
}
