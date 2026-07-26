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
  final DateTime submissionDate;
  final List<ClaimAttachment> attachments;
  final Map<String, String> particulars;

  Claim({
    required this.id,
    required this.creditorName,
    required this.formType,
    required this.amount,
    required this.status,
    required this.rpId,
    required this.lastUpdated,
    required this.submissionDate,
    this.attachments = const [],
    this.particulars = const {},
  });
}

class ClaimAttachment {
  final String name;
  final String type; // e.g., 'PDF', 'Image'
  final String size;
  final DateTime uploadDate;

  ClaimAttachment({
    required this.name,
    required this.type,
    required this.size,
    required this.uploadDate,
  });
}
