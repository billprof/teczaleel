import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:teczaleel/core/utils/functions.dart';
import 'package:teczaleel/widgets/app_button.dart';

class OrderSummary extends StatelessWidget {
  final double totalPrice;
  const OrderSummary({super.key, required this.totalPrice});

  void _showCheckoutDialog(BuildContext context) {
    AlertInfo.show(
      context: context,
      text: 'This is just for a demo',
      typeInfo: TypeInfo.warning,
      duration: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  Utils.formatMoney(totalPrice),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7b32e8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Checkout',
                    onPressed: () => _showCheckoutDialog(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
