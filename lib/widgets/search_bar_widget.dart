import 'package:flutter/material.dart';
import 'package:godarna/constants/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onFilterTap;
  final String? initialQuery;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
    this.initialQuery,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'البحث عن عقارات...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textLight,
                ),
              ),
              onChanged: (value) {
                widget.onSearch(value);
              },
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: AppColors.borderGrey,
          ),
          IconButton(
            onPressed: widget.onFilterTap,
            icon: const Icon(
              Icons.tune,
              color: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }
}