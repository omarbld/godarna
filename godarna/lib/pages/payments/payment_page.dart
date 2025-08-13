import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final String bookingId;
  const PaymentPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('payment.title'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('payment.online_coming')), 
            const SizedBox(height: 8),
            Text(tr('payment.booking_reference', args: [bookingId])),
          ],
        ),
      ),
    );
  }
}