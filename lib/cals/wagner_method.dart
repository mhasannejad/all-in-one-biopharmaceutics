import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WagnerMethod extends StatefulWidget {
  const WagnerMethod({super.key});

  @override
  State<WagnerMethod> createState() => _WagnerMethodState();
}

class _WagnerMethodState extends State<WagnerMethod> {
  TextEditingController half_life_controller = TextEditingController();
  TextEditingController intended_time_controller = TextEditingController();
  TextEditingController Q2_controller = TextEditingController();

  double Q1 = 0;

  void calculate() {
    double half_life = double.parse(half_life_controller.text);
    double intended_time = double.parse(intended_time_controller.text);
    double Q2 = double.parse(Q2_controller.text);

    double N = intended_time / half_life;

    double Q1_to_Q2 = 1 / (1 - (pow(.5, N)));
    setState(() {
      Q1 = Q1_to_Q2 * Q2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('elimination k Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNumberInputField(
                  half_life_controller, 'Half Life (h)', 'drug half life (h)'),
              _buildNumberInputField(intended_time_controller,
                  'Intended time (h)', 'in how long do you need your Cpss?'),
              _buildNumberInputField(
                  Q2_controller,
                  'secondary flow rate (mg/h)',
                  'calculate Q2 using cpss = Q/cl'),
              ElevatedButton(
                onPressed: calculate,
                child: Text('calculate'),
              ),
              Text(
                'Q1 : set initial flow rate (mg/h) to: $Q1 \n' +
                    'drop per min:  \n',
                style: TextStyle(fontSize: 15, height: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
    ;
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
