import 'package:biopharmacy/utills/pharmacokinetics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleDoseCal extends StatefulWidget {
  const MultipleDoseCal({super.key});

  @override
  State<MultipleDoseCal> createState() => _MultipleDoseCalState();
}

class _MultipleDoseCalState extends State<MultipleDoseCal> {
  TextEditingController k_elim_controller = TextEditingController();
  TextEditingController vd_controller = TextEditingController();
  TextEditingController bioavalbility_controller = TextEditingController();
  TextEditingController MEC_controller = TextEditingController();
  TextEditingController MTC_controller = TextEditingController();

  double ta = 6;
  double dose_per_hour = 0;
  void calculate() {
    double mec = double.parse(MEC_controller.text);
    double mtc = double.parse(MTC_controller.text);
    double vd = double.parse(vd_controller.text);
    double ke = double.parse(k_elim_controller.text);
    double F = double.parse(bioavalbility_controller.text);
    double cpss = Pharmacokinetics.cBarSteadyStateFromMECandMTC(mec,mtc);
    setState(() {
      dose_per_hour = Pharmacokinetics.targetDosePerHour(cpss, vd, ke, F);
      ta = Pharmacokinetics.halfLifeFromK(ke);
    });
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
              _buildNumberInputField(k_elim_controller, 'K elimination',
                  'normal elimination constant'),
              _buildNumberInputField(
                  vd_controller, 'Vd', 'volume of Distribution'),
              _buildNumberInputField(
                  bioavalbility_controller,
                  'bio availability, F, 0-1',
                  'in case if its non iv, default: 1'),
              _buildNumberInputField(
                  MEC_controller, 'MEC', 'minimum effective concentration'),
              _buildNumberInputField(
                  MTC_controller, 'MTC', 'minimum toxic concentration'),
              Slider(value: ta, min: 0,max: 24*7,label: ta.toString(),divisions: ((24*7)/6).toInt(),onChanged: (value){
                setState(() {
                  ta = value;
                });
              }),
              ElevatedButton(
                onPressed: calculate,
                child: Text('calculate'),
              ),
              Text(
                'Dose Per $ta Hour: ${dose_per_hour*ta}',
                style: TextStyle(fontSize: 15, height: 2.5),
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
