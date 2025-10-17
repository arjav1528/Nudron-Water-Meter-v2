import 'dart:typed_data';

class DeviceInfo {
  int version;
  int deviceId;
  String claimCode;
  String deviceModel;
  int deviceTemp;
  String lorawanRegion;
  String batteryLevel;

  DeviceInfo({
    required this.version,
    required this.deviceId,
    required this.claimCode,
    required this.deviceModel,
    required this.deviceTemp,
    required this.lorawanRegion,
    required this.batteryLevel,
  });

  Map<String, dynamic> toJson() => {
        'Battery Level': batteryLevel,
        'Claim Code': claimCode,
        'Device ID': deviceId,
        'Device Model': deviceModel,
        'Device Temp': deviceTemp,
        'LoRaWAN Region': lorawanRegion,
        'Version': version,
      };
}

class CurrentMetrics {
  double totalUsage;
  double forwardUsage;
  double reverseUsage;
  int alerts;
  int status;
  int currentRecordIndex;

  CurrentMetrics({
    required this.totalUsage,
    required this.forwardUsage,
    required this.reverseUsage,
    required this.alerts,
    required this.status,
    required this.currentRecordIndex,
  });

  Map<String, dynamic> toJson() => {
        'Alerts': alerts,
        'Forward Usage': forwardUsage,
        'Reverse Usage': reverseUsage,
        'Status': status,
        'Total Usage': totalUsage,
        'Current Record Index': currentRecordIndex,
      };
}

class TimeSettings {
  String deviceTime;
  int recordFreqCode;
  int recordPeriod;
  bool reqTimeUpdate;
  String timeZone;

  TimeSettings({
    required this.deviceTime,
    required this.recordFreqCode,
    required this.recordPeriod,
    required this.reqTimeUpdate,
    required this.timeZone,
  });

  Map<String, dynamic> toJson() => {
        'Device Time': deviceTime,
        'Record Freq Code': recordFreqCode,
        'Record Period': recordPeriod,
        'Req Time Update': reqTimeUpdate,
        'Time Zone': timeZone,
      };
}

class DeviceData {
  DeviceInfo deviceInfo;
  CurrentMetrics currentMetrics;
  List<UsagePacket> previousRecords;
  bool testModeStatus;
  TimeSettings timeSettings;

  DeviceData({
    required this.deviceInfo,
    required this.currentMetrics,
    required this.previousRecords,
    required this.testModeStatus,
    required this.timeSettings,
  });

  Map<String, dynamic> toJson() => {
        'Current Metrics': currentMetrics.toJson(),
        'Device Info': deviceInfo.toJson(),
        'Previous Records': previousRecords.map((e) => e.toJson()).toList(),
        'Test Mode Status': testModeStatus,
        'Time Settings': timeSettings.toJson(),
      };
}

class UsagePacket {
  String timestamp;
  int alerts;
  int status;
  int totalizer;
  List<int> intraDay;

  UsagePacket({
    required this.timestamp,
    required this.alerts,
    required this.status,
    required this.totalizer,
    this.intraDay = const [],
  });

  Map<String, dynamic> toJson() => {
        'Timestamp': timestamp,
        'Alerts': alerts,
        'Status': status,
        'Totalizer': totalizer,
        if (intraDay.isNotEmpty) 'IntraDay': intraDay,
      };
}

class Alerts {
  bool airBubbles;
  bool noConsumption;
  bool reverseFlow;
  bool leakFlow;
  bool contiFlow;
  bool burstPipe;
  bool maxFlow;
  bool freeze;

  Alerts({
    this.airBubbles = false,
    this.noConsumption = false,
    this.reverseFlow = false,
    this.leakFlow = false,
    this.contiFlow = false,
    this.burstPipe = false,
    this.maxFlow = false,
    this.freeze = false,
  });
}

class Status {
  bool badTemp;
  bool lowBat;
  bool motion;

  Status({this.badTemp = false, this.lowBat = false, this.motion = false});
}

class DeviceReadPacket1 {
  int version;
  Uint8List devId;
  Uint8List claimCode;
  int tzOffset;
  int meterModel;
  int testingMode;
  int lastUsageL;
  int lastUsageMl;
  int usageL;
  int usageMl;
  int forwardUsageL;
  int forwardUsageMl;
  int reverseUsageL;
  int reverseUsageMl;
  int dummy;
  int alert;
  Uint8List status;
  int isTsInit;
  int tsUpdateBool;
  int dummy2;
  int dummy3;
  int batMV;
  int tempC;
  int time;
  int regionCode;
  int recordFreqCode;
  int recordFreq;
  int calc1;
  int dummy4;
  int dummy5;
  int curRecordIndex;

  DeviceReadPacket1({
    required this.version,
    required this.devId,
    required this.claimCode,
    required this.tzOffset,
    required this.meterModel,
    required this.testingMode,
    required this.lastUsageL,
    required this.lastUsageMl,
    required this.usageL,
    required this.usageMl,
    required this.forwardUsageL,
    required this.forwardUsageMl,
    required this.calc1,
    required this.reverseUsageL,
    required this.reverseUsageMl,
    required this.dummy,
    required this.alert,
    required this.status,
    required this.isTsInit,
    required this.tsUpdateBool,
    required this.batMV,
    required this.tempC,
    required this.time,
    required this.regionCode,
    required this.recordFreqCode,
    required this.recordFreq,
    required this.dummy2,
    required this.dummy3,
    required this.curRecordIndex,
    required this.dummy4,
    required this.dummy5,
  });
}
