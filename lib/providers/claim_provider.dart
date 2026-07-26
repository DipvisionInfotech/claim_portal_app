import 'package:flutter/foundation.dart';
import '../models/claim.dart';
import '../models/claim_form.dart';

class ClaimProvider with ChangeNotifier {
  final List<Claim> _claims = [
    Claim(
      id: 'CLM000123',
      creditorName: 'ABC Traders',
      formType: FormType.b,
      amount: 500000,
      status: ClaimStatus.underVerification,
      rpId: 'RP001',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Claim(
      id: 'CLM000122',
      creditorName: 'Global Suppliers Pvt Ltd',
      formType: FormType.c,
      amount: 1250000,
      status: ClaimStatus.submitted,
      rpId: 'RP001',
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Claim(
      id: 'CLM000121',
      creditorName: 'XYZ Services',
      formType: FormType.d,
      amount: 275000,
      status: ClaimStatus.draft,
      rpId: 'RP001',
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  List<Claim> get claims => [..._claims];

  void addClaim(Claim claim) {
    _claims.insert(0, claim);
    notifyListeners();
  }

  int countByStatus(ClaimStatus status) {
    return _claims.where((c) => c.status == status).length;
  }

  int get totalClaims => _claims.length;
}
