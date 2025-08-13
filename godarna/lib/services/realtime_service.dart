import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeService {
  static RealtimeChannel subscribeToMyBookings({
    required String userId,
    required void Function(PostgresChangePayload payload) onChange,
  }) {
    final channel = Supabase.instance.client
        .channel('bookings-tenant-$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            final newRec = payload.newRecord;
            final oldRec = payload.oldRecord;
            if ((newRec['tenant_id'] == userId) || (oldRec['tenant_id'] == userId)) {
              onChange(payload);
            }
          },
        )
        .subscribe();
    return channel;
  }

  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await Supabase.instance.client.removeChannel(channel);
  }
}