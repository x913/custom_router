import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WebViewPageState();
  }
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? _webController;
  String? webViewUrl;
  bool? timePassed;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _enableRotation();
    webViewUrl = widget.url;
  }

  @override
  Widget build(BuildContext context) {
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
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (con) {
                    print('AAA creation completed');
                    _webController = con;
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
