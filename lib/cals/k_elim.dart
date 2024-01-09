import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KElimImpairedRenal extends StatefulWidget {
  const KElimImpairedRenal({super.key});

  @override
  State<KElimImpairedRenal> createState() => _KElimImpairedRenalState();
}

class _KElimImpairedRenalState extends State<KElimImpairedRenal> {
  TextEditingController k_elim_controller = TextEditingController();
  TextEditingController fe_controller = TextEditingController();
  TextEditingController renal_function_controller = TextEditingController();

  double k_elim = 0.0;
  double fe = 0.0;
  double renal_ratio = 0.0;

  double normal_halflife = 0.0;
  double normal_ke = 0.0;
  double normal_km = 0.0;
  double patient_ke = 0.0;
  double patient_km = 0.0;
  double patient_kel = 0.0;
  double patient_halflife = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void calculate() {
    k_elim = double.parse(k_elim_controller.text);
    fe = double.parse(fe_controller.text);
    renal_ratio = double.parse(renal_function_controller.text);

    setState(() {
      normal_halflife = 0.693 / k_elim.toDouble();
      normal_ke = k_elim * fe.toDouble() ;
      normal_km = k_elim - normal_ke;
      patient_ke = renal_ratio*normal_ke/100;
      patient_km = normal_km;
      patient_kel = patient_km + patient_ke;
      patient_halflife = 0.693/patient_kel;
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
              _buildNumberInputField(k_elim_controller, 'K elimination',
                  'normal elimination constant'),
              _buildNumberInputField(fe_controller, 'Fe', 'normal Fe'),
              _buildNumberInputField(
                  renal_function_controller, 'in percent', 'renal function'),
              ElevatedButton(
                onPressed: calculate,
                child: Text('calculate'),
              ),
              Text(
                  'normal t1/2 \t => \t ' + '$normal_halflife'+ '\n'+
                  'normal ke  \t => \t ' + '$normal_ke'+ '\n'+
                  'normal km \t => \t ' + '$normal_km'+ '\n'+
                  'patient ke \t => \t ' + '$patient_ke'+ '\n'+
                  'patient km \t => \t ' + '$patient_km'+ '\n'+
                  'patient kel \t => \t ' + '$patient_kel'+ '\n'
                  'patient t1/2 \t => \t ' + '$patient_halflife'+ '\n',style: TextStyle(fontSize: 15,height: 2.5),
                      )
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
