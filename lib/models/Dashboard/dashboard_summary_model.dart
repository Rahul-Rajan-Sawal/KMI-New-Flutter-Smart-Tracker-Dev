class DashboardSummary {
  final int convertedCount;
  final double convertedAmount;

  final int lostCount;
  final double lostAmount;

  final int openCount;
  final double openAmount;

  final int salesCloseCount;
  final double salesCloseAmount;

  final int totalLeads;
  final double totalGwp;

  // Lost sub status
  final int lostToCompetitionCount;
  final int notRespondingCount;
  final int notInterestedCount;

  // Open sub status
  final int parkedCount;
  final int followUpCount;
  final double parkedAmount;
  final double followUpAmount;

  // Sales Closed sub status
  final int premiumCollectedCount;
  final int policyIssuedCount;

  DashboardSummary({
    required this.totalLeads,
    required this.totalGwp,
    required this.convertedCount,
    required this.convertedAmount,
    required this.lostCount,
    required this.lostAmount,
    required this.openCount,
    required this.openAmount,
    required this.salesCloseCount,
    required this.salesCloseAmount,

    this.lostToCompetitionCount = 0,
    this.notRespondingCount = 0,
    this.notInterestedCount = 0,
    this.parkedCount = 0,
    this.followUpCount = 0,
    this.parkedAmount = 0,
    this.followUpAmount = 0,
    this.premiumCollectedCount = 0,
    this.policyIssuedCount = 0,
  });

  double _calculate(int value) {
    if (totalLeads == 0) return 0.0;
    return (value * 100) / totalLeads;
  }

  double get convertedPercentage => _calculate(convertedCount);
  double get lostPercentage => _calculate(lostCount);
  double get openPercentage => _calculate(openCount);
  double get salesClosedPercentage => _calculate(salesCloseCount);
}
