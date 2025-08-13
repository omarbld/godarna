import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../providers/listings_provider.dart';

class FiltersSheet extends StatefulWidget {
  const FiltersSheet({super.key});

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  final minPriceCtrl = TextEditingController();
  final maxPriceCtrl = TextEditingController();
  final bedroomsCtrl = TextEditingController();
  final bathroomsCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(tr('home.filters'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: minPriceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('filters.min_price')))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: maxPriceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('filters.max_price')))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: bedroomsCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('filters.bedrooms')))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: bathroomsCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('filters.bathrooms')))),
          ]),
          const SizedBox(height: 8),
          TextField(controller: ratingCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('filters.min_rating'))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final filter = ListingsFilter(
                minPrice: double.tryParse(minPriceCtrl.text),
                maxPrice: double.tryParse(maxPriceCtrl.text),
                bedrooms: int.tryParse(bedroomsCtrl.text),
                bathrooms: int.tryParse(bathroomsCtrl.text),
                minRating: int.tryParse(ratingCtrl.text),
              );
              Navigator.of(context).pop(filter);
            },
            child: Text(tr('common.apply')),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}