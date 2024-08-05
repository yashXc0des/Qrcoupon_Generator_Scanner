class Coupon {
  final String serialNumber;
  final String uniqueID;
  final DateTime validity;
  final bool claimed;

  Coupon({
    required this.serialNumber,
    required this.uniqueID,
    required this.validity,
    required this.claimed,
  });

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'uniqueID': uniqueID,
      'validity': validity.toIso8601String(),
      'claimed': claimed,
    };
  }

  static Coupon fromMap(Map<String, dynamic> map) {
    return Coupon(
      serialNumber: map['serialNumber'],
      uniqueID: map['uniqueID'],
      validity: DateTime.parse(map['validity']),
      claimed: map['claimed'],
    );
  }
}
