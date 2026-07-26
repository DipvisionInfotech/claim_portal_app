import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/claim_provider.dart';
import '../models/claim.dart';
import '../models/claim_form.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClaimProvider>(context);
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    if (provider.totalClaims == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No data available for reports',
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Submit your first claim to see analytics.'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics & Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
          ),
          const SizedBox(height: 8),
          const Text('Real-time overview of your filed claims and their status.'),
          const SizedBox(height: 24),
          
          if (isMobile) ...[
            _buildSummaryGrid(provider, currencyFormat),
            const SizedBox(height: 24),
            _buildClaimDistributionChart(provider),
            const SizedBox(height: 24),
            _buildStatusBreakdownChart(provider),
          ] else ...[
            _buildSummaryGrid(provider, currencyFormat),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildClaimDistributionChart(provider)),
                const SizedBox(width: 24),
                Expanded(child: _buildStatusBreakdownChart(provider)),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildFormTypeTable(provider, currencyFormat),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(ClaimProvider provider, NumberFormat format) {
    double totalAmount = provider.claims.fold(0, (sum, c) => sum + c.amount);
    int admittedCount = provider.countByStatus(ClaimStatus.admitted);
    double admittedRate = provider.totalClaims > 0 ? (admittedCount / provider.totalClaims) * 100 : 0;

    return LayoutBuilder(builder: (context, constraints) {
      int count = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
      return GridView.count(
        crossAxisCount: count,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: [
          _buildSummaryCard('Total Value Filed', format.format(totalAmount), Icons.account_balance_wallet, Colors.blue),
          _buildSummaryCard('Avg. Claim Size', format.format(provider.totalClaims > 0 ? totalAmount / provider.totalClaims : 0), Icons.analytics, Colors.purple),
          _buildSummaryCard('Admission Rate', '${admittedRate.toStringAsFixed(1)}%', Icons.verified, Colors.green),
          _buildSummaryCard('Active Files', provider.totalClaims.toString(), Icons.folder_shared, Colors.orange),
        ],
      );
    });
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimDistributionChart(ClaimProvider provider) {
    final Map<FormType, int> distribution = {};
    for (var type in FormType.values) {
      distribution[type] = provider.claims.where((c) => c.formType == type).length;
    }

    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Claims by Form Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 60,
                sections: distribution.entries.where((e) => e.value > 0).map((e) {
                  return PieChartSectionData(
                    color: _getColorForFormType(e.key),
                    value: e.value.toDouble(),
                    title: 'Form ${e.key.name.toUpperCase()}',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdownChart(ClaimProvider provider) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: provider.totalClaims.toDouble() + 1,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(fontSize: 10);
                        switch (value.toInt()) {
                          case 0: return const Text('Draft', style: style);
                          case 1: return const Text('Subm.', style: style);
                          case 2: return const Text('Verif.', style: style);
                          case 3: return const Text('Adm.', style: style);
                          case 4: return const Text('Rej.', style: style);
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, provider.countByStatus(ClaimStatus.draft).toDouble(), Colors.grey),
                  _buildBarGroup(1, provider.countByStatus(ClaimStatus.submitted).toDouble(), Colors.orange),
                  _buildBarGroup(2, provider.countByStatus(ClaimStatus.underVerification).toDouble(), Colors.blue),
                  _buildBarGroup(3, provider.countByStatus(ClaimStatus.admitted).toDouble(), Colors.green),
                  _buildBarGroup(4, provider.countByStatus(ClaimStatus.rejected).toDouble(), Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [BarChartRodData(toY: y, color: color, width: 20, borderRadius: BorderRadius.circular(4))],
    );
  }

  Widget _buildFormTypeTable(ClaimProvider provider, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detailed Form Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Table(
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade50),
                children: [
                  _buildTableCell('Form Type', isHeader: true),
                  _buildTableCell('Count', isHeader: true),
                  _buildTableCell('Total Value', isHeader: true),
                  _buildTableCell('Avg. Value', isHeader: true),
                ],
              ),
              ...FormType.values.map((type) {
                final claims = provider.claims.where((c) => c.formType == type).toList();
                if (claims.isEmpty) return const TableRow(children: [SizedBox(), SizedBox(), SizedBox(), SizedBox()]);
                double total = claims.fold(0, (sum, c) => sum + c.amount);
                return TableRow(
                  children: [
                    _buildTableCell('Form ${type.name.toUpperCase()}'),
                    _buildTableCell(claims.length.toString()),
                    _buildTableCell(format.format(total)),
                    _buildTableCell(format.format(total / claims.length)),
                  ],
                );
              }).where((row) => row.children[0] is! SizedBox),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
    );
  }

  Color _getColorForFormType(FormType type) {
    switch (type) {
      case FormType.ca: return Colors.blue;
      case FormType.c: return Colors.indigo;
      case FormType.b: return Colors.teal;
      case FormType.d: return Colors.orange;
      case FormType.e: return Colors.deepOrange;
      case FormType.f: return Colors.purple;
    }
  }
}
