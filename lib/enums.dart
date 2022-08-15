enum Preference { 
  initiated, 
  webViewUrl, 
  overrideUrl,
  isFinalLinkCachingEnabled,
  isOpenInBrowserEnabled,
  isFinalLinkCachedAlready,
}


enum FirebaseField { url1, url2 }

enum SdkKey {
  facebook, appsflyer, onesignal, appsflyer_app_id
}

enum ResponseField {
  url1,
  url2
}

enum CollectableFields {
  is_tablet,
  android_id,             // +
  deeplink,             // +
  fb_ref,             // +
  InstallReferrer,    // +
  is_fb,              // +
  af_siteid,          // +
  httpReferrer,       //  +
  media_source,       // +
  advertising_id,    // +  advertising_id? was ad_id
  adset_id,          // +
  // campaign_id,       // +
  // campaign,          // +
  appsflyer_id,      // +
  battery_level,      // +
  charging,           // +
  locale,             // +
  phone_model,        // +
  phone_brand,        // +
  vpn,                // +
  af_ad_id,           // +
  uuid,               // +

  af_adset_id,
  atributionId,
  adId, 
  adgroupId

}
