import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading {
  ShimmerLoading._();

  static Widget list({int itemCount = 5}) {
    return _ShimmerPreset(itemCount: itemCount, type: _ShimmerType.list);
  }

  static Widget grid({int itemCount = 6}) {
    return _ShimmerPreset(itemCount: itemCount, type: _ShimmerType.grid);
  }

  static Widget productDetail() {
    return const _ShimmerPreset(itemCount: 1, type: _ShimmerType.productDetail);
  }

  static Widget searchList({int itemCount = 5}) {
    return _ShimmerPreset(itemCount: itemCount, type: _ShimmerType.searchList);
  }

  static Widget orderHistory({int itemCount = 5}) {
    return _ShimmerPreset(itemCount: itemCount, type: _ShimmerType.orderHistory);
  }

  static Widget horizontalScroll({int itemCount = 5}) {
    return _ShimmerPreset(itemCount: itemCount, type: _ShimmerType.horizontalScroll);
  }
}

enum _ShimmerType { list, grid, productDetail, searchList, orderHistory, horizontalScroll }

class _ShimmerPreset extends StatelessWidget {
  final int itemCount;
  final _ShimmerType type;

  const _ShimmerPreset({required this.itemCount, required this.type});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: type == _ShimmerType.grid
            ? _buildGrid()
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: itemCount,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemBuilder: (_, __) => _buildItem(),
              ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12.h, width: double.infinity, color: Colors.grey[300]),
                  SizedBox(height: 6.h),
                  Container(height: 12.h, width: 60.w, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem() {
    switch (type) {
      case _ShimmerType.list:
        return _buildCartItem();
      case _ShimmerType.searchList:
        return _buildSearchItem();
      case _ShimmerType.orderHistory:
        return _buildOrderItem();
      case _ShimmerType.productDetail:
        return _buildProductDetail();
      case _ShimmerType.horizontalScroll:
        return _buildHorizontalScroll();
      default:
        return _buildCartItem();
    }
  }

  Widget _baseItem(Widget leading, Widget body) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          leading,
          SizedBox(width: 14.w),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _shimmerBox(double w, double h, [double radius = 8]) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildCartItem() {
    return _baseItem(
      _shimmerBox(80.w, 80.h),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(double.infinity, 14.h),
          SizedBox(height: 8.h),
          _shimmerBox(80.w, 14.h),
          SizedBox(height: 8.h),
          _shimmerBox(60.w, 14.h),
        ],
      ),
    );
  }

  Widget _buildSearchItem() {
    return _baseItem(
      _shimmerBox(70.w, 70.h),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(double.infinity, 14.h),
          SizedBox(height: 6.h),
          _shimmerBox(100.w, 14.h),
          SizedBox(height: 6.h),
          _shimmerBox(60.w, 14.h),
        ],
      ),
    );
  }

  Widget _buildOrderItem() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _shimmerBox(44.w, 44.h, 10),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(120.w, 14.h),
                SizedBox(height: 6.h),
                _shimmerBox(80.w, 12.h),
                SizedBox(height: 4.h),
          _shimmerBox(60.w, 14.h),
              ],
            ),
          ),
          _shimmerBox(70.w, 24.h, 20),
        ],
      ),
    );
  }

  Widget _buildHorizontalScroll() {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(left: 12.w),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          width: 160.w,
          margin: EdgeInsets.only(right: 12.w, bottom: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(120.w, 12.h),
                    SizedBox(height: 6.h),
                    _shimmerBox(80.w, 14.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetail() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(double.infinity, 250.h, 12),
          SizedBox(height: 20.h),
          _shimmerBox(100.w, 22.h),
          SizedBox(height: 20.h),
          _shimmerBox(double.infinity, 60.h),
          SizedBox(height: 16.h),
          _shimmerBox(double.infinity, 14.h),
          SizedBox(height: 6.h),
          _shimmerBox(double.infinity, 14.h),
          SizedBox(height: 6.h),
          _shimmerBox(200.w, 14.h),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(180.w, 20.h),
              Row(
                children: [
                  _shimmerBox(36.w, 36.h, 18),
                  SizedBox(width: 12.w),
                  _shimmerBox(20.w, 16.h),
                  SizedBox(width: 12.w),
                  _shimmerBox(36.w, 36.h, 18),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _shimmerBox(double.infinity, 50.h, 12),
        ],
      ),
    );
  }
}
