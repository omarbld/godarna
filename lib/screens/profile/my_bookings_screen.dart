import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/providers/booking_provider.dart';
import 'package:godarna/providers/auth_provider.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        Provider.of<BookingProvider>(context, listen: false).fetchUserBookings(authProvider.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(AppStrings.getString('myBookings', context)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: AppStrings.getString('upcoming', context)),
            Tab(text: AppStrings.getString('active', context)),
            Tab(text: AppStrings.getString('completed', context)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList('upcoming'),
          _buildBookingsList('active'),
          _buildBookingsList('completed'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(String status) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryRed,
            ),
          );
        }

        List<dynamic> bookings;
        switch (status) {
          case 'upcoming':
            bookings = bookingProvider.upcomingBookings;
            break;
          case 'active':
            bookings = bookingProvider.activeBookings;
            break;
          case 'completed':
            bookings = bookingProvider.completedBookings;
            break;
          default:
            bookings = [];
        }

        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(status),
                  size: 80,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 20),
                Text(
                  _getEmptyMessage(status),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBookingCard(booking, status),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingCard(dynamic booking, String status) {
    return Container(
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
          // Property Image and Info
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    booking.property?.mainPhoto ?? '',
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 60,
                      color: AppColors.backgroundGrey,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.property?.title ?? 'عقار غير محدد',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.property?.locationDisplay ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Booking Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        Icons.calendar_today,
                        DateFormat('dd/MM/yyyy').format(booking.checkIn),
                        AppStrings.getString('checkIn', context),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.calendar_today,
                        DateFormat('dd/MM/yyyy').format(booking.checkOut),
                        AppStrings.getString('checkOut', context),
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        Icons.nights_stay,
                        '${booking.nights}',
                        AppStrings.getString('nights', context),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.getString('totalPrice', context),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${booking.totalPrice.toStringAsFixed(2)} درهم',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
                
                if (status == 'upcoming' && booking.status == 'confirmed') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.getString('cancel', context),
                          onPressed: () => _showCancelDialog(booking.id),
                          backgroundColor: AppColors.error,
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: AppStrings.getString('viewDetails', context),
                          onPressed: () {
                            // Navigate to booking details
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (status == 'completed' && booking.rating == null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: AppStrings.getString('addReview', context),
                      onPressed: () => _showReviewDialog(booking.id),
                      backgroundColor: AppColors.secondaryOrange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textLight,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.schedule;
      case 'active':
        return Icons.home;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.bookmark;
    }
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'upcoming':
        return AppStrings.getString('noUpcomingBookings', context);
      case 'active':
        return AppStrings.getString('noActiveBookings', context);
      case 'completed':
        return AppStrings.getString('noCompletedBookings', context);
      default:
        return AppStrings.getString('noBookings', context);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.info;
      default:
        return AppColors.textLight;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return AppStrings.getString('pending', context);
      case 'confirmed':
        return AppStrings.getString('confirmed', context);
      case 'cancelled':
        return AppStrings.getString('cancelled', context);
      case 'completed':
        return AppStrings.getString('completed', context);
      default:
        return status;
    }
  }

  void _showCancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getString('cancelBooking', context)),
        content: Text(AppStrings.getString('cancelBookingConfirm', context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getString('cancel', context)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
                await bookingProvider.updateBookingStatus(bookingId, 'cancelled');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إلغاء الحجز بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppStrings.getString('confirm', context),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(String bookingId) {
    // TODO: Implement review dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة التقييم قيد التطوير'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}