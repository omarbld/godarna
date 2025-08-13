import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:godarna/providers/property_provider.dart';
import 'package:godarna/providers/auth_provider.dart';
import 'package:godarna/constants/app_colors.dart';
import 'package:godarna/constants/app_strings.dart';
import 'package:godarna/widgets/custom_button.dart';
import 'package:godarna/widgets/property_card.dart';
import 'package:godarna/screens/property/add_property_screen.dart';
import 'package:godarna/screens/property/edit_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        Provider.of<PropertyProvider>(context, listen: false).fetchMyProperties(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(AppStrings.getString('myProperties', context)),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          if (propertyProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            );
          }

          if (propertyProvider.myProperties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.getString('noPropertiesYet', context),
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: AppStrings.getString('addFirstProperty', context),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPropertyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: propertyProvider.myProperties.length,
            itemBuilder: (context, index) {
              final property = propertyProvider.myProperties[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Stack(
                  children: [
                    PropertyCard(
                      property: property,
                      onTap: () {
                        // Navigate to property details
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditPropertyScreen(property: property),
                              ),
                            );
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, propertyProvider, property.id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, size: 20),
                                const SizedBox(width: 8),
                                Text(AppStrings.getString('edit', context)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 20, color: AppColors.error),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.getString('delete', context),
                                  style: const TextStyle(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.more_vert,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPropertyScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PropertyProvider propertyProvider, String propertyId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getString('deleteProperty', context)),
        content: Text(AppStrings.getString('deletePropertyConfirm', context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getString('cancel', context)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await propertyProvider.deleteProperty(propertyId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف العقار بنجاح'),
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
              AppStrings.getString('delete', context),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}