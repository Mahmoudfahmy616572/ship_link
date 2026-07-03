import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/shared/shimmer/shimmer_loading.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/user/screens/location_picker/location_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});
  static String routName = '/addressBook';

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _loading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('user_addresses')
          .select()
          .eq('user_id', user.id)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      if (mounted) setState(() => _addresses = data);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _deleteAddress(String id) async {
    await Supabase.instance.client.from('user_addresses').delete().eq('id', id);
    _loadAddresses();
  }

  Future<void> _setDefault(String id) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client
          .from('user_addresses')
          .update({'is_default': false}).eq('user_id', user.id);
      await Supabase.instance.client
          .from('user_addresses')
          .update({'is_default': true}).eq('id', id);
      _loadAddresses();
      if (mounted) {
        CustomSnackBar.displaySuccessMotionToast(
            context.t.tr('set_default_success'), context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.displayErrorMotionToast(e.toString(), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Sizer.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          context.t.tr('address_book'),
          style: appStyle(22, FontWeight.w700, AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddressForm(context),
        backgroundColor: AppColors.cta,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? ShimmerLoading.list()
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined,
                          size: 64.r, color: AppColors.textHint),
                      SizedBox(height: 16.h),
                      Text(
                        context.t.tr('no_addresses'),
                        style: appStyle(16, FontWeight.w500, AppColors.textSecondary),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        context.t.tr('tap_add_address'),
                        style: appStyle(13, FontWeight.w400, AppColors.textDisabled),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 80.h),
                  itemCount: _addresses.length,
                  itemBuilder: (_, i) {
                    final addr = _addresses[i];
                    return _AddressCard(
                      address: addr,
                      onDelete: () => _deleteAddress(addr['id']),
                      onSetDefault: () => _setDefault(addr['id']),
                      onEdit: () => _showAddressForm(context, address: addr),
                    );
                  },
                ),
    );
  }

  void _showAddressForm(BuildContext context, {Map<String, dynamic>? address}) {
    final labelCtrl = TextEditingController(text: address?['label'] ?? '');
    final cityCtrl = TextEditingController(text: address?['city'] ?? '');
    final streetCtrl = TextEditingController(text: address?['street'] ?? '');
    final buildingCtrl = TextEditingController(text: address?['building'] ?? '');
    final apartmentCtrl = TextEditingController(text: address?['apartment'] ?? '');
    final fullAddressCtrl = TextEditingController(text: address?['full_address'] ?? '');
    double? pickedLat = (address?['latitude'] as num?)?.toDouble();
    double? pickedLng = (address?['longitude'] as num?)?.toDouble();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 20.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      address == null ? context.t.tr('add_address') : context.t.tr('edit_address'),
                      style: appStyle(20, FontWeight.w700, AppColors.textPrimary),
                    ),
                    SizedBox(height: 20.h),
                    _formField(context.t.tr('label'), labelCtrl, hint: 'Home, Work, Other'),
                    SizedBox(height: 12.h),
                    _formField(context.t.tr('city'), cityCtrl),
                    SizedBox(height: 12.h),
                    _formField(context.t.tr('street'), streetCtrl),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _formField(context.t.tr('building'), buildingCtrl),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _formField(context.t.tr('apartment'), apartmentCtrl),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _formField(context.t.tr('full_address'), fullAddressCtrl,
                        hint: context.t.tr('enter_address_manually'),
                        maxLines: 2),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LocationPicker(
                                isAddressPicker: true,
                              ),
                            ),
                          );
                          if (result != null && context.mounted) {
                            setSheetState(() {
                              pickedLat = (result['latitude'] as num?)?.toDouble();
                              pickedLng = (result['longitude'] as num?)?.toDouble();
                              cityCtrl.text = result['city'] as String? ?? cityCtrl.text;
                              streetCtrl.text = result['street'] as String? ?? streetCtrl.text;
                              fullAddressCtrl.text = result['full_address'] as String? ??
                                  '${result['latitude']}, ${result['longitude']}';
                            });
                          }
                        },
                        icon: Icon(Icons.map_outlined, size: 18.r),
                        label: Text(context.t.tr('pick_from_maps'),
                            style: appStyle(14, FontWeight.w500, AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: saving
                            ? null
                            : () async {
                                setSheetState(() => saving = true);
                                try {
                                  final user = Supabase.instance.client.auth.currentUser;
                                  if (user == null) return;
                                  final data = {
                                    'user_id': user.id,
                                    'label': labelCtrl.text.trim(),
                                    'city': cityCtrl.text.trim(),
                                    'street': streetCtrl.text.trim(),
                                    'building': buildingCtrl.text.trim(),
                                    'apartment': apartmentCtrl.text.trim(),
                                    'full_address': fullAddressCtrl.text.trim(),
                                    'latitude': pickedLat,
                                    'longitude': pickedLng,
                                  };
                                  if (address == null) {
                                    // Auto-set as default if user has no addresses
                                    final existing = await Supabase.instance.client
                                        .from('user_addresses')
                                        .select('id')
                                        .eq('user_id', user.id)
                                        .limit(1);
                                    if (existing.isEmpty) {
                                      data['is_default'] = true;
                                    }
                                    await Supabase.instance.client
                                        .from('user_addresses')
                                        .insert(data);
                                  } else {
                                    await Supabase.instance.client
                                        .from('user_addresses')
                                        .update(data)
                                        .eq('id', address['id']);
                                  }
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  _loadAddresses();
                                } catch (e) {
                                  if (mounted) {
                                    CustomSnackBar.error(e.toString(), context);
                                  }
                                } finally {
                                  setSheetState(() => saving = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        child: saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                address == null ? context.t.tr('save_address') : context.t.tr('update_address'),
                                style: appStyle(16, FontWeight.w600, Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _formField(String label, TextEditingController ctrl,
      {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: appStyle(12, FontWeight.w500, AppColors.textSecondary)),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: appStyle(15, FontWeight.w500, AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: appStyle(13, FontWeight.w400, AppColors.textHint),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> address;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;

  const _AddressCard({
    required this.address,
    required this.onDelete,
    required this.onSetDefault,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = address['is_default'] == true;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDefault ? AppColors.cta : AppColors.border,
          width: isDefault ? 1.5 : 1,
        ),
        color: AppColors.surface,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isDefault ? null : onSetDefault,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Icon(
                        isDefault
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 22.r,
                        color: isDefault ? AppColors.cta : AppColors.textHint,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 18.r, color: isDefault ? AppColors.cta : AppColors.textHint),
                              SizedBox(width: 6.w),
                              Flexible(
                                child: Text(
                                  address['label'] ?? 'Address',
                                  overflow: TextOverflow.ellipsis,
                                  style: appStyle(15, FontWeight.w600, AppColors.textPrimary),
                                ),
                              ),
                              if (isDefault) ...[
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.cta.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Text(context.t.tr('default_address'),
                                      style: appStyle(10, FontWeight.w600, AppColors.cta)),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 6.h),
                          _detail(context.t.tr('city'), address['city'] ?? ''),
                          if ((address['street'] ?? '').isNotEmpty)
                            _detail(context.t.tr('street'), address['street']),
                          if ((address['building'] ?? '').isNotEmpty ||
                              (address['apartment'] ?? '').isNotEmpty)
                            _detail('${context.t.tr('building')}/${context.t.tr('apt')}',
                                '${address['building'] ?? ''}${address['apartment'] != null ? ' / ${context.t.tr('apt')} ${address['apartment']}' : ''}'),
                          if ((address['full_address'] ?? '').isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: Text(address['full_address'],
                                  style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
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
              padding: EdgeInsets.only(top: 12.h, right: 8.w, left: 8.w),
              child: Icon(Icons.more_vert, size: 20.r, color: AppColors.textHint),
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
              PopupMenuItem(
                value: 'delete',
                child: Text(context.t.tr('delete'), style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: appStyle(12, FontWeight.w500, AppColors.textHint)),
          Expanded(
            child: Text(value,
                style: appStyle(13, FontWeight.w500, AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
