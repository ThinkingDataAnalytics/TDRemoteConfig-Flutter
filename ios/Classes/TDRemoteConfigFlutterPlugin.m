#import "TDRemoteConfigFlutterPlugin.h"
#import <TDRemoteConfig/TDRemoteConfig.h>

@interface TDRemoteConfigReceiver : NSObject
+ (void)setEventSink:(FlutterEventSink)eventSink;
@end

@implementation TDRemoteConfigReceiver

static FlutterEventSink sEventSink = nil;

+ (void)setEventSink:(FlutterEventSink)eventSink {
    sEventSink = [eventSink copy];
}

+ (void)fun:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo[kTDRemoteConfigStrategyStatusMap];
    if (!info) {
        info = @{}; // 设置一个空字典作为默认值
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if(sEventSink){
            sEventSink(info);
        }
    });
}

@end

@implementation TDRemoteConfigFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"thinkingdata.cn/RemoteConfig"
            binaryMessenger:[registrar messenger]];
  TDRemoteConfigFlutterPlugin* instance = [[TDRemoteConfigFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* eventChannel = [FlutterEventChannel
                                             eventChannelWithName:@"thinkingdata.cn/RemoteConfig/event"
                                             binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"enableLog" isEqualToString:call.method]) {
      bool enableLog = call.arguments;
      [TDRemoteConfig enableLog:enableLog];
      result(nil);
  }else if([@"initWithConfig" isEqualToString:call.method]){
      TDRemoteConfigSettings *settings = [[TDRemoteConfigSettings alloc]init];
      settings.appId = call.arguments[@"appId"];
      settings.serverUrl = call.arguments[@"serverUrl"];
      NSNumber *modeNumber = call.arguments[@"mode"];
      if(modeNumber && modeNumber.intValue == 1){
          settings.mode = TDRemoteConfigModeDebug;
      }
      settings.fetchParams = call.arguments[@"customFetchParams"];
      [TDRemoteConfig startWithSettings:settings];
      result(nil);
  }else if([@"setDefaultValues" isEqualToString:call.method]){
      [TDRemoteConfig setDefaultValues:call.arguments[@"defaultValues"] appId:call.arguments[@"appId"]];
      result(nil);
  }else if([@"setDefaultValuesWithFile" isEqualToString:call.method]){
      [TDRemoteConfig setDefaultValuesWithJsonFile:call.arguments[@"defaultValues"] appId:call.arguments[@"appId"]];
      result(nil);
  }else if([@"clearDefaultValues" isEqualToString:call.method]){
      [TDRemoteConfig clearDefaultValuesWithAppId:call.arguments[@"appId"]];
      result(nil);
  }else if([@"setCustomFetchParams" isEqualToString:call.method]){
      [TDRemoteConfig setCustomFetchParams:call.arguments[@"fetchParams"] appId:call.arguments[@"appId"]];
      result(nil);
  }else if([@"fetch" isEqualToString:call.method]){
      [TDRemoteConfig fetchWithAppId:call.arguments[@"appId"]];
      result(nil);
  }else if([@"removeCustomFetchParam" isEqualToString:call.method]){
      [TDRemoteConfig removeCustomFetchParam:call.arguments[@"key"] appId:call.arguments[@"appId"]];
      result(nil);
  }else if([@"addClientParams" isEqualToString:call.method]){
      [TDRemoteConfig addClientParams:call.arguments[@"clientParams"]];
      result(nil);
  }else if([@"getClientParams" isEqualToString:call.method]){
      NSDictionary *clientParams = [TDRemoteConfig getClientParams];
      result(clientParams);
  }else if([@"removeClientParam" isEqualToString:call.method]){
      [TDRemoteConfig removeClientParam:call.arguments[@"key"]];
      result(nil);
  }else if([@"accumulateNum" isEqualToString:call.method]){
      [TDRemoteConfig accumulateNum:call.arguments[@"num"] toClientParamKey:call.arguments[@"key"]];
      result(nil);
  }else if([@"getClientParamValueForKey" isEqualToString:call.method]){
      result([TDRemoteConfig getClientParamValueForKey:call.arguments[@"key"]]);
  }else if([@"getConfigValue" isEqualToString:call.method]){
      NSString *appId = call.arguments[@"appId"];
      NSArray<NSDictionary *> *dataList = call.arguments[@"dataList"];
      NSString *type = call.arguments[@"type"];
      if(dataList){
          TDObject *tdObject = [TDRemoteConfig getDataWithAppId:appId];
          for (NSDictionary *item in dataList) {
              if(!item) continue;
              id key = item[@"key"];
              id defaultValue = item[@"defaultValue"];
              if ([key isKindOfClass:[NSString class]]) {
                  tdObject = tdObject.getWithDefault((NSString *)key,defaultValue);
              } else if ([key isKindOfClass:[NSNumber class]]) {
                  NSNumber *num = (NSNumber *)key;
                  tdObject = tdObject[num.intValue];
              }
          }
          if ([@"string" isEqualToString:type]) {
              result([tdObject stringValue]);
              return;
          } else if ([@"int" isEqualToString:type]) {
              result([tdObject longNumber]);
              return;
          }else if ([@"double" isEqualToString:type]) {
              result([tdObject doubleNumber]);
              return;
          }else if ([@"bool" isEqualToString:type]) {
              NSNumber *numberValue = [tdObject numberValue];
              if (numberValue) {
                  result(numberValue);
              }
              result(@NO);
              return;
          }else if ([@"object" isEqualToString:type]) {
              result([tdObject objectValue]);
              return;
          }else if ([@"array" isEqualToString:type]) {
              result([tdObject arrayValue]);
              return;
          }
      }
      result(nil);
  }
  else if([@"addConfigFetchListener" isEqualToString:call.method]){
      [[NSNotificationCenter defaultCenter] addObserver:TDRemoteConfigReceiver.class selector:@selector(fun:) name:kTDRemoteConfigFetchDataSuccess object:nil];
      result(nil);
  }else {
    result(FlutterMethodNotImplemented);
  }
}
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(FlutterEventSink)events {
    [TDRemoteConfigReceiver setEventSink:events];
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    [TDRemoteConfigReceiver setEventSink:nil];
    return nil;
}

@end
