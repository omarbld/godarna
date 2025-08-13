import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/services/payment_service.dart';
import 'package:godarna/models/payment_model.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/utils/error_handler.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentService _paymentService = PaymentService();
  List<Map<String, dynamic>> _payments = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get current user ID from auth provider
      // For now, using a placeholder
      const userId = 'current_user_id';
      
      final payments = await _paymentService.getPaymentHistory(userId);
      final stats = await _paymentService.getPaymentStatistics(userId);
      
      setState(() {
        _payments = payments;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'حدث خطأ في تحميل بيانات المدفوعات: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('سجل المدفوعات'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadPaymentData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPaymentData,
              color: AppColors.primaryRed,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Statistics
                    _buildStatistics(),
                    
                    const SizedBox(height: 24),
                    
                    // Payments List
                    _buildPaymentsList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatistics() {
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
            'إحصائيات المدفوعات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي المدفوع',
                  '${_statistics['totalPaid']?.toStringAsFixed(2) ?? '0.00'} درهم',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'قيد المعالجة',
                  '${_statistics['totalPending']?.toStringAsFixed(2) ?? '0.00'} درهم',
                  Icons.schedule,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المدفوعات الناجحة',
                  '${_statistics['successfulPayments'] ?? 0}',
                  Icons.thumb_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'المدفوعات الفاشلة',
                  '${_statistics['failedPayments'] ?? 0}',
                  Icons.thumb_down,
                  AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList() {
    if (_payments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
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
          children: [
            Icon(
              Icons.payment,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مدفوعات',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر هنا جميع المدفوعات الخاصة بك',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'سجل المدفوعات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _payments.length,
            itemBuilder: (context, index) {
              final payment = _payments[index];
              return _buildPaymentCard(payment);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final amount = (payment['amount'] ?? 0).toDouble();
    final status = payment['status'] ?? '';
    final method = payment['payment_method'] ?? '';
    final createdAt = DateTime.tryParse(payment['created_at'] ?? '') ?? DateTime.now();
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'paid':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case 'failed':
        statusColor = AppColors.error;
        statusIcon = Icons.error;
        break;
      case 'refunded':
        statusColor = AppColors.info;
        statusIcon = Icons.undo;
        break;
      default:
        statusColor = AppColors.textLight;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentMethodName(method),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${amount.toStringAsFixed(2)} درهم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),
              if (payment['transaction_id'] != null) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رقم العملية',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        payment['transaction_id'].toString().substring(0, 8),
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
            ],
          ),
          
          // Property Info
          if (payment['bookings'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.home,
                    color: AppColors.textLight,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'عقار محجوز',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(
                      DateTime.tryParse(payment['bookings']['check_in'] ?? '') ?? DateTime.now(),
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Actions
          if (status == 'paid' && method != 'cash_on_delivery') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'طلب استرداد',
                onPressed: () => _showRefundDialog(payment),
                backgroundColor: AppColors.warning,
                height: 40,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Helper methods
  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash_on_delivery':
        return 'نقداً عند التسليم';
      default:
        return method;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'paid':
        return 'مدفوع';
      case 'pending':
        return 'قيد المعالجة';
      case 'failed':
        return 'فشل';
      case 'refunded':
        return 'مسترد';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  void _showRefundDialog(Map<String, dynamic> payment) {
    final amount = (payment['amount'] ?? 0).toDouble();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طلب استرداد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المبلغ: ${amount.toStringAsFixed(2)} درهم'),
            const SizedBox(height: 16),
            const Text('سبب الاسترداد:'),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'اكتب سبب الاسترداد هنا...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processRefund(payment['id'], amount, 'سبب الاسترداد');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('إرسال الطلب'),
          ),
        ],
      ),
    );
  }

  Future<void> _processRefund(String paymentId, double amount, String reason) async {
    try {
      final result = await _paymentService.refundPayment(paymentId, amount, reason);
      
      if (result['success'] == true) {
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(
            context,
            'تم إرسال طلب الاسترداد بنجاح',
          );
          _loadPaymentData(); // Refresh data
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            result['message'] ?? 'حدث خطأ في طلب الاسترداد',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          'حدث خطأ في معالجة طلب الاسترداد',
        );
      }
    }
  }
}