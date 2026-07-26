import 'package:flutter/foundation.dart';
import '../models/claim.dart';

class ClaimProvider with ChangeNotifier {
  final List<Claim> _claims = [];

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
