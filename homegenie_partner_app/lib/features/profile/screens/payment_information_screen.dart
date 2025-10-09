
import 'package:flutter/material.dart';
import 'package:shared/theme/app_theme.dart';

class PaymentInformationScreen extends StatelessWidget {
  const PaymentInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/images/empty_wip.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
