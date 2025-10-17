import 'package:flutter/foundation.dart';

class Session {
  final String clientID;
  final String deviceInfo;
  final String location;
  final DateTime lastRefresh;

  Session({
    required this.clientID,
    required this.deviceInfo,
    required this.location,
    required this.lastRefresh,
  });

  factory Session.fromJson(Map<dynamic, dynamic> json) {
    return Session(
        clientID: json["clientID"] ?? '',
        deviceInfo: json["deviceInfo"] ?? '',
        location: json["location"] ?? json['ip']??'Unknown',
        lastRefresh: DateTime.fromMillisecondsSinceEpoch(json["lastRefresh"]));
  }
}

class UserInfo {
  final String id;
  final String name;
  final String email;
  final bool emailVerified;
  final String phone;
  final bool phoneVerified;

  const UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerified,
    required this.phone,
    required this.phoneVerified,
  });

  factory UserInfo.fromJson(Map<dynamic, dynamic> json) {
    return UserInfo(
        email: json["email"] ?? '',
        id: json["userID"] ?? '',
        name: json["name"] ?? "",
        emailVerified: json["emailVerified"] ?? false,
        phone: json["phone"] ?? '91',
        phoneVerified: json["phoneVerified"] ?? false);
  }

  printClass() {
    if (kDebugMode) {
      print(
          'UserInfo: id: $id, name: $name, email: $email, emailVerified: $emailVerified, phone: $phone, phoneVerified: $phoneVerified');
    }
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
      'phone': phone,
      'phoneVerified': phoneVerified,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        emailVerified,
        phone,
        phoneVerified,
      ];
}
