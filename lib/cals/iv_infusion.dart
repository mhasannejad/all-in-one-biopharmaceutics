import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IVInfusionCal extends StatefulWidget {
  const IVInfusionCal({super.key});

  @override
  State<IVInfusionCal> createState() => _IVInfusionCalState();
}

class _IVInfusionCalState extends State<IVInfusionCal> {
  TextEditingController clearance_controller = TextEditingController();
  TextEditingController c_steady_state_controller = TextEditingController();
  TextEditingController drug_dose_controller = TextEditingController();
  TextEditingController iv_volume_controller = TextEditingController();
  TextEditingController patient_wheigh_controller = TextEditingController();
  TextEditingController half_life_controller = TextEditingController();

  bool add_loading_dose = false;

  double Q = 0;
  double Dl = 0;
  void calculate(){
    double clearance = double.parse(clearance_controller.text);
    double c_ss = double.parse(clearance_controller.text);
    double dose = double.parse(drug_dose_controller.text);
    double iv_fluid = double.parse(iv_volume_controller.text);
    double half_life = double.parse(half_life_controller.text);

    setState(() {
      Q = c_ss*clearance;
      Dl = (Q*half_life)/0.693;

      double concenteration = dose/iv_fluid; // mg/ml
      double Q_mg_per_min = Q/60;
      // ondansetron concenteration 8mg in 1000 cc
      //
      // 1 ml = 20 drop
      //
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
              CheckboxListTile(value: add_loading_dose,title: Text('Include loading dose'), onChanged: (value){
                setState(() {
                  add_loading_dose = value!;
                });

              }),
              _buildNumberInputField(clearance_controller, 'Clearance',
                  'Clearance or (V.K)'),
              _buildNumberInputField(c_steady_state_controller, 'Cp(ss)', 'Steady State Concentration in plasma'),
              _buildNumberInputField(drug_dose_controller, 'Drug Dose (mg)', 'Drug amount injected in IV fluid '),
              _buildNumberInputField(iv_volume_controller, 'IV fluid Volume (ml)', 'total volume of IV fluide  '),
              _buildNumberInputField(patient_wheigh_controller, 'Patient Weight (kg)', 'patient weight'),
              Container(
                child: add_loading_dose?_buildNumberInputField(half_life_controller, 'Half life (h)', 'half life for ib bolus calculation'):Container(),
              ),
              ElevatedButton(
                onPressed: calculate,
                child: Text('calculate'),
              ),
              Text(
                'Q :flow rate (mg/h) : $Q \n'+
                'drop per min:  \n',style: TextStyle(fontSize: 15,height: 2.5),
              ),
              Container(
                child: add_loading_dose?Text(
                'Loading dose: $Dl',style: TextStyle(fontSize: 15,height: 2.5)):Container(),
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
