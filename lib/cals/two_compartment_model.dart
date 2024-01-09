import 'dart:math';

import 'package:editable/editable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class TwoCompartmentModel extends StatefulWidget {
  const TwoCompartmentModel({super.key});

  @override
  State<TwoCompartmentModel> createState() => _TwoCompartmentModelState();
}

class _TwoCompartmentModelState extends State<TwoCompartmentModel> {
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
      appBar: AppBar(title: Text('Two Compartment model')),
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

                // calculate this
                double beta = 0;
                double alpha = 0;


                var inputs =
                    _editableTableKey.currentState!.editedRows.toList();
                List<List<dynamic>> data = [
                  ['time', 'cp']
                ];
                List<double> x = [];
                List<double> y = [];
                for (var i in inputs) {
                  print([double.parse(i['cp']),log(double.parse(i['cp']))]);
                  data.add([
                    i['time'],
                    log(double.parse(i['cp'])),
                  ]);

                  x.add(double.parse(i['time']));
                  y.add(log(double.parse(i['cp'])));
                }
                List<List<dynamic>> last_four = [
                  ['time', 'cp']
                ];
                last_four
                    .addAll(data.toList().reversed.take(4).toList().reversed);

                List<List<dynamic>> first_3 = [
                  ['time', 'cp']
                ];
                List<List<dynamic>> first_3_residual = [
                  ['time', 'cp']
                ];
                List<List<dynamic>> first_3_x = [
                  ['time']
                ];
                for(int i in [0,1,2]){
                  first_3_x.add([x[i]]);
                }


                first_3.addAll(data.toList().reversed.take(3).toList().reversed);
                DataFrame B_post_distro = DataFrame(last_four);
                LinearRegressor B_model = LinearRegressor(B_post_distro, 'cp');
                var predicted_A = B_model.predict(DataFrame(first_3_x));

                for(int i in [0,1,2]){
                  first_3_residual.add([x[i],pow(e,y[i])-pow(e, predicted_A.rows.toList()[i].first)]);
                  print(y[i]);
                  print(predicted_A.rows.toList()[i]);
                  print([x[i],pow(e,y[i])-pow(e, predicted_A.rows.toList()[i].first)]);
                }
                beta = -1 * B_model.coefficients[1] ;
                LinearRegressor A_model = LinearRegressor(DataFrame(first_3_residual), 'cp');
                print(B_model.coefficients[1]*-1);
                print(A_model.coefficients);
                var first_3_res_display = first_3_residual.sublist(1);
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
                                dataCount: first_3_res_display.length,
                                xValueMapper: (index) => first_3_res_display[index][0],
                                yValueMapper: (index) => first_3_res_display[index][1],
                              ),
                            ),
                            Expanded(
                              child: SfSparkLineChart.custom(
                                labelDisplayMode:
                                    SparkChartLabelDisplayMode.all,
                                dataCount: x.length,
                                xValueMapper: (index) => x[index],
                                yValueMapper: (index) => y[index],
                              ),
                            ),
                            Text('Slope B: ${B_model.coefficients[1]} \n  '
                                'Slope A: ${A_model.coefficients[1]}')
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
