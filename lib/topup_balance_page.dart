import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class TopUpBalancePage extends StatefulWidget {
  const TopUpBalancePage({Key? key}) : super(key: key);

  @override
  State<TopUpBalancePage> createState() => _TopUpBalancePageState();
}

class _TopUpBalancePageState extends State<TopUpBalancePage> {
  final _amountController = TextEditingController();

  final String merchantId = "10000100"; // Sample test merchant ID
  final String salt = "46f0cd694581a"; // Sample test salt
  final String returnUrl = "https://sandbox.payfast.pk/eng/process";

  late final WebViewController _controller;

  String generateSignature(String amount, String orderId) {
    final raw = "$merchantId&$amount&PKR&$orderId&$returnUrl&$salt";
    final bytes = utf8.encode(raw);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void launchPayment(String amount) {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = generateSignature(amount, orderId);

    final paymentUrl = Uri.https('sandbox.payfast.pk', '/payment', {
      'merchant_id': merchantId,
      'order_id': orderId,
      'amount': amount,
      'return_url': returnUrl,
      'signature': signature,
      'description': 'Top up balance',
    }).toString();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(paymentUrl));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Processing Payment')),
          body: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Balance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Enter amount to top up (PKR):'),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final amount = _amountController.text.trim();
                if (amount.isNotEmpty && double.tryParse(amount) != null) {
                  launchPayment(amount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter a valid amount")),
                  );
                }
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
