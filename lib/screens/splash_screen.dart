import 'package:flutter/material.dart';

import '../widgets/loading_container.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen([Key? key]) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/icon.png',
                errorBuilder: (_, __, ___) => Container(),
                height: 150,
              ),
              const SizedBox(
                height: 50,
              ),
              const LoadingContainer(
                color: Colors.white,
              ),
            ],
          ),
        ));
  }

}
