import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../local_settings.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String userAgent;
  
  const WebViewPage({Key? key, required this.url, required this.userAgent}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WebViewPageState();
  }
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? _webController;
  
  String? webViewUrl;
  
  String? ua;

  bool? timePassed;
  
  late LocalSettings localSettings;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    initSettings();
    _enableRotation();
    webViewUrl = widget.url;
    ua = widget.userAgent;
  }

  Future<void> initSettings() async {
    localSettings = await LocalSettings.create();
  }

  @override
  Widget build(BuildContext context) {

    print("AAA build webview $ua");

    return WillPopScope(
      onWillPop: () async {
        if ((await _webController?.canGoBack()) ?? false) {
          await _webController?.goBack();
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(flex: 10, child: 
                WebView(
                  gestureNavigationEnabled: true,
                  initialUrl: webViewUrl,
		              //userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 11_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1",
		              userAgent: ua,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (con) {
                    print("AAA creation completed url is ${webViewUrl}");
                    _webController = con;
                  },
                  onPageStarted: (String url) {
                      print("AAA on page loading started $url");
                  },
                  onPageFinished: (String url) {
                    print("AAA on page loading finished $url");
                    if(localSettings.isFinalLinkCachingEnabled() && !localSettings.isFinalLinkCachedAlready()) {
                      print("AAA caching final url $url");
                      localSettings.setWebViewUrl(url);
                      localSettings.setFinalLinkCachedAlready();
                    }
                    
                  },
                  onProgress: (int progress) {
                    print('AAA WebView is loading (progress : $progress%)');
                  },
                ),
              ),
              Expanded(child:
                Container(color: Colors.white, child: Row(children: [
                  Spacer(),

                  InkWell(onTap: () async {
                   var canGoBack = await _webController?.canGoBack();
                   if(canGoBack ?? false) {
                     print("AAA can go back 1");
                     await _webController?.goBack();
                   } else {
                     print("AAA can not go back 2 ${canGoBack}");
                   }
                }, child: Image.asset("assets/images/back.png")),

                 InkWell(onTap: () async {
                  var canGoForward = await _webController?.canGoForward();
                  if(canGoForward ?? false) {
                    print("AAA can go forward 1");
                    await _webController?.goForward();
                  } else {
                    print("AAA can not go forward");
                  }
                }, child: Image.asset("assets/images/forward.png"))

                ]))
              )
            ],
          ) 
        ),
      ),
    );
  }

  void _enableRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
