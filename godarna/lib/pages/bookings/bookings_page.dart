import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../services/realtime_service.dart';

class BookingsPage extends ConsumerStatefulWidget {
  const BookingsPage({super.key});

  @override
  ConsumerState<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends ConsumerState<BookingsPage> {
  RealtimeChannel? _channel;
  String? _userId;

  @override
  void dispose() {
    if (_channel != null) {
      RealtimeService.unsubscribe(_channel!);
    }
    super.dispose();
  }

  void _ensureSubscription(String userId) {
    if (_userId == userId && _channel != null) return;
    _userId = userId;
    if (_channel != null) {
      RealtimeService.unsubscribe(_channel!);
    }
    _channel = RealtimeService.subscribeToMyBookings(
      userId: userId,
      onChange: (payload) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('booking.my_bookings'))),
        );
        ref.invalidate(myBookingsProvider(userId));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final userId = auth.profile?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('booking.my_bookings'))),
        body: Center(child: Text(tr('auth.sign_in_first'))),
      );
    }

    _ensureSubscription(userId);

    final bookingsAsync = ref.watch(myBookingsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(tr('booking.my_bookings'))),
      body: bookingsAsync.when(
        data: (items) => ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final b = items[i];
            return ListTile(
              title: Text('#${b.id.substring(0, 6)} • ${DateFormat.yMMMd().format(b.startDate)} → ${DateFormat.yMMMd().format(b.endDate)}'),
              subtitle: Text('${tr('booking.status')}: ${b.status} • ${tr('payment.status')}: ${b.paymentStatus}'),
              trailing: Text('${b.totalPrice.toStringAsFixed(0)} MAD'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }
}