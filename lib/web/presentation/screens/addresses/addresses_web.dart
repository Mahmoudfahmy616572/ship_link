import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/screens/addresses/location_picker_web.dart';
import 'package:ship_link/web/presentation/shared/shimmer.dart';
import 'package:ship_link/web/presentation/shared/hover_widget.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressesWeb extends StatefulWidget {
  const AddressesWeb({super.key});
  static String routName = '/addresses';

  @override
  State<AddressesWeb> createState() => _AddressesWebState();
}

class _AddressesWebState extends State<AddressesWeb> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _addresses = [];
  bool _loading = true;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('user_addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      if (mounted) setState(() => _addresses = List<Map<String, dynamic>>.from(data));
    }
    if (mounted) { setState(() => _loading = false); _animCtrl.forward(); }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.tr('delete_address')),
        content: Text(context.t.tr('are_you_sure_delete_address')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.t.tr('cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.t.tr('delete'), style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;
    await Supabase.instance.client.from('user_addresses').delete().eq('id', id);
    _load();
  }

  Future<void> _setDefault(String id) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('user_addresses').update({'is_default': false}).eq('user_id', user.id);
    await Supabase.instance.client.from('user_addresses').update({'is_default': true}).eq('id', id);
    _load();
  }

  void _showForm({Map<String, dynamic>? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _AddressForm(address: address, onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('address_book')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      floatingActionButton: HoverScale(
        onTap: () => _showForm(),
        child: FloatingActionButton(
          onPressed: () => _showForm(),
          backgroundColor: AppColors.cta,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: _loading
          ? Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: List.generate(3, (_) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerBox(height: 100, radius: 16),
              ))),
            )
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off_outlined, size: 64, color: const Color(0xFFD1D5DB)),
                      SizedBox(height: 16),
                      Text(context.t.tr('no_addresses'),
                          style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
                      SizedBox(height: 8),
                      Text(context.t.tr('tap_add_address'),
                          style: appStyle(13, FontWeight.w400, const Color(0xFFD1D5DB))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 80),
                  itemCount: _addresses.length,
                  itemBuilder: (_, i) {
                    final addr = _addresses[i];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (i * 80)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)), child: child,
                      )),
                      child: _AddressCard(
                        address: addr,
                        onDelete: () => _delete(addr['id']),
                        onSetDefault: () => _setDefault(addr['id']),
                        onEdit: () => _showForm(address: addr),
                      ),
                    );
                  },
                ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> address;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;

  const _AddressCard({required this.address, required this.onDelete, required this.onSetDefault, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isDefault = address['is_default'] == true;
    return HoverScale(
      scale: 1.01,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDefault ? AppColors.cta : const Color(0xFFE5E7EB), width: isDefault ? 1.5 : 1),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: isDefault ? null : onSetDefault,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          isDefault ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          size: 22, color: isDefault ? AppColors.cta : const Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 18,
                                    color: isDefault ? AppColors.cta : const Color(0xFF9CA3AF)),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(address['label'] ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
                                ),
                                if (isDefault) ...[
                                  SizedBox(width: 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.cta.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(context.t.tr('default_address'),
                                        style: appStyle(10, FontWeight.w600, AppColors.cta)),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 6),
                            _detail(context.t.tr('city'), address['city'] ?? ''),
                            if ((address['street'] ?? '').isNotEmpty)
                              _detail(context.t.tr('street'), address['street']),
                            if ((address['building'] ?? '').isNotEmpty || (address['apartment'] ?? '').isNotEmpty)
                              _detail('${context.t.tr('building')}/${context.t.tr('apt')}',
                                  '${address['building'] ?? ''}${address['apartment'] != null ? ' / ${context.t.tr('apt')} ${address['apartment']}' : ''}'),
                            if ((address['full_address'] ?? '').isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Text(address['full_address'],
                                    style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: Padding(
                padding: EdgeInsets.only(top: 12, right: 8, left: 8),
                child: Icon(Icons.more_vert, size: 20, color: const Color(0xFF9CA3AF)),
              ),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'default') onSetDefault();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                if (!isDefault)
                  PopupMenuItem(value: 'default', child: Text(context.t.tr('set_as_default'))),
                PopupMenuItem(value: 'edit', child: Text(context.t.tr('edit'))),
                PopupMenuItem(value: 'delete', child: Text(context.t.tr('delete'), style: TextStyle(color: AppColors.error))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('$label: ', style: appStyle(12, FontWeight.w500, const Color(0xFF9CA3AF))),
          Text(value, style: appStyle(13, FontWeight.w500, const Color(0xFF111827))),
        ],
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  final Map<String, dynamic>? address;
  final VoidCallback onSaved;
  const _AddressForm({this.address, required this.onSaved});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  late TextEditingController _labelCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _buildingCtrl;
  late TextEditingController _apartmentCtrl;
  late TextEditingController _fullAddressCtrl;
  double? _lat;
  double? _lng;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.address?['label'] ?? '');
    _cityCtrl = TextEditingController(text: widget.address?['city'] ?? '');
    _streetCtrl = TextEditingController(text: widget.address?['street'] ?? '');
    _buildingCtrl = TextEditingController(text: widget.address?['building'] ?? '');
    _apartmentCtrl = TextEditingController(text: widget.address?['apartment'] ?? '');
    _fullAddressCtrl = TextEditingController(text: widget.address?['full_address'] ?? '');
    _lat = (widget.address?['latitude'] as num?)?.toDouble();
    _lng = (widget.address?['longitude'] as num?)?.toDouble();
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _cityCtrl.dispose();
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _apartmentCtrl.dispose();
    _fullAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final data = {
        'user_id': user.id,
        'label': _labelCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'street': _streetCtrl.text.trim(),
        'building': _buildingCtrl.text.trim(),
        'apartment': _apartmentCtrl.text.trim(),
        'full_address': _fullAddressCtrl.text.trim(),
        'latitude': _lat,
        'longitude': _lng,
      };
      if (widget.address == null) {
        final existing = await Supabase.instance.client
            .from('user_addresses')
            .select('id')
            .eq('user_id', user.id)
            .limit(1);
        if (existing.isEmpty) data['is_default'] = true;
        await Supabase.instance.client.from('user_addresses').insert(data);
      } else {
        await Supabase.instance.client.from('user_addresses').update(data).eq('id', widget.address!['id']);
      }
      if (mounted) Navigator.pop(context);
      widget.onSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: 16),
            Text(widget.address == null ? context.t.tr('add_address') : context.t.tr('edit_address'),
                style: appStyle(20, FontWeight.w700, const Color(0xFF111827))),
            SizedBox(height: 20),
            _field(context.t.tr('label'), _labelCtrl, hint: 'Home, Work, Other'),
            SizedBox(height: 12),
            _field(context.t.tr('city'), _cityCtrl),
            SizedBox(height: 12),
            _field(context.t.tr('street'), _streetCtrl),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field(context.t.tr('building'), _buildingCtrl)),
                SizedBox(width: 12),
                Expanded(child: _field(context.t.tr('apartment'), _apartmentCtrl)),
              ],
            ),
            SizedBox(height: 12),
            _field(context.t.tr('full_address'), _fullAddressCtrl, hint: context.t.tr('enter_address_manually'), maxLines: 2),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 44,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(builder: (_) => const LocationPickerWeb()),
                  );
                  if (result != null && mounted) {
                    setState(() {
                      _lat = (result['latitude'] as num?)?.toDouble();
                      _lng = (result['longitude'] as num?)?.toDouble();
                      _cityCtrl.text = result['city'] as String? ?? _cityCtrl.text;
                      _streetCtrl.text = result['street'] as String? ?? _streetCtrl.text;
                      _fullAddressCtrl.text = result['full_address'] as String? ??
                          '${result['latitude']}, ${result['longitude']}';
                    });
                  }
                },
                icon: Icon(Icons.map_outlined, size: 18),
                label: Text(context.t.tr('pick_from_maps'),
                    style: appStyle(14, FontWeight.w500, AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cta,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.address == null ? context.t.tr('save_address') : context.t.tr('update_address'),
                        style: appStyle(16, FontWeight.w600, Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: appStyle(12, FontWeight.w500, const Color(0xFF6B7280))),
        SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: appStyle(15, FontWeight.w500, const Color(0xFF111827)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: appStyle(13, FontWeight.w400, const Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
