import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../models/chartModels.dart';
import '../../utils/utils.dart';

import '../../widgets/data_grid_widget.dart';

class TrendsTable extends StatefulWidget {
  const TrendsTable({super.key});

  @override
  State<TrendsTable> createState() => _TrendsTableState();
}

class _TrendsTableState extends State<TrendsTable> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ValueListenableBuilder<int>(
          valueListenable: NudronChartMap.selectedMonth,
          builder: (context, value, child) {
            return DataGridWidget(
              data: Utils.sortTableDataByMonthDescending(
                      BlocProvider.of<DashboardBloc>(context)
                          .nudronChartData
                          ?.getCurrentTableData()) ??
                  [],
              exportToIncludeWholeData: true,
              columnsToTakeHeaderWidthAndExtraPadding: {
                0: 20,
              },
              key: UniqueKey(),
            );
          }),
    );
  }
}