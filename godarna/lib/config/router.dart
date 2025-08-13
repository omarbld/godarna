import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/auth/login_page.dart';
import '../pages/home/home_page.dart';
import '../pages/listing/listing_details_page.dart';
import '../pages/listing/add_listing_page.dart';
import '../pages/bookings/bookings_page.dart';
import '../pages/payments/payment_page.dart';
import '../pages/profile/profile_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) => ListingDetailsPage(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/add-listing',
        builder: (context, state) => const AddListingPage(),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const BookingsPage(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId'] ?? '';
          return PaymentPage(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}