enum FundCategory { fpv, fic }

class Fund {
  final String id;
  final String name;
  final double minimumAmount;
  final FundCategory category;

  const Fund({
    required this.id,
    required this.name,
    required this.minimumAmount,
    required this.category,
  });

  String get categoryLabel => category == FundCategory.fpv ? 'FPV' : 'FIC';
}
