import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/services/payment_service.dart';
import 'package:godarna/models/payment_model.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/widgets/custom_button.dart';
import 'package:godarna/utils/error_handler.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String propertyTitle;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.propertyTitle,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  String? _selectedPaymentMethod;
  bool _isProcessing = false;
  Map<String, dynamic>? _paymentResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('الدفع'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary
            _buildBookingSummary(),
            
            const SizedBox(height: 24),
            
            // Payment Methods
            _buildPaymentMethods(),
            
            const SizedBox(height: 24),
            
            // Payment Button
            if (_selectedPaymentMethod != null) _buildPaymentButton(),
            
            const SizedBox(height: 24),
            
            // Payment Result
            if (_paymentResult != null) _buildPaymentResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.primaryRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملخص الحجز',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'تأكيد الدفع',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Property Info
          Row(
            children: [
              Icon(
                Icons.home,
                color: AppColors.textLight,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.propertyTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Amount
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: AppColors.textLight,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'المبلغ الإجمالي:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.amount.toStringAsFixed(2)} درهم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Booking ID
          Row(
            children: [
              Icon(
                Icons.confirmation_number,
                color: AppColors.textLight,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'رقم الحجز:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                widget.bookingId.substring(0, 8),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final paymentMethods = _paymentService.getAvailablePaymentMethods();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر طريقة الدفع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...paymentMethods.map((method) => _buildPaymentMethodCard(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryRed.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryRed : AppColors.borderLight,
          width: 2,
        ),
      ),
      child: RadioListTile<String>(
        value: method['id'],
        groupValue: _selectedPaymentMethod,
        onChanged: (value) {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
        title: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(method['icon']),
              color: isSelected ? AppColors.primaryRed : AppColors.textLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryRed : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    method['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        activeColor: AppColors.primaryRed,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isProcessing ? 'جاري المعالجة...' : 'تأكيد الدفع',
        onPressed: _isProcessing ? null : _processPayment,
        isLoading: _isProcessing,
        backgroundColor: AppColors.primaryRed,
        height: 56,
      ),
    );
  }

  Widget _buildPaymentResult() {
    final isSuccess = _paymentResult!['success'] == true;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuccess ? AppColors.success : AppColors.error,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? AppColors.success : AppColors.error,
            size: 48,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _paymentResult!['message'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSuccess ? AppColors.success : AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (_paymentResult!['transaction_id'] != null) ...[
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'رقم العملية: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _paymentResult!['transaction_id'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          if (isSuccess) ...[
            CustomButton(
              text: 'العودة للرئيسية',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              backgroundColor: AppColors.success,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'إعادة المحاولة',
                    onPressed: () {
                      setState(() {
                        _paymentResult = null;
                      });
                    },
                    backgroundColor: AppColors.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'العودة',
                    onPressed: () => Navigator.pop(context),
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods
  IconData _getPaymentMethodIcon(String iconName) {
    switch (iconName) {
      case 'money':
        return Icons.money;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance':
        return Icons.account_balance;
      case 'smartphone':
        return Icons.smartphone;
      default:
        return Icons.payment;
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _paymentService.processPayment(
        bookingId: widget.bookingId,
        paymentMethod: _selectedPaymentMethod!,
        amount: widget.amount,
        paymentDetails: {
          'property_title': widget.propertyTitle,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _paymentResult = result;
        _isProcessing = false;
      });

      if (result['success'] == true) {
        // Send notification to host
        // TODO: Implement notification service call
        
        // Show success message
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(
            context,
            'تم الدفع بنجاح!',
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            result['message'] ?? 'حدث خطأ في الدفع',
          );
        }
      }
    } catch (e) {
      setState(() {
        _paymentResult = {
          'success': false,
          'message': 'حدث خطأ غير متوقع: $e',
        };
        _isProcessing = false;
      });

      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'حدث خطأ في معالجة الدفع',
        );
      }
    }
  }
}