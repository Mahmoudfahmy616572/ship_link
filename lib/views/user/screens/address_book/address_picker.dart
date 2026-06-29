import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/views/shared/app_style.dart';

class AddressPicker extends StatefulWidget {
  final List<Map<String, dynamic>> addresses;

  const AddressPicker({super.key, required this.addresses});

  @override
  State<AddressPicker> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    final defaultIdx = widget.addresses.indexWhere((a) => a['is_default'] == true);
    _selectedIndex = defaultIdx >= 0 ? defaultIdx : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text('Select Delivery Address',
                style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
          ),
          SizedBox(height: 8.h),
          ...List.generate(widget.addresses.length, (i) {
            final addr = widget.addresses[i];
            final isSelected = _selectedIndex == i;
            final lat = (addr['latitude'] as num?)?.toDouble();
            final lng = (addr['longitude'] as num?)?.toDouble();
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = i),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.location_on_outlined,
                          color: AppColors.primary, size: 22),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(addr['label'] ?? 'Address',
                                  style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
                              if (addr['is_default'] == true) ...[
                                SizedBox(width: 6.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.cta.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('Default', style: appStyle(9, FontWeight.w600, AppColors.cta)),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${addr['city'] ?? ''}${addr['street'] != null ? ', ${addr['street']}' : ''}',
                            style: appStyle(12, FontWeight.w400, const Color(0xFF6B7280)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (lat != null && lng != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Map',
                            style: appStyle(11, FontWeight.w500,
                                isSelected ? AppColors.primary : const Color(0xFF9CA3AF))),
                      ),
                    SizedBox(width: 4.w),
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? AppColors.primary : const Color(0xFFD1D5DB),
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 24.h),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  final selected = widget.addresses[_selectedIndex!];
                  Navigator.pop(context, selected);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF242424),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Confirm Address',
                    style: appStyle(16, FontWeight.w600, Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
