class DeviceConfig {
  final AlertConfig alertConfig;
  final bool countReverseFlowToTotalizer;
  final LastDeviceTxRxInfo lastDeviceTxRxInfo;
  final LastLNSData lastLNSData;
  final LoRaWANInfo loRaWANInfo;

  DeviceConfig({
    required this.alertConfig,
    required this.countReverseFlowToTotalizer,
    required this.lastDeviceTxRxInfo,
    required this.lastLNSData,
    required this.loRaWANInfo,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> json) {
    return DeviceConfig(
      alertConfig: AlertConfig.fromJson(json['Alert Config']),
      countReverseFlowToTotalizer: json['Count Reverse Flow to Totalizer'],
      lastDeviceTxRxInfo:
          LastDeviceTxRxInfo.fromJson(json['Last Device TxRx Info']),
      lastLNSData: LastLNSData.fromJson(json['Last LNS Data']),
      loRaWANInfo: LoRaWANInfo.fromJson(json['LoRaWAN Info']),
    );
  }
}

class AlertConfig {
  final int alertMask;
  final int burstFlowThresPer;
  final int emptyPipeThresPer;
  final List<int> leakFlowThres;
  final int noConsumptionThresPer;
  final List<int> normalFlowThres;
  final int reverseFlowThresPer;
  final int startFlowThresVal;

  AlertConfig({
    required this.alertMask,
    required this.burstFlowThresPer,
    required this.emptyPipeThresPer,
    required this.leakFlowThres,
    required this.noConsumptionThresPer,
    required this.normalFlowThres,
    required this.reverseFlowThresPer,
    required this.startFlowThresVal,
  });

  factory AlertConfig.fromJson(Map<String, dynamic> json) {
    return AlertConfig(
      alertMask: json['Alert Mask'],
      burstFlowThresPer: json['Burst Flow Thres Per'],
      emptyPipeThresPer: json['Empty Pipe Thres Per'],
      leakFlowThres: List<int>.from(json['Leak Flow Thres']),
      noConsumptionThresPer: json['No Consumption Thres Per'],
      normalFlowThres: List<int>.from(json['Normal Flow Thres']),
      reverseFlowThresPer: json['Reverse Flow Thres Per'],
      startFlowThresVal: json['Start Flow Thres Val'],
    );
  }
}

class LastDeviceTxRxInfo {
  final int currentDataRate;
  final String rxFrequency;
  final int rxRSSI;
  final int rxSNR;
  final int txChannel;
  final int txPower;
  final String txTime;

  LastDeviceTxRxInfo({
    required this.currentDataRate,
    required this.rxFrequency,
    required this.rxRSSI,
    required this.rxSNR,
    required this.txChannel,
    required this.txPower,
    required this.txTime,
  });

  factory LastDeviceTxRxInfo.fromJson(Map<String, dynamic> json) {
    return LastDeviceTxRxInfo(
      currentDataRate: json['Current DataRate'],
      rxFrequency: json['Rx Frequency'],
      rxRSSI: json['Rx RSSI'],
      rxSNR: json['Rx SNR'],
      txChannel: json['Tx Channel'],
      txPower: json['Tx Power'],
      txTime: json['Tx Time'],
    );
  }
}

class LastLNSData {
  final List<Gateway> gateways;
  final int uplinkDataRate;
  final String uplinkFrequency;
  final int uplinkPort;
  final String uplinkTime;

  LastLNSData({
    required this.gateways,
    required this.uplinkDataRate,
    required this.uplinkFrequency,
    required this.uplinkPort,
    required this.uplinkTime,
  });

  factory LastLNSData.fromJson(Map<String, dynamic> json) {
    return LastLNSData(
      gateways:
          List<Gateway>.from(json['Gateways'].map((x) => Gateway.fromJson(x))),
      uplinkDataRate: json['Uplink DataRate'],
      uplinkFrequency: json['Uplink Frequency'],
      uplinkPort: json['Uplink Port'],
      uplinkTime: json['Uplink Time'],
    );
  }
}

class Gateway {
  final String id;
  final int rssi;
  final double snr;

  Gateway({
    required this.id,
    required this.rssi,
    required this.snr,
  });

  factory Gateway.fromJson(Map<String, dynamic> json) {
    return Gateway(
      id: json['Id'],
      rssi: json['RSSI'],
      snr: json['SNR'],
    );
  }
}

class LoRaWANInfo {
  final String appKey;
  final String devAddress;
  final String devEUI;
  final int devNonce;
  final bool isJoined;
  final String joinEUI;
  final int joinNonce;
  final String lmVersion;
  final String netID;
  final String nwkKey;

  LoRaWANInfo({
    required this.appKey,
    required this.devAddress,
    required this.devEUI,
    required this.devNonce,
    required this.isJoined,
    required this.joinEUI,
    required this.joinNonce,
    required this.lmVersion,
    required this.netID,
    required this.nwkKey,
  });

  factory LoRaWANInfo.fromJson(Map<String, dynamic> json) {
    return LoRaWANInfo(
      appKey: json['App Key'],
      devAddress: json['Dev Address'],
      devEUI: json['Dev EUI'],
      devNonce: json['Dev Nonce'],
      isJoined: json['Is Joined'],
      joinEUI: json['Join EUI'],
      joinNonce: json['Join Nonce'],
      lmVersion: json['LM Version'],
      netID: json['Net ID'],
      nwkKey: json['Nwk Key'],
    );
  }
}
