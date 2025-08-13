import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/providers/auth_provider.dart';
import 'package:godarna/services/analytics_service.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  Map<String, dynamic> _platformStats = {};
  List<Map<String, dynamic>> _popularCities = [];
  List<Map<String, dynamic>> _popularPropertyTypes = [];
  List<Map<String, dynamic>> _bookingTrends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    
    try {
      final platformStats = await _analyticsService.getPlatformStats();
      final popularCities = await _analyticsService.getPopularCities();
      final popularPropertyTypes = await _analyticsService.getPopularPropertyTypes();
      final bookingTrends = await _analyticsService.getBookingTrends(7);

      setState(() {
        _platformStats = platformStats;
        _popularCities = popularCities;
        _popularPropertyTypes = popularPropertyTypes;
        _bookingTrends = bookingTrends;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل البيانات: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isAuthenticated || authProvider.currentUser?.role != 'admin') {
      return Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        appBar: AppBar(
          title: const Text('الإدارة'),
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'غير مصرح لك بالوصول لهذه الصفحة',
            style: TextStyle(fontSize: 18, color: AppColors.error),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('لوحة الإدارة'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadAdminData,
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
              onRefresh: _loadAdminData,
              color: AppColors.primaryRed,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Platform Overview
                    _buildPlatformOverview(),
                    
                    const SizedBox(height: 20),
                    
                    // Statistics Grid
                    _buildStatisticsGrid(),
                    
                    const SizedBox(height: 20),
                    
                    // Popular Cities
                    _buildPopularCities(),
                    
                    const SizedBox(height: 20),
                    
                    // Popular Property Types
                    _buildPopularPropertyTypes(),
                    
                    const SizedBox(height: 20),
                    
                    // Booking Trends
                    _buildBookingTrends(),
                    
                    const SizedBox(height: 20),
                    
                    // Admin Actions
                    _buildAdminActions(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlatformOverview() {
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
                  Icons.admin_panel_settings,
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
                      'نظرة عامة على المنصة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'إحصائيات شاملة لجميع المستخدمين والعقارات',
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
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'إجمالي المستخدمين',
          '${_platformStats['totalUsers'] ?? 0}',
          Icons.people,
          AppColors.primaryRed,
        ),
        _buildStatCard(
          'إجمالي العقارات',
          '${_platformStats['totalProperties'] ?? 0}',
          Icons.home,
          AppColors.success,
        ),
        _buildStatCard(
          'إجمالي الحجوزات',
          '${_platformStats['totalBookings'] ?? 0}',
          Icons.bookmark,
          AppColors.info,
        ),
        _buildStatCard(
          'إجمالي الإيرادات',
          '${NumberFormat('#,###').format(_platformStats['totalRevenue'] ?? 0)} درهم',
          Icons.attach_money,
          AppColors.secondaryOrange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
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

  Widget _buildPopularCities() {
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
            'المدن الأكثر شعبية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_popularCities.isEmpty)
            const Center(
              child: Text(
                'لا توجد بيانات متاحة',
                style: TextStyle(color: AppColors.textLight),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _popularCities.length,
              itemBuilder: (context, index) {
                final city = _popularCities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(city['city'] ?? ''),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${city['count']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPopularPropertyTypes() {
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
            'أنواع العقارات الأكثر شعبية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_popularPropertyTypes.isEmpty)
            const Center(
              child: Text(
                'لا توجد بيانات متاحة',
                style: TextStyle(color: AppColors.textLight),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _popularPropertyTypes.length,
              itemBuilder: (context, index) {
                final type = _popularPropertyTypes[index];
                return ListTile(
                  leading: Icon(
                    _getPropertyTypeIcon(type['type']),
                    color: AppColors.primaryRed,
                  ),
                  title: Text(_getPropertyTypeName(type['type'])),
                  subtitle: Text('${type['percentage'].toStringAsFixed(1)}%'),
                  trailing: Text(
                    '${type['count']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBookingTrends() {
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
            'اتجاهات الحجوزات (آخر 7 أيام)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_bookingTrends.isEmpty)
            const Center(
              child: Text(
                'لا توجد بيانات متاحة',
                style: TextStyle(color: AppColors.textLight),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _bookingTrends.length,
                itemBuilder: (context, index) {
                  final trend = _bookingTrends[index];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.bottomCenter,
                              heightFactor: (trend['bookings'] as int) / 
                                  (_getMaxBookings() == 0 ? 1 : _getMaxBookings()),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRed,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trend['date'].split('-').last,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${trend['bookings']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
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
            'إجراءات الإدارة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'إدارة المستخدمين',
                  onPressed: () {
                    // TODO: Navigate to user management
                  },
                  icon: Icons.people,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'إدارة العقارات',
                  onPressed: () {
                    // TODO: Navigate to property management
                  },
                  icon: Icons.home,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'إدارة الحجوزات',
                  onPressed: () {
                    // TODO: Navigate to booking management
                  },
                  icon: Icons.bookmark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'التقارير',
                  onPressed: () {
                    // TODO: Navigate to reports
                  },
                  icon: Icons.analytics,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getPropertyTypeIcon(String type) {
    switch (type) {
      case 'apartment':
        return Icons.apartment;
      case 'villa':
        return Icons.villa;
      case 'riad':
        return Icons.house;
      case 'studio':
        return Icons.single_bed;
      default:
        return Icons.home;
    }
  }

  String _getPropertyTypeName(String type) {
    switch (type) {
      case 'apartment':
        return 'شقة';
      case 'villa':
        return 'فيلا';
      case 'riad':
        return 'رياض';
      case 'studio':
        return 'استوديو';
      default:
        return type;
    }
  }

  int _getMaxBookings() {
    if (_bookingTrends.isEmpty) return 0;
    int max = 0;
    for (final trend in _bookingTrends) {
      if (trend['bookings'] > max) {
        max = trend['bookings'];
      }
    }
    return max;
  }
}