class Pharmacokinetics {
  static double targetDosePerHour(
      double cpss, double volumeOfDistribution, double k, double F) {
    // cpss*vd*k = X0/T
    return cpss * volumeOfDistribution * k;
  }

  static double cBarSteadyStateFromMECandMTC(double MEC, double MTC) {
    return (MEC + MTC) / 2;
  }

  static double halfLifeFromK(double k){
    return .693/k;
  }

}
