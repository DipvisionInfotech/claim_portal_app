import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/claim.dart';

class ClaimDetailsScreen extends StatelessWidget {
  final Claim claim;

  const ClaimDetailsScreen({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Text('Claim Details: ${claim.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF003366),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(claim),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Claim Overview',
              child: Column(
                children: [
                  _buildDetailRow('Creditor Name', claim.creditorName),
                  _buildDetailRow('Form Type', 'Form ${claim.formType.name.toUpperCase()}'),
                  _buildDetailRow('Claim Amount', currencyFormat.format(claim.amount)),
                  _buildDetailRow('Submission Date', dateFormat.format(claim.submissionDate)),
                  _buildDetailRow('RP / IRP Assigned', claim.rpId),
                  _buildDetailRow('Last Updated', dateFormat.format(claim.lastUpdated)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (claim.particulars.isNotEmpty) ...[
              _buildSection(
                title: 'Particulars of Claim',
                child: Column(
                  children: claim.particulars.entries.map((e) => _buildDetailRow(e.key, e.value)).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
            _buildSection(
              title: 'Attachments & Documents',
              child: claim.attachments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No attachments found for this claim.', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: claim.attachments.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final attachment = claim.attachments[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.description, color: Color(0xFF003366)),
                          ),
                          title: Text(attachment.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('${attachment.type} • ${attachment.size} • Uploaded ${DateFormat('dd MMM').format(attachment.uploadDate)}', style: const TextStyle(fontSize: 12)),
                          trailing: IconButton(
                            icon: const Icon(Icons.download_outlined, color: Color(0xFF003366)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloading ${attachment.name}...')),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 32),
            if (claim.status == ClaimStatus.draft)
              ElevatedButton(
                onPressed: () {
                  // Submit logic
                },
                child: const Text('FINAL SUBMIT CLAIM'),
              )
            else
              OutlinedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Generating acknowledgement receipt...')),
                  );
                },
                icon: const Icon(Icons.print_outlined),
                label: const Text('DOWNLOAD ACKNOWLEDGEMENT'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFF003366)),
                  foregroundColor: const Color(0xFF003366),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(Claim claim) {
    Color color = Colors.grey;
    switch (claim.status) {
      case ClaimStatus.submitted: color = Colors.orange; break;
      case ClaimStatus.underVerification: color = Colors.blue; break;
      case ClaimStatus.admitted: color = Colors.green; break;
      case ClaimStatus.rejected: color = Colors.red; break;
      case ClaimStatus.clarificationRequired: color = Colors.purple; break;
      case ClaimStatus.draft: color = Colors.grey; break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${claim.status.name.toUpperCase()}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
                ),
                Text(
                  _getStatusMessage(claim.status),
                  style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusMessage(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.submitted: return 'Your claim has been submitted and is awaiting initial review.';
      case ClaimStatus.underVerification: return 'The RP/IRP is currently verifying your submitted documents.';
      case ClaimStatus.admitted: return 'Congratulations! Your claim has been admitted in the COC.';
      case ClaimStatus.rejected: return 'Your claim has been rejected. Please check the reasons provided by the RP.';
      case ClaimStatus.clarificationRequired: return 'The RP has requested additional information. Please respond promptly.';
      case ClaimStatus.draft: return 'This claim is yet to be submitted for verification.';
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
