/*
 * Copyright (C) 2025 ThinkingData
 */
package cn.thinkingdata.tdremoteconfig_flutter;

import android.content.Context;

import androidx.annotation.NonNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import cn.thinkingdata.remoteconfig.TDRemoteConfig;
import cn.thinkingdata.remoteconfig.TDRemoteConfigSettings;
import cn.thinkingdata.remoteconfig.core.TDObject;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * @author liulongbing
 * @since 2025/6/25
 */
public class TDRemoteConfigFlutterPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {

    private MethodChannel channel;
    private Context mContext;
    private EventChannel.EventSink eventSink;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        mContext = binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), "thinkingdata.cn/RemoteConfig");
        channel.setMethodCallHandler(this);
        EventChannel eventChannel = new EventChannel(binding.getBinaryMessenger(), "thinkingdata.cn/RemoteConfig/event");
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            if ("enableLog".equals(call.method)) {
                boolean enableLog = ( boolean ) call.arguments;
                TDRemoteConfig.enableLog(enableLog);
                result.success(null);
            } else if ("initWithConfig".equals(call.method)) {
                TDRemoteConfigSettings settings = new TDRemoteConfigSettings();
                settings.appId = call.argument("appId");
                settings.serverUrl = call.argument("serverUrl");
                Integer mode = call.argument("mode");
                if (mode != null && mode == 1) {
                    settings.mode = TDRemoteConfigSettings.TDRemoteConfigMode.DEBUG;
                }
                Map<String, Object> fetchParams = call.argument("customFetchParams");
                settings.setCustomFetchParams(extractJSONObject(fetchParams));
                TDRemoteConfig.init(mContext, settings);
                result.success(null);
            } else if ("setDefaultValues".equals(call.method)) {
                Map<String, Object> defaultValues = call.argument("defaultValues");
                String appId = call.argument("appId");
                TDRemoteConfig.setDefaultValues(extractJSONObject(defaultValues), appId);
                result.success(null);
            } else if ("setDefaultValuesWithFile".equals(call.method)) {
                String filePath = call.argument("filePath");
                String appId = call.argument("appId");
                TDRemoteConfig.setDefaultValues(filePath, appId);
                result.success(null);
            } else if ("clearDefaultValues".equals(call.method)) {
                String appId = call.argument("appId");
                TDRemoteConfig.clearDefaultValues(appId);
                result.success(null);
            } else if ("setCustomFetchParams".equals(call.method)) {
                Map<String, Object> fetchParams = call.argument("fetchParams");
                String appId = call.argument("appId");
                String templateCode = call.argument("templateCode");
                TDRemoteConfig.setCustomFetchParams(extractJSONObject(fetchParams), appId, templateCode);
                result.success(null);
            } else if ("fetch".equals(call.method)) {
                String appId = call.argument("appId");
                String templateCode = call.argument("templateCode");
                TDRemoteConfig.fetch(appId, templateCode);
                result.success(null);
            } else if ("removeCustomFetchParam".equals(call.method)) {
                String appId = call.argument("appId");
                String key = call.argument("key");
                String templateCode = call.argument("templateCode");
                TDRemoteConfig.removeCustomFetchParam(key, appId, templateCode);
                result.success(null);
            } else if ("addClientParams".equals(call.method)) {
                Map<String, Object> clientParams = call.argument("clientParams");
                TDRemoteConfig.addClientParams(extractJSONObject(clientParams));
                result.success(null);
            } else if ("getClientParams".equals(call.method)) {
                JSONObject clientParams = TDRemoteConfig.getClientParams();
                result.success(jsonToMap(clientParams));
            } else if ("removeClientParam".equals(call.method)) {
                String key = call.argument("key");
                TDRemoteConfig.removeClientParam(key);
                result.success(null);
            } else if ("accumulateNum".equals(call.method)) {
                String key = call.argument("key");
                Double num = call.argument("num");
                if (num != null) {
                    TDRemoteConfig.accumulateNum(key, num);
                }
                result.success(null);
            } else if ("getClientParamValueForKey".equals(call.method)) {
                String key = call.argument("key");
                result.success(TDRemoteConfig.getClientParamValueForKey(key));
            } else if ("getConfigValue".equals(call.method)) {
                String appId = call.argument("appId");
                String templateCode = call.argument("templateCode");
                List<Map<String, Object>> dataList = call.argument("dataList");
                String type = call.argument("type");
                if (dataList != null) {
                    TDObject tdObject = TDRemoteConfig.getData(appId, templateCode);
                    for (Map<String, Object> stringObjectMap : dataList) {
                        if (stringObjectMap == null) continue;
                        Object key = stringObjectMap.get("key");
                        Object defaultValue = stringObjectMap.get("defaultValue");
                        if (key instanceof String) {
                            tdObject = tdObject.get(( String ) key, defaultValue);
                        } else if (key instanceof Integer) {
                            tdObject = tdObject.get(( Integer ) key, defaultValue);
                        }
                    }
                    if ("string".equals(type)) {
                        result.success(tdObject.stringValue());
                        return;
                    } else if ("int".equals(type)) {
                        result.success(tdObject.longValue());
                        return;
                    } else if ("double".equals(type)) {
                        result.success(tdObject.doubleValue());
                        return;
                    } else if ("bool".equals(type)) {
                        result.success(tdObject.booleanValue());
                        return;
                    } else if ("object".equals(type)) {
                        result.success(jsonToMap(tdObject.objectValue()));
                        return;
                    } else if ("array".equals(type)) {
                        result.success(jsonToList(tdObject.arrayValue()));
                        return;
                    }
                }
                result.success(null);
            } else if ("addConfigFetchListener".equals(call.method)) {
                TDRemoteConfig.addConfigFetchListener(new TDRemoteConfig.OnConfigFetchListener() {
                    @Override
                    public void onFetchSuccess(JSONObject jsonObject) {
                        if (eventSink != null) {
                            eventSink.success(jsonToMap(jsonObject));
                        }
                    }
                });
                result.success(null);
            } else {
                result.notImplemented();
            }
        } catch (Exception ignore) {
        }
    }

    private JSONObject extractJSONObject(Map<String, Object> properties) throws JSONException {
        JSONObject jsonObject = new JSONObject();
        if (properties != null) {
            for (String key : properties.keySet()) {
                Object value = properties.get(key);
                if (value instanceof Map<?, ?>) {
                    value = extractJSONObject(( Map<String, Object> ) value);
                } else if (value instanceof List) {
                    //value = new JSONArray(value);
                    value = new JSONArray(( List ) value);
                }
                jsonObject.put(key, value);
            }
        }
        return jsonObject;
    }

    public static Map<String, Object> jsonToMap(JSONObject jsonObject) {
        Map<String, Object> map = new HashMap<>();
        if (jsonObject == null) return map;
        Iterator<String> keys = jsonObject.keys();

        while (keys.hasNext()) {
            String key = keys.next();
            Object value = jsonObject.opt(key);

            // 递归处理嵌套的 JSONObject
            if (value instanceof JSONObject) {
                value = jsonToMap(( JSONObject ) value);
            }
            // 递归处理嵌套的 JSONArray
            else if (value instanceof JSONArray) {
                value = jsonToList(( JSONArray ) value);
            }

            map.put(key, value);
        }
        return map;
    }

    private static List<Object> jsonToList(JSONArray jsonArray) {
        List<Object> list = new ArrayList<>();
        if (jsonArray == null) return list;
        for (int i = 0; i < jsonArray.length(); i++) {
            Object value = jsonArray.opt(i);

            // 递归处理嵌套的 JSONObject
            if (value instanceof JSONObject) {
                list.add(jsonToMap(( JSONObject ) value));
            }
            // 递归处理嵌套的 JSONArray
            else if (value instanceof JSONArray) {
                list.add(jsonToList(( JSONArray ) value));
            } else {
                list.add(value);
            }
        }
        return list;
    }

}
