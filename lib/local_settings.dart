import 'package:shared_preferences/shared_preferences.dart';

import 'enums.dart';

extension on Enum {
  String asString() {
    return toString().split('.').last;
  }
}

class LocalSettings {
  static LocalSettings? _instance;
  SharedPreferences? _preferences;

  LocalSettings._create() {}

  Future<void> _init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future<LocalSettings> create() async {
    if (_instance == null) {
      _instance = LocalSettings._create();
      await _instance?._init();
    }
    return _instance!;
  }

  bool isInitiated() {
    return _preferences!.getBool(Preference.initiated.asString()) ?? false;
  }

  bool isOverrideUrl() {
    return _preferences!.getBool(Preference.overrideUrl.asString()) ?? false;
  }

  String getWebViewUrl() {
    return _preferences!.getString(Preference.webViewUrl.asString()) ?? '';
  }

  bool isFinalLinkCachingEnabled() {
    return _preferences!.getBool(Preference.isFinalLinkCachingEnabled.asString()) ?? false;
  }

  bool isFinalLinkCachedAlready() {
    return _preferences!.getBool(Preference.isFinalLinkCachedAlready.asString()) ?? false;
  }


  bool isOpenInBrowserEnabled() {
    return _preferences!.getBool(Preference.isOpenInBrowserEnabled.asString()) ?? false;
  }

  void setFinalLinkCachingEnabled() {
    _preferences!.setBool(Preference.isFinalLinkCachingEnabled.asString(), true);
  }

    void setFinalLinkCachedAlready() {
    _preferences!.setBool(Preference.isFinalLinkCachedAlready.asString(), true);
  }

  void setOpenInBrowserEnabled() {
    _preferences!.setBool(Preference.isOpenInBrowserEnabled.asString(), true);
  }

  void setInitiated() {
    _preferences!.setBool(Preference.initiated.asString(), true);
  }

  void setOverrideUrl() {
    _preferences!.setBool(Preference.overrideUrl.asString(), true);
  }

  void setWebViewUrl(String url) {
    _preferences!.setString(Preference.webViewUrl.asString(), url);
  }
}