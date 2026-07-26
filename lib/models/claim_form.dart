enum FormType {
  ca, // Financial Creditor in a Class
  c,  // Financial Creditor
  b,  // Operational Creditor
  d,  // Workman/Employee
  f,  // Other Creditor
  e   // Authorised Representative of Workmen/Employees
}

class ClaimForm {
  final FormType type;
  final String title;
  final String subtitle;
  final String regulation;

  ClaimForm({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.regulation,
  });
}
