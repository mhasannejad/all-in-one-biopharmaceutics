import 'dart:math';

import 'package:editable/editable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class ExtraVascularPathCal extends StatefulWidget {
  const ExtraVascularPathCal({super.key});

  @override
  State<ExtraVascularPathCal> createState() => _ExtraVascularPathCalState();
}

class _ExtraVascularPathCalState extends State<ExtraVascularPathCal> {
  final _editableTableKey = GlobalKey<EditableState>();

  int rowCount = 1;
  List cols = [
    {"title": 'Time (h or min)', 'widthFactor': 0.5, 'key': 'time'},
    {"title": 'Cp', 'widthFactor': 0.5, 'key': 'cp'},
  ];
  List rows = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('elimination k Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => updateRowCount(rowCount - 1),
                ),
                Text('Rows: ${rows.length}'),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => updateRowCount(rowCount + 1),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Editable(
                  key: _editableTableKey,
                  columns: cols,
                  rowCount: rows.length,
                  thStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  rows: rows,
                  tdStyle: TextStyle(fontSize: 16),
                  borderColor: Colors.grey.shade300,
                  onSubmitted: (row) {
                    // Handle changes when a cell is edited
                    // You can update your data model here
                    print('Edited row: $row');
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                var inputs =
                    _editableTableKey.currentState!.editedRows.toList();
                List<List<dynamic>> data = [
                  ['row', 'time', 'cp', 'diff']
                ];
                List<List<dynamic>> data_for_regresion = [
                  ['time', 'log_diff']
                ];
                List<double> x = [];
                List<double> y = [];
                var cpss = 0;
                for (var i in inputs) {
                  data.add([
                    i['row'],
                    i['time'],
                    i['cp'],
                    (cpss - double.parse(i['cp']))
                  ]);
                  data_for_regresion.add([
                    double.parse(i['time']),
                    log(cpss - double.parse(i['cp']))
                  ]);
                  x.add(double.parse(i['time']));
                  y.add(log(double.parse(i['cp'])));
                }
                ;

                double max_cp = y.reduce(max);
                int index_of_max = y.indexOf(max_cp);

                List<double> elim_phase_y = y.sublist(index_of_max);
                List<double> elim_phase_x = x.sublist(index_of_max);
                List<double> abs_phase_x = x.sublist(0, index_of_max);
                List<double> abs_phase_y = y.sublist(0, index_of_max);

                List<List<dynamic>> elim_phase = [
                  ['time', 'log_cp']
                ];
                List<List<dynamic>> abs_phase = [
                  ['time']
                ];

                for (double item in elim_phase_x) {
                  elim_phase
                      .add([item, elim_phase_y[elim_phase_x.indexOf(item)]]);
                }
                for (double item in abs_phase_x) {
                  abs_phase.add([item]);
                }

                var elim_df = DataFrame(elim_phase);
                var predict_abs_phase = DataFrame(abs_phase);
                final model =
                    LinearRegressor(elim_df, 'log_cp', fitIntercept: true);
                var predicted = model.predict(predict_abs_phase);
                var predicted_full =
                    predict_abs_phase.addSeries(predicted['log_cp']);
                var res = [
                  ['time', 'log_cp'] as Iterable<dynamic>
                ];

                var residuals = [
                  ['time', 'diff'] as Iterable<dynamic>
                ];
                predicted.rows.toList().asMap().forEach((key, value) {
                  residuals.add([abs_phase_x[key],(value.first-abs_phase_y[key])]);
                  print([abs_phase_x[key],(value.first-abs_phase_y[key])]);
                });
                DataFrame residual_df = DataFrame(residuals);

                res += predicted_full.toMatrix().toList() +
                    elim_df.toMatrix().toList();
                var predicted_plus_elim_phase = DataFrame(res);
                //predicted_plus_elim_phase. = [['time','log_cp']];
                final residual_model =
                LinearRegressor(residual_df, 'diff', fitIntercept: true);
                print(residual_model.coefficients);
                print(model.coefficients);
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        child: Column(
                          children: [
                            Expanded(
                              child: SfSparkLineChart.custom(
                                labelDisplayMode:
                                    SparkChartLabelDisplayMode.all,
                                dataCount: predicted_plus_elim_phase.rows.length,
                                xValueMapper: (index) => predicted_plus_elim_phase['time'].data.toList()[index],
                                yValueMapper: (index) => predicted_plus_elim_phase['log_cp'].data.toList()[index],
                              ),
                            ),Expanded(
                              child: SfSparkLineChart.custom(
                                labelDisplayMode:
                                    SparkChartLabelDisplayMode.all,
                                dataCount: x.length,
                                xValueMapper: (index) => x[index],
                                yValueMapper: (index) => y[index],
                              ),
                            ),
                            Text('Coefficents: ')
                          ],
                        ),
                      );
                    });
              },
              child: Text('Calculate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInputField(
      TextEditingController controller, String label, String helper) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        // Respond to changes in real time (you can add your logic here)
        print('$label: $value');
      },
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        hintText: 'Enter a number',
      ),
    );
  }

  updateRowCount(int i) {
    setState(() {
      _editableTableKey.currentState?.createRow();
    });
  }
}
