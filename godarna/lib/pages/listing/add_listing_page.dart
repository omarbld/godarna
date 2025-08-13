import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class AddListingPage extends ConsumerStatefulWidget {
  const AddListingPage({super.key});

  @override
  ConsumerState<AddListingPage> createState() => _AddListingPageState();
}

class _AddListingPageState extends ConsumerState<AddListingPage> {
  final formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final bedroomsCtrl = TextEditingController(text: '1');
  final bathroomsCtrl = TextEditingController(text: '1');
  final guestsCtrl = TextEditingController(text: '1');
  final imageUrlCtrl = TextEditingController();
  bool isPublished = true;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(tr('host.add_listing'))),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: tr('listing.title')),
              validator: (v) => v == null || v.isEmpty ? tr('common.required') : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: descCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(labelText: tr('listing.description')),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('listing.price_per_night')))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: cityCtrl, decoration: InputDecoration(labelText: tr('listing.city')))),
            ]),
            const SizedBox(height: 8),
            TextFormField(controller: addressCtrl, decoration: InputDecoration(labelText: tr('listing.address'))),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(controller: bedroomsCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('listing.bedrooms_short')))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: bathroomsCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('listing.bathrooms_short')))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: guestsCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr('listing.guests_short')))),
            ]),
            const SizedBox(height: 8),
            TextFormField(controller: imageUrlCtrl, decoration: InputDecoration(labelText: tr('listing.image_url'))),
            const SizedBox(height: 8),
            SwitchListTile(
              value: isPublished,
              onChanged: (v) => setState(() => isPublished = v),
              title: Text(tr('listing.published')),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      setState(() => isSubmitting = true);
                      try {
                        final result = await supabase.from('listings').insert({
                          'host_id': auth.profile!.id,
                          'title': titleCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'price_per_night': double.tryParse(priceCtrl.text) ?? 0,
                          'bedrooms': int.tryParse(bedroomsCtrl.text) ?? 1,
                          'bathrooms': int.tryParse(bathroomsCtrl.text) ?? 1,
                          'max_guests': int.tryParse(guestsCtrl.text) ?? 1,
                          'city': cityCtrl.text.trim(),
                          'address_line': addressCtrl.text.trim(),
                          'main_image_url': imageUrlCtrl.text.trim().isEmpty ? null : imageUrlCtrl.text.trim(),
                          'is_published': isPublished,
                        }).select('id').single();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('host.listing_created'))));
                        Navigator.of(context).pop(result['id']);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      } finally {
                        setState(() => isSubmitting = false);
                      }
                    },
              child: Text(tr('common.save')),
            ),
          ],
        ),
      ),
    );
  }
}