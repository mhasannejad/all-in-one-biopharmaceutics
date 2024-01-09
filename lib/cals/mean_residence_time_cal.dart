import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MeanResidenceTimeCal extends StatefulWidget {
  const MeanResidenceTimeCal({super.key});

  @override
  State<MeanResidenceTimeCal> createState() => _MeanResidenceTimeCalState();
}

class _MeanResidenceTimeCalState extends State<MeanResidenceTimeCal> {
  TextEditingController k_elim_controller = TextEditingController();
  double MRT = 0;
  double k_elim = 0;
  void calculate_simple() {
    setState(() {
      k_elim = double.parse(k_elim_controller.text);
      MRT = 1/k_elim;
    });
  }
  void calculate_multi_compartment(){

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multiple Dose Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Non Compatmental and one-cpmpartmental model: MRT=1/k'),
              _buildNumberInputField(k_elim_controller, 'K', 'elimination constant'),
              ElevatedButton(
                onPressed: calculate_simple,
                child: Text('calculate'),
              ),
              Text(
                'Mean Residence time: $MRT',
                style: TextStyle(fontSize: 15, height: 2.5),
              ),
              Text('two-cpmpartmental model: MRT=1/k'),
              ElevatedButton(
                onPressed: calculate_multi_compartment,
                child: Text('calculate'),
              ),
            ],
          ),
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
}
