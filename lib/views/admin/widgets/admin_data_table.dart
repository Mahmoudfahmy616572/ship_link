import 'package:flutter/material.dart';
import '../../shared/app_style.dart';
import 'package:ship_link/utils/sizer.dart';

class AdminDataTable extends StatelessWidget {
  final List<String> columns;
  final List<DataRow> rows;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: columns
                .map((c) => DataColumn(
                    label: Text(c,
                        style: appStyle(14, FontWeight.bold, Colors.black87))))
                .toList(),
            rows: rows,
          ),
        ),
      ),
    );
  }
}