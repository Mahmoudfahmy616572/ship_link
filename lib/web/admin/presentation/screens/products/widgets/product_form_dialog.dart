import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';

// فورم إضافة/تعديل منتج (بيظهر في Dialog)
class ProductFormDialog extends StatefulWidget {
  final Map<String, dynamic>? product; // null = إضافة جديدة
  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _newPrice;
  late final TextEditingController _qty;
  late final TextEditingController _category;
  late final TextEditingController _image;
  bool _isOffer = false;
  bool _isTopSeller = false;
  int _status = 1;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?['name']?.toString() ?? '');
    _desc = TextEditingController(text: p?['description']?.toString() ?? '');
    _price = TextEditingController(text: p?['price']?.toString() ?? '');
    _newPrice = TextEditingController(text: p?['new_price']?.toString() ?? '');
    _qty = TextEditingController(text: (p?['qty'] ?? 0).toString());
    _category = TextEditingController(text: p?['category']?.toString() ?? '');
    _image = TextEditingController(text: p?['image']?.toString() ?? '');
    _isOffer = p?['is_offer'] == true;
    _isTopSeller = p?['is_top_seller'] == true;
    _status = p?['status'] is int ? p!['status'] as int : 1;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _newPrice.dispose();
    _qty.dispose();
    _category.dispose();
    _image.dispose();
    super.dispose();
  }

  Map<String, dynamic> _collect() {
    return {
      'name': _name.text.trim(),
      'description': _desc.text.trim(),
      'price': double.tryParse(_price.text) ?? 0.0,
      'new_price': _isOffer ? (double.tryParse(_newPrice.text) ?? 0.0) : null,
      'is_offer': _isOffer,
      'qty': int.tryParse(_qty.text) ?? 0,
      'category': _category.text.trim(),
      'image': _image.text.trim().isEmpty ? null : _image.text.trim(),
      'is_top_seller': _isTopSeller,
      'status': _status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isEdit = widget.product != null;
    return AlertDialog(
      title: Text(isEdit ? t.tr('edit_product') : t.tr('add_product')),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(labelText: t.tr('name'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  validator: (v) => (v == null || v.trim().isEmpty) ? t.tr('required_field') : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  decoration: InputDecoration(labelText: t.tr('description'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        decoration: InputDecoration(labelText: t.tr('price'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) => (v == null || double.tryParse(v) == null) ? t.tr('required_field') : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _qty,
                        decoration: InputDecoration(labelText: t.tr('qty'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null) ? t.tr('required_field') : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _category,
                  decoration: InputDecoration(labelText: t.tr('category'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _image,
                  decoration: InputDecoration(labelText: t.tr('image_url'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.tr('on_offer'), style: appStyle(14, FontWeight.w500, AppColors.textPrimary)),
                  value: _isOffer,
                  onChanged: (v) => setState(() => _isOffer = v ?? false),
                ),
                if (_isOffer)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _newPrice,
                      decoration: InputDecoration(labelText: t.tr('offer_price'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.tr('top_seller'), style: appStyle(14, FontWeight.w500, AppColors.textPrimary)),
                  value: _isTopSeller,
                  onChanged: (v) => setState(() => _isTopSeller = v ?? false),
                ),
                DropdownButtonFormField<int>(
                  value: _status,
                  decoration: InputDecoration(labelText: t.tr('status'), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: [
                    DropdownMenuItem(value: 1, child: Text(t.tr('active'))),
                    DropdownMenuItem(value: 0, child: Text(t.tr('inactive'))),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 1),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(t.tr('cancel'))),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.of(context).pop(_collect());
          },
          child: Text(t.tr('save')),
        ),
      ],
    );
  }
}
