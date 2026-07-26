import 'claim_form.dart';

enum ClaimStatus {
  draft,
  submitted,
  underVerification,
  admitted,
  rejected,
  clarificationRequired
}

class Claim {
  final String id;
  final String creditorName;
  final FormType formType;
  final double amount;
  final ClaimStatus status;
  final String rpId;
  final DateTime lastUpdated;

  Claim({
    required this.id,
    required this.creditorName,
    required this.formType,
    required this.amount,
    required this.status,
    required this.rpId,
    required this.lastUpdated,
  });
}
