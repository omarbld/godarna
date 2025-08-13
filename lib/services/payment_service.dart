import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:godarna/models/booking_model.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Process payment for a booking
  Future<Map<String, dynamic>> processPayment({
    required String bookingId,
    required String paymentMethod,
    required double amount,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      // Create payment record
      final paymentResponse = await _supabase
          .from('payments')
          .insert({
            'booking_id': bookingId,
            'amount': amount,
            'payment_method': paymentMethod,
            'status': 'pending',
            'details': paymentDetails,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Update booking payment status
      await _supabase
          .from('bookings')
          .update({
            'payment_status': 'pending',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      // Process payment based on method
      Map<String, dynamic> result;
      switch (paymentMethod) {
        case 'cash_on_delivery':
          result = await _processCashOnDelivery(bookingId, amount);
          break;
        case 'online':
          result = await _processOnlinePayment(bookingId, amount, paymentDetails);
          break;
        case 'bank_transfer':
          result = await _processBankTransfer(bookingId, amount, paymentDetails);
          break;
        case 'mobile_money':
          result = await _processMobileMoney(bookingId, amount, paymentDetails);
          break;
        default:
          throw Exception('طريقة دفع غير مدعومة');
      }

      // Update payment status
      await _updatePaymentStatus(
        paymentResponse['id'],
        result['success'] ? 'paid' : 'failed',
        result['transaction_id'],
        result['message'],
      );

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في معالجة الدفع: $e',
        'transaction_id': null,
      };
    }
  }

  // Process cash on delivery payment
  Future<Map<String, dynamic>> _processCashOnDelivery(
    String bookingId,
    double amount,
  ) async {
    try {
      // For cash on delivery, we just mark it as pending
      // The actual payment happens when the guest arrives
      await _supabase
          .from('bookings')
          .update({
            'payment_status': 'pending',
            'payment_method': 'cash_on_delivery',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      return {
        'success': true,
        'message': 'تم تأكيد الدفع نقداً عند التسليم',
        'transaction_id': 'COD_${DateTime.now().millisecondsSinceEpoch}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في تأكيد الدفع النقدي: $e',
        'transaction_id': null,
      };
    }
  }

  // Process online payment
  Future<Map<String, dynamic>> _processOnlinePayment(
    String bookingId,
    double amount,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // TODO: Integrate with actual payment gateway
      // For now, simulate successful payment
      
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate payment success (90% success rate)
      final isSuccess = DateTime.now().millisecondsSinceEpoch % 10 != 0;
      
      if (isSuccess) {
        // Update booking payment status
        await _supabase
            .from('bookings')
            .update({
              'payment_status': 'paid',
              'payment_method': 'online',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', bookingId);

        return {
          'success': true,
          'message': 'تم الدفع بنجاح',
          'transaction_id': 'ONL_${DateTime.now().millisecondsSinceEpoch}',
        };
      } else {
        return {
          'success': false,
          'message': 'فشل في معالجة الدفع. يرجى المحاولة مرة أخرى.',
          'transaction_id': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في معالجة الدفع الإلكتروني: $e',
        'transaction_id': null,
      };
    }
  }

  // Process bank transfer payment
  Future<Map<String, dynamic>> _processBankTransfer(
    String bookingId,
    double amount,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // Generate bank transfer reference
      final transferRef = 'BT_${DateTime.now().millisecondsSinceEpoch}';
      
      // Update booking with transfer reference
      await _supabase
          .from('bookings')
          .update({
            'payment_status': 'pending',
            'payment_method': 'bank_transfer',
            'transfer_reference': transferRef,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      return {
        'success': true,
        'message': 'تم إنشاء طلب التحويل البنكي. الرقم المرجعي: $transferRef',
        'transaction_id': transferRef,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في إنشاء طلب التحويل البنكي: $e',
        'transaction_id': null,
      };
    }
  }

  // Process mobile money payment
  Future<Map<String, dynamic>> _processMobileMoney(
    String bookingId,
    double amount,
    Map<String, dynamic>? paymentDetails,
  ) async {
    try {
      // TODO: Integrate with mobile money providers
      // For now, simulate successful payment
      
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate payment success (95% success rate)
      final isSuccess = DateTime.now().millisecondsSinceEpoch % 20 != 0;
      
      if (isSuccess) {
        // Update booking payment status
        await _supabase
            .from('bookings')
            .update({
              'payment_status': 'paid',
              'payment_method': 'mobile_money',
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            })
            .eq('id', bookingId);

        return {
          'success': true,
          'message': 'تم الدفع عبر المحفظة الإلكترونية بنجاح',
          'transaction_id': 'MM_${DateTime.now().millisecondsSinceEpoch}',
        };
      } else {
        return {
          'success': false,
          'message': 'فشل في معالجة الدفع عبر المحفظة الإلكترونية',
          'transaction_id': null,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في معالجة الدفع عبر المحفظة الإلكترونية: $e',
        'transaction_id': null,
      };
    }
  }

  // Update payment status
  Future<void> _updatePaymentStatus(
    String paymentId,
    String status,
    String? transactionId,
    String? message,
  ) async {
    try {
      await _supabase
          .from('payments')
          .update({
            'status': status,
            'transaction_id': transactionId,
            'message': message,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  // Get payment history for a user
  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('''
            *,
            bookings!inner(
              id,
              property_id,
              check_in,
              check_out,
              total_price
            )
          ''')
          .eq('bookings.tenant_id', userId)
          .order('created_at', ascending: false);

      return response ?? [];
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }

  // Get payment details
  Future<Map<String, dynamic>?> getPaymentDetails(String paymentId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('''
            *,
            bookings(
              id,
              property_id,
              check_in,
              check_out,
              total_price,
              properties(
                title,
                city
              )
            )
          ''')
          .eq('id', paymentId)
          .single();

      return response;
    } catch (e) {
      print('Error getting payment details: $e');
      return null;
    }
  }

  // Refund payment
  Future<Map<String, dynamic>> refundPayment(
    String paymentId,
    double amount,
    String reason,
  ) async {
    try {
      // Check if payment can be refunded
      final payment = await _supabase
          .from('payments')
          .select('*')
          .eq('id', paymentId)
          .single();

      if (payment['status'] != 'paid') {
        return {
          'success': false,
          'message': 'لا يمكن استرداد الدفع في هذه الحالة',
        };
      }

      // Create refund record
      final refundResponse = await _supabase
          .from('refunds')
          .insert({
            'payment_id': paymentId,
            'amount': amount,
            'reason': reason,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      // Update payment status
      await _supabase
          .from('payments')
          .update({
            'status': 'refunded',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      // Update booking payment status
      await _supabase
          .from('bookings')
          .update({
            'payment_status': 'refunded',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', payment['booking_id']);

      return {
        'success': true,
        'message': 'تم إنشاء طلب الاسترداد بنجاح',
        'refund_id': refundResponse['id'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في إنشاء طلب الاسترداد: $e',
      };
    }
  }

  // Get available payment methods
  List<Map<String, dynamic>> getAvailablePaymentMethods() {
    return [
      {
        'id': 'cash_on_delivery',
        'name': 'نقداً عند التسليم',
        'description': 'ادفع عند وصولك للعقار',
        'icon': 'money',
        'enabled': true,
      },
      {
        'id': 'online',
        'name': 'دفع إلكتروني',
        'description': 'ادفع عبر البطاقة البنكية',
        'icon': 'credit_card',
        'enabled': true,
      },
      {
        'id': 'bank_transfer',
        'name': 'تحويل بنكي',
        'description': 'تحويل مباشر للبنك',
        'icon': 'account_balance',
        'enabled': true,
      },
      {
        'id': 'mobile_money',
        'name': 'محفظة إلكترونية',
        'description': 'ادفع عبر المحفظة الإلكترونية',
        'icon': 'smartphone',
        'enabled': true,
      },
    ];
  }

  // Validate payment method
  bool isValidPaymentMethod(String method) {
    final methods = getAvailablePaymentMethods();
    return methods.any((m) => m['id'] == method && m['enabled'] == true);
  }

  // Get payment statistics
  Future<Map<String, dynamic>> getPaymentStatistics(String userId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('''
            status,
            amount,
            bookings!inner(
              tenant_id
            )
          ''')
          .eq('bookings.tenant_id', userId);

      if (response == null) return {};

      double totalPaid = 0;
      double totalPending = 0;
      double totalRefunded = 0;
      int successfulPayments = 0;
      int failedPayments = 0;

      for (final payment in response) {
        final amount = (payment['amount'] ?? 0).toDouble();
        final status = payment['status'];

        switch (status) {
          case 'paid':
            totalPaid += amount;
            successfulPayments++;
            break;
          case 'pending':
            totalPending += amount;
            break;
          case 'refunded':
            totalRefunded += amount;
            break;
          case 'failed':
            failedPayments++;
            break;
        }
      }

      return {
        'totalPaid': totalPaid,
        'totalPending': totalPending,
        'totalRefunded': totalRefunded,
        'successfulPayments': successfulPayments,
        'failedPayments': failedPayments,
        'totalPayments': response.length,
      };
    } catch (e) {
      print('Error getting payment statistics: $e');
      return {};
    }
  }
}