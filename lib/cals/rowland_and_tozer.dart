import 'dart:convert';
import 'dart:math';
import 'package:editable/editable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class RowlandAndTozer extends StatefulWidget {
  const RowlandAndTozer({super.key});

  @override
  State<RowlandAndTozer> createState() => _RowlandAndTozerState();
}

class _RowlandAndTozerState extends State<RowlandAndTozer> {
  final _editableTableKey = GlobalKey<EditableState>();

  TextEditingController cpss_controller = TextEditingController();

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
            _buildNumberInputField(
                cpss_controller, 'Cpss', 'level of intended Cpss'),
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
                var cpss = double.parse(cpss_controller.text);
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
                  y.add(log(cpss - double.parse(i['cp'])));
                }

                var dataframe = DataFrame(data_for_regresion);
                final model =
                    LinearRegressor(dataframe, 'log_diff', fitIntercept: true);
                print(dataframe);
                print(model.coefficients);
                print(model.interceptScale);
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Expanded(
                              child: SfSparkLineChart.custom(
                                labelDisplayMode: SparkChartLabelDisplayMode.all,
                                dataCount: x.length,
                                xValueMapper: (index) => x[index],
                                yValueMapper: (index) => y[index],
                              ),
                            ),
                            Text('Coefficents: ${model.coefficients}')
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
