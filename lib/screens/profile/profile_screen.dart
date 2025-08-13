import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/providers/auth_provider.dart';
import 'package:godarna/providers/language_provider.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/widgets/custom_button.dart';
import 'package:godarna/screens/auth/login_screen.dart';
import 'package:godarna/screens/profile/edit_profile_screen.dart';
import 'package:godarna/screens/profile/my_properties_screen.dart';
import 'package:godarna/screens/profile/my_bookings_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    if (!authProvider.isAuthenticated) {
      return _buildNotAuthenticated(context);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(AppStrings.getString('profile', context)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => languageProvider.toggleLanguage(),
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, authProvider),
            
            const SizedBox(height: 20),
            
            // Profile Actions
            _buildProfileActions(context, authProvider),
            
            const SizedBox(height: 20),
            
            // Settings
            _buildSettings(context, languageProvider),
            
            const SizedBox(height: 20),
            
            // Logout Button
            CustomButton(
              text: AppStrings.getString('logout', context),
              onPressed: () => _showLogoutDialog(context, authProvider),
              backgroundColor: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotAuthenticated(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(AppStrings.getString('profile', context)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 80,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.getString('loginRequired', context),
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: AppStrings.getString('login', context),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser!;
    
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
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.backgroundGrey,
            backgroundImage: user.avatar != null
                ? CachedNetworkImageProvider(user.avatar!)
                : null,
            child: user.avatar == null
                ? Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.textLight,
                  )
                : null,
          ),
          
          const SizedBox(height: 16),
          
          // User Info
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          if (user.phone != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone,
                  color: AppColors.textLight,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  user.phone!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileActions(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser!;
    
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
            AppStrings.getString('quickActions', context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Edit Profile
          _buildActionTile(
            context,
            icon: Icons.edit,
            title: AppStrings.getString('editProfile', context),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
          
          // My Properties (for hosts)
          if (user.isHost)
            _buildActionTile(
              context,
              icon: Icons.home,
              title: AppStrings.getString('myProperties', context),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyPropertiesScreen(),
                  ),
                );
              },
            ),
          
          // My Bookings
          _buildActionTile(
            context,
            icon: Icons.bookmark,
            title: AppStrings.getString('myBookings', context),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyBookingsScreen(),
                ),
              );
            },
          ),
          
          // Change Role
          if (user.role == 'tenant')
            _buildActionTile(
              context,
              icon: Icons.swap_horiz,
              title: AppStrings.getString('becomeHost', context),
              onTap: () => _showChangeRoleDialog(context, authProvider),
            ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context, LanguageProvider languageProvider) {
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
            AppStrings.getString('settings', context),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language Setting
          _buildActionTile(
            context,
            icon: Icons.language,
            title: AppStrings.getString('language', context),
            subtitle: languageProvider.currentLanguageName,
            onTap: () => languageProvider.toggleLanguage(),
          ),
          
          // Notifications
          _buildActionTile(
            context,
            icon: Icons.notifications,
            title: AppStrings.getString('notifications', context),
            subtitle: AppStrings.getString('enabled', context),
            onTap: () {
              // TODO: Implement notifications settings
            },
          ),
          
          // Privacy
          _buildActionTile(
            context,
            icon: Icons.privacy_tip,
            title: AppStrings.getString('privacy', context),
            onTap: () {
              // TODO: Implement privacy settings
            },
          ),
          
          // Help & Support
          _buildActionTile(
            context,
            icon: Icons.help,
            title: AppStrings.getString('helpSupport', context),
            onTap: () {
              // TODO: Implement help & support
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryRed,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textLight,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getString('logout', context)),
        content: Text(AppStrings.getString('logoutConfirm', context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getString('cancel', context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.signOut();
            },
            child: Text(
              AppStrings.getString('logout', context),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getString('becomeHost', context)),
        content: Text(AppStrings.getString('becomeHostConfirm', context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getString('cancel', context)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await authProvider.changeRole('host');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تغيير دورك إلى مالك عقار'),
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
              style: const TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.error;
      case 'host':
        return AppColors.primaryRed;
      case 'tenant':
        return AppColors.secondaryOrange;
      default:
        return AppColors.primaryRed;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'مدير';
      case 'host':
        return 'مالك عقار';
      case 'tenant':
        return 'مستأجر';
      default:
        return 'مستخدم';
    }
  }
}