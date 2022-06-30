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
          child: WebView(
            gestureNavigationEnabled: true,
            initialUrl: webViewUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) async {
              await _webController!.runJavascript("""

                  javascript:(function f() {
                        const style = document.createElement("style");
                        style.setAttribute('type', 'text/css');
                        style.innerHTML = ''
                            + '#footer {'
                            + 'z-index: 999999;'
                            + 'position: fixed;'
                            + 'bottom: 0;'
                            + 'height: 65px;'
                            + 'width: 100%;'
                            + '}'
                            + '.arrow {'
                            + 'float: right;'
                            + '}';
                
                        document.head.appendChild(style);

                        const footer = document.createElement("div");
                        
                        footer.innerHTML = '<div id="footer" style="background-color: #FFF">'
                            + '<div class="arrow">'
                            + '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAN3SURBVHgB7ZtJaBRBFIZ/JRp3yVmiA64YMIo5qcioiCBGEDwILkFGBMGINxNwjWByENFEhJzGgxpFVDxoPCgEBL2JnhRRDMaLC0RQ4574HvWadpLGdE33dFeN9cFPQab2rq6/lg7gcDgcDsd/yxjYSyVpJWktaQbpE6mbdBNlzlTSIdIH0lCAjqJMqSA1kt7Bb+xj0nHSVtJB0nf5+wKUGfWkp/Abfp+UDYiXl9/3oEzIQjXWazh3Qv0/4rdKvGZYTh3pLvyG87Dn4V8xSrouib8DllJNukAahGpIP+kIaVrI9C8lXR0so4rURvoC1YCvUMO5SiOPpZK2FxbBlnYY6klz5fnJ8wiohj7eBHgOFsDv8l4UWhq/88UO3cnw1wXzYDgbEM7SdGiQvB7AYLIYaWkbEQ8PJc8GGAhPTsVYWljmS77vSZNgEFEtLSydkn8ehuBZ2gCKtzQdXks5S5AyQZZ2EcVZWliWSVnPkSJBu7QolqZDs5TXiZQohaXpcEfK3YSE4ZMYnV1aqXgl5c9FQvBwP4nSWZoOE+BPsokwjnRbCv1GakH8lqbDYqnLIyTEKSmwDwZYDrEG/oRbcmqkMD5zmwMz2AxVp8uIwNiQ8Rol5NXWC5jBdAn7EYGwHVAjYRfMYbyEPxCBsB0wOKxQk4h0uRO2A55IuBrm4D35SkQgbAdckXAfaSHMYEDCiUiIdqhZl3dfJnQC3wlyfbqREPz+35JCf5OOQe0A08I7CHmGBOFX5gT8pTCvxXchHaZATc6fkcItN291+WLy747YhuR5I+VnkBLcaG9HxmK3WIXkuCHlbkHK5FDYEVyx2Sg93oFIOwyA38kDpLfwO4KXzhmUDu9IrBcGwWeAHaRfUJXj8CxpJuKHJ2XvRmg5DCNDOg9/NPC5fRPit842yf80DIXngmsodIwc4qMW/r1DmuuSUclipHVuRzz0SJ47YQFB1hl1k5WTvHpgEUHWWexpE59Nehcyi2ARbJ08McZhnWckfSsshK2TFzM/oRrBYQf0rtVWwHcba7+AzaDQOnlk6Fhnn6SrheXwXHAd+taZl/hp7VBjJwvlEmF3nd6Hkk0oM4Ksc31AvEvy+26UKcOtky9l+WNp3g7zx9Le/iOJnWhqsHXuh9oBDgWoRSczm/9hguu+DuoAZhbpI+kq6R4cDofD4XCE4Q8nuRn7NgDggAAAAABJRU5ErkJggg==" id="back">'
                            + '<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAOUSURBVHgB7ZtbiE1RGMd/hJRLJo8MU24TxcR4MdRRPMgtUTNCJoOSKG9GyOWBByHjwTyNQubFzJOJiIniTXlwSWqYeHBrXsxgcvu+vn06zpkzZp/bPmuf2b/6t5tm7/b3rf2t9d9rrX0gIiIiIiJi2DKCzFkh2iSaJHorui+6LfrDMOAElmiq3ogOiMZTwszEkv0lOiyqFZ0UvSDREF2inZQou7Ekr6f53yrRU5IbYislxkEsuVP/OUeT7iLRENooyykRdmFJtfg4t4HkhmjDulCoqcKSeefz/AlY1Xwg0RDaeBWEFLXMT1giSzO4rlx0UfTTu1aPTaJphBDt/5rEeTKnQnSZRDVoZWiFjCNEzMeC78FKPBtmiNpJdowGQkQnFvgOckPdIZTWWY8F3El+2MZA64zhMFr62gU02AXkj1TrvIF1Fyc5x9AvRdkwERsYP+K4ddZgwX0WjST/pLNO/dsp64yX6xIKRwUDrbMRR6zzAhbUIQqPjgVtOGaddVgw7QRHDIesczqZzQ3ySTrrXEzA6Nzgq+g3xVsJSrVOdaVCDMqD8tK78WyKh76XHMdWqjSWDtEYAqLDu+lKik+lqBuLp4mAuOLdsA43mCvqxWKq8XNBrv2l1zu6MqV9jtmzUuvnglwboN87BtbnfHDPO1b5OTnXBnBxMyT+UHxt+uTaAPEn/wN32OwdnxEArVgVbMQNdOVZH4bGNM/PBblWwGTv2EPxWYjtU2pVniWgCniCtbavAadA6BqCvgh992K5KRpFQMRvOpbg0ST3kbx4coYAk59FYkYWNOtI3pR9IFpGwGzwbn6L4IiJHpJIXF981lAkmr0gGik81aK7JK8M7SXAck/HKwq/JDZVdA2bcsc3ZI6S/aZM3lDL0YC6KQxlotOib959+rC5fhmO0IIF1kx+UUvTJxzfd9Anf1U0BYfQmZ8uh2uAleSH0aL9JFvaHdEiHGQ7FuBj8sN6BlpaDId5hAVaT27ESLY0bYSiWZpfdO1Pg/1C9guhTlqaXy7h/zuhVHS7Swc05ywtE/TLUA0+k8Epbml93rW6jOaUpflFNx40gdc+zx/M0soJKfHRv3WI89LN0rTPVxNy/HwomTpL01E+Romwh8EHQP3eJ9XS1lJizMGS0zW3I6It2MfS/+7Watlr+YfC0rLhGOk/l9dXY22UUFmaks0PJrSfr8bmBO+xd3Z9fe0nIiIiIiIiIkz8BSRPHdHnspqqAAAAAElFTkSuQmCC" id="forward">'
                            + '</div>'
                            + '</div>';

                        document.body.appendChild(footer);
                        const back = document.getElementById("back");
                        const forward = document.getElementById("forward");
                        
                        back.addEventListener("touchstart", () => {
                            console.log("AAA back pressed");
                            window.history.go(-1);
                        });
                        
                        forward.addEventListener("touchstart", () => {
                            console.log("AAA forward pressed");
                            window.history.forward();
                        });
                        
                        console.log('AAA footer added success');
                })();

              """);
            },
            onWebViewCreated: (con) {
              print('complete');
              _webController = con;
            },
          ),
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
