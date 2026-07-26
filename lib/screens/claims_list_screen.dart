import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/claim_provider.dart';
import '../models/claim.dart';
import 'claim_details_screen.dart';

class ClaimsListScreen extends StatelessWidget {
  final String title;
  final ClaimStatus? filterStatus;

  const ClaimsListScreen({
    super.key,
    required this.title,
    this.filterStatus,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClaimProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    final filteredClaims = filterStatus == null
        ? provider.claims
        : provider.claims.where((c) => c.status == filterStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF003366),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search claims...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF003366)),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: filteredClaims.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No claims found',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredClaims.length,
              itemBuilder: (context, index) {
                final claim = filteredClaims[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              claim.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003366),
                                fontSize: 16,
                              ),
                            ),
                            _buildStatusBadge(claim.status),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildDetailRow('Creditor Name', claim.creditorName),
                        _buildDetailRow('Form Type', 'Form ${claim.formType.name.toUpperCase()}'),
                        _buildDetailRow('Claim Amount', currencyFormat.format(claim.amount)),
                        _buildDetailRow('RP / IRP', claim.rpId),
                        _buildDetailRow('Last Updated', dateFormat.format(claim.lastUpdated)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ClaimDetailsScreen(claim: claim),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF003366)),
                              foregroundColor: const Color(0xFF003366),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('VIEW FULL DETAILS'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ClaimStatus status) {
    Color color = Colors.grey;
    String text = status.name;

    switch (status) {
      case ClaimStatus.draft:
        color = Colors.grey;
        text = 'Draft';
        break;
      case ClaimStatus.submitted:
        color = Colors.orange;
        text = 'Submitted';
        break;
      case ClaimStatus.underVerification:
        color = Colors.blue;
        text = 'Under Verification';
        break;
      case ClaimStatus.admitted:
        color = Colors.green;
        text = 'Admitted';
        break;
      case ClaimStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case ClaimStatus.clarificationRequired:
        color = Colors.purple;
        text = 'Clarification Req.';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
