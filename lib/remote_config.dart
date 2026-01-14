import 'dart:core';

import 'package:flutter/services.dart';

enum TDRemoteConfigMode { NORMAL, DEBUG }

class TDRemoteConfigSettings {
  String? appId;
  String? serverUrl;
  TDRemoteConfigMode mode = TDRemoteConfigMode.NORMAL;
  Map<String, dynamic>? customFetchParams;
}

class TDObject {
  MethodChannel? _channel;
  String? appId;
  String? templateCode;
  List<Map<String, dynamic>> dataList = [];
  TDObject(MethodChannel? channel, String? a, String? b) {
    _channel = channel;
    appId = a;
    templateCode = b;
  }
  TDObject get(dynamic key, {dynamic defaultValue}) {
    if (key == null) return this;
    dataList.add({"key": key, "defaultValue": defaultValue});
    return this;
  }

  Future<String?> stringValue() async {
    return await _channel?.invokeMethod("getConfigValue", {
      "appId": appId,
      "templateCode": templateCode,
      "dataList": dataList,
      "type": "string"
    });
  }

  Future<int?> intValue() async {
    return await _channel?.invokeMethod("getConfigValue", {
      "appId": appId,
      "templateCode": templateCode,
      "dataList": dataList,
      "type": "int"
    });
  }

  Future<double?> doubleValue() async {
    return await _channel?.invokeMethod("getConfigValue", {
      "appId": appId,
      "templateCode": templateCode,
      "dataList": dataList,
      "type": "double"
    });
  }

  Future<bool?> boolValue() async {
    return await _channel?.invokeMethod("getConfigValue", {
      "appId": appId,
      "templateCode": templateCode,
      "dataList": dataList,
      "type": "bool"
    });
  }

  Future<Map<String, dynamic>?> objectValue() async {
    return await _channel?.invokeMapMethod("getConfigValue", {
      "appId": appId,
      "templateCode": templateCode,
      "dataList": dataList,
      "type": "object"
    });
  }

  Future<List<dynamic>?> arrayValue() async {
    return await _channel?.invokeListMethod("getConfigValue", {
      "appId": appId,
      "templateCode": templateCode,
      "dataList": dataList,
      "type": "array"
    });
  }
}

class TDRemoteConfig {
  static const _libVersion = "1.0.0";

  static const MethodChannel _channel =
      MethodChannel('thinkingdata.cn/RemoteConfig');

  static const EventChannel _eventChannel =
      EventChannel('thinkingdata.cn/RemoteConfig/event');

  static void enableLog(bool enableLog) {
    _channel.invokeMethod("enableLog", true);
  }

  static void init(String appId, String serverUrl) {
    TDRemoteConfigSettings settings = TDRemoteConfigSettings();
    settings.appId = appId;
    settings.serverUrl = serverUrl;
    initWithConfig(settings);
  }

  static void initWithConfig(TDRemoteConfigSettings settings) {
    Map<String, dynamic> config = <String, dynamic>{
      'appId': settings.appId,
      'serverUrl': settings.serverUrl,
      'mode': settings.mode == TDRemoteConfigMode.NORMAL ? 0 : 1,
      'customFetchParams': settings.customFetchParams
    };
    _channel.invokeMethod("initWithConfig", config);
  }

  static void setDefaultValues(Map<String, dynamic> params, {String? appId}) {
    _channel.invokeMethod(
        "setDefaultValues", {"defaultValues": params, "appId": appId});
  }

  static void setDefaultValuesWithFile(String filePath, {String? appId}) {
    _channel.invokeMethod(
        "setDefaultValuesWithFile", {"filePath": filePath, "appId": appId});
  }

  static void clearDefaultValues({String? appId}) {
    _channel.invokeMethod("clearDefaultValues", {"appId": appId});
  }

  static void setCustomFetchParams(Map<String, dynamic> params,
      {String? appId, String? templateCode}) {
    _channel.invokeMethod("setCustomFetchParams",
        {"fetchParams": params, "appId": appId, "templateCode": templateCode});
  }

  static void removeCustomFetchParam(String key,
      {String? appId, String? templateCode}) {
    _channel.invokeMethod("removeCustomFetchParam",
        {"key": key, "appId": appId, "templateCode": templateCode});
  }

  static TDObject getData({String? appId, String? templateCode}) {
    return TDObject(_channel, appId, templateCode);
  }

  static void fetch({String? appId, String? templateCode}) {
    _channel
        .invokeMethod("fetch", {"appId": appId, "templateCode": templateCode});
  }

  static dynamic _convertDynamic(dynamic value) {
    if (value is Map) {
      return {
        for (var entry in value.entries)
          entry.key.toString(): _convertDynamic(entry.value)
      };
    } else if (value is List) {
      return value.map((e) => _convertDynamic(e)).toList();
    }
    return value;
  }

  static void addConfigFetchListener(
      void Function(Map<String, dynamic> statusData) f) {
    _channel.invokeMethod("addConfigFetchListener");
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final Map<String, dynamic> convertedMap = _convertDynamic(event);
        f(convertedMap);
      }
    });
  }

  static String getSDKVersion() {
    return _libVersion;
  }

  static void addClientParams(Map<String, dynamic> params) {
    _channel.invokeMethod("addClientParams", {"clientParams": params});
  }

  static void removeClientParam(String key) {
    _channel.invokeMethod("removeClientParam", {"key": key});
  }

  static void accumulateNum(String key, double num) {
    _channel.invokeMethod("accumulateNum", {"key": key, "num": num});
  }

  static Future<dynamic>? getClientParamValueForKey(String key) async {
    return await _channel
        .invokeMethod("getClientParamValueForKey", {"key": key});
  }

  static Future<Map<String, dynamic>?> getClientParams() async {
    return await _channel.invokeMapMethod("getClientParams");
  }
}
