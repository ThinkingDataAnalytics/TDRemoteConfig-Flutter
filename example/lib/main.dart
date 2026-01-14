import 'package:flutter/material.dart';
import 'dart:async';
import 'package:thinking_analytics/td_analytics.dart';
import 'package:td_remote_config/remote_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const appId = "a3a3493ebff5474a98e9f98c56edd54f";
const serverUrl = "http://10.82.3.185:8991";

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: CustomScrollView(shrinkWrap: true, slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(2.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '初始化',
                                style: TextStyle(fontSize: 14),
                              ),
                              onPressed: () => {initSDK()})),
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '设置默认值',
                                style: TextStyle(fontSize: 14),
                              ),
                              onPressed: () => {setDefaultValues()})),
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '设置文件默认值',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () => {setDefaultValuesWithFile()})),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '清除默认值',
                                style: TextStyle(fontSize: 14),
                              ),
                              onPressed: () => {clearDefaultValues()})),
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '设置请求参数',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () => {setCustomFetchParams()})),
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '拉取配置',
                                style: TextStyle(fontSize: 14),
                              ),
                              onPressed: () => {fetch()})),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '清除请求参数',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () => {removeFetchParams()})),
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '设置客户端参数',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () => {addClientParams()})),
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '获取客户端参数',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () => {getClientParams()})),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '清除客户端参数',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () => {removeClientParam()})),
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '累加客户端参数',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () => {accumulateNum()})),
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '获取单个客户端参数',
                                style: TextStyle(fontSize: 8),
                              ),
                              onPressed: () => {getClientParamValueForKey()})),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: OutlinedButton(
                              child: const Text(
                                '获取远程配置',
                                style: TextStyle(fontSize: 10),
                              ),
                              onPressed: () => {getRemoteData()})),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void initSDK() async {
    TDAnalytics.enableLog(true);
    TDRemoteConfig.enableLog(true);
    TDAnalytics.init(appId, serverUrl);
    TDRemoteConfigSettings settings = TDRemoteConfigSettings();
    settings.appId = appId;
    settings.serverUrl = serverUrl;
    // settings.mode = TDRemoteConfigMode.DEBUG;
    settings.customFetchParams = {"name": "jack", "age": 10};
    TDRemoteConfig.initWithConfig(settings);
    TDRemoteConfig.addConfigFetchListener((statusData) {
      print(statusData);
    });
  }

  void setDefaultValues() {
    TDRemoteConfig.setDefaultValues({
      "df_name": "jen",
      "df_age": 100,
      "df_aa": 1.89,
      "df_bb": true,
      "df_obj": {
        "name": "jjj",
        "ddd": 123,
        "obj": {"name": "jjj", "ddd": 123}
      },
      "df_array": ["aaa", 1.3, "bb"],
      "df_list": [
        {
          "name": "jjj",
          "ddd": 123,
          "obj": {"name": "jjj", "ddd": 123}
        },
        {
          "name": "kk",
          "ddd": 4444,
          "obj": {"name": "kk", "ddd": 456}
        }
      ]
    });
  }

  void setDefaultValuesWithFile() {
    TDRemoteConfig.setDefaultValuesWithFile("aaa");
  }

  void clearDefaultValues() {
    TDRemoteConfig.clearDefaultValues();
  }

  void setCustomFetchParams() {
    TDRemoteConfig.setCustomFetchParams({"fetch_aa": "abc", "fetch_bb": 100});
  }

  void fetch() {
    TDRemoteConfig.fetch();
  }

  void removeFetchParams() {
    TDRemoteConfig.removeCustomFetchParam("fetch_aa");
  }

  void addClientParams() {
    TDRemoteConfig.addClientParams({"client_cc": "cbc", "client_dd": 20});
  }

  void getClientParams() async {
    Map<String, dynamic>? params = await TDRemoteConfig.getClientParams();
    print(params);
  }

  void removeClientParam() {
    TDRemoteConfig.removeClientParam("client_cc");
  }

  void accumulateNum() {
    TDRemoteConfig.accumulateNum("client_dd", 10);
  }

  void getClientParamValueForKey() async {
    dynamic value = await TDRemoteConfig.getClientParamValueForKey("client_cc");
    print(value);
  }

  void getRemoteData() async {
    // Map<String, dynamic>? v = await TDRemoteConfig.getData()
    //     .get("configId_53827")
    //     .get("template_53827")
    //     .get(0)
    //     .get("config")
    //     .get("city01")
    //     .get("customParams")
    //     .objectValue();
    List<dynamic>? v =
        await TDRemoteConfig.getData().get("df_list").arrayValue();
    print(v);
  }
}
