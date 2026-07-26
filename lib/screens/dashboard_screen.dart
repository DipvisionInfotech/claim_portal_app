import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar.dart';
import '../models/claim_form.dart';
import '../models/claim.dart';
import '../providers/claim_provider.dart';
import 'form_submission_screen.dart';
import 'claims_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedMenuItem = 'Dashboard';

  void _onMenuItemSelected(String title) {
    setState(() {
      _selectedMenuItem = title;
    });

    if (title == 'File New Claim') {
      _showFormSelectionDialog(context);
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to $title')),
      );
    }
  }

  void _showFormSelectionDialog(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select IBC Claim Form'),
        content: SizedBox(
          width: isMobile ? double.maxFinite : 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormOption(context, FormType.ca, 'FORM CA', 'Financial Creditors in a Class'),
                _buildFormOption(context, FormType.c, 'FORM C', 'Financial Creditors'),
                _buildFormOption(context, FormType.b, 'FORM B', 'Operational Creditors'),
                _buildFormOption(context, FormType.d, 'FORM D', 'Workman or Employee'),
                _buildFormOption(context, FormType.e, 'FORM E', 'Authorised Representative of Workmen/Employees'),
                _buildFormOption(context, FormType.f, 'FORM F', 'Other Creditors'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormOption(BuildContext context, FormType type, String title, String subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      leading: const Icon(Icons.description, color: Color(0xFF003366)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormSubmissionScreen(formType: type),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      drawer: isMobile ? Drawer(child: Sidebar(
        selectedItem: _selectedMenuItem,
        onItemSelected: _onMenuItemSelected,
      )) : null,
      body: Row(
        children: [
          if (!isMobile) Sidebar(
            selectedItem: _selectedMenuItem,
            onItemSelected: _onMenuItemSelected,
          ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, isMobile),
                Expanded(
                  child: _selectedMenuItem == 'Dashboard' 
                    ? SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsRow(context, isMobile),
                            const SizedBox(height: 24),
                            if (isMobile) ...[
                              _buildChartsSection(context, isMobile),
                              const SizedBox(height: 24),
                              _buildRightSidebar(context, isMobile),
                            ] else
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: _buildChartsSection(context, isMobile)),
                                  const SizedBox(width: 24),
                                  Expanded(flex: 1, child: _buildRightSidebar(context, isMobile)),
                                ],
                              ),
                            const SizedBox(height: 24),
                            _buildMyClaimsTable(context, isMobile),
                            const SizedBox(height: 24),
                            _buildFooter(context, isMobile),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              '$_selectedMenuItem Module',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('This section is under development.'),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => _onMenuItemSelected('Dashboard'),
                              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
                              child: const Text('Back to Dashboard'),
                            )
                          ],
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (!isMobile) ...[
            IconButton(
              icon: const Badge(
                label: Text('5'),
                child: Icon(Icons.notifications_none),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications panel opened')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help center opened')),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile menu opened')),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Vikram Singh',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isMobile)
                    const Text(
                      'Creditor',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User details opened')),
              );
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF003366),
              child: Text('VS', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isMobile) {
    final provider = Provider.of<ClaimProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200 ? 6 : (constraints.maxWidth > 800 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 2.2 : (constraints.maxWidth > 1200 ? 1.5 : 2.0),
          children: [
            _buildStatCard('Total Claims', provider.totalClaims.toString(), Icons.description_outlined, Colors.blue, '15%', true),
            _buildStatCard('Draft Claims', provider.countByStatus(ClaimStatus.draft).toString(), Icons.edit_note, Colors.green, '25%', true),
            _buildStatCard('Submitted Claims', provider.countByStatus(ClaimStatus.submitted).toString(), Icons.send_outlined, Colors.blueAccent, '8%', true),
            _buildStatCard('Under Verification', provider.countByStatus(ClaimStatus.underVerification).toString(), Icons.search, Colors.purple, '10%', false),
            _buildStatCard('Admitted', provider.countByStatus(ClaimStatus.admitted).toString(), Icons.check_circle_outline, Colors.teal, '5%', true),
            _buildStatCard('Rejected', provider.countByStatus(ClaimStatus.rejected).toString(), Icons.cancel_outlined, Colors.red, '20%', false),
          ],
        );
      },
    );
  }


  Widget _buildStatCard(String title, String value, IconData icon, Color color, String trend, bool isUp) {
    return InkWell(
      onTap: () {
        ClaimStatus? status;
        if (title == 'Draft Claims') status = ClaimStatus.draft;
        else if (title == 'Submitted Claims') status = ClaimStatus.submitted;
        else if (title == 'Under Verification') status = ClaimStatus.underVerification;
        else if (title == 'Admitted') status = ClaimStatus.admitted;
        else if (title == 'Rejected') status = ClaimStatus.rejected;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClaimsListScreen(
              title: title,
              filterStatus: status,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: isUp ? Colors.green : Colors.red,
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: ' $trend ',
                          style: TextStyle(
                            color: isUp ? Colors.green : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: 'vs last month',
                          style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, bool isMobile) {
    final provider = Provider.of<ClaimProvider>(context);
    
    int submitted = provider.countByStatus(ClaimStatus.submitted);
    int underVerification = provider.countByStatus(ClaimStatus.underVerification);
    int other = provider.totalClaims - submitted - underVerification;

    Widget buildStatusChart() => Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Claims by Status', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 40,
                            sections: [
                              if (submitted > 0)
                                PieChartSectionData(color: Colors.blueAccent, value: submitted.toDouble(), title: '$submitted', radius: 25, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              if (underVerification > 0)
                                PieChartSectionData(color: Colors.purple, value: underVerification.toDouble(), title: '$underVerification', radius: 25, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              if (other > 0)
                                PieChartSectionData(color: Colors.grey.shade300, value: other.toDouble(), title: '$other', radius: 25, titleStyle: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${provider.totalClaims}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const Text('Total', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    Widget buildTimeChart() => Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Claims Over Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Last 7 Days', style: TextStyle(fontSize: 10)),
                        Icon(Icons.keyboard_arrow_down, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 3),
                          const FlSpot(1, 1),
                          const FlSpot(2, 4),
                          const FlSpot(3, 2),
                          const FlSpot(4, 5),
                          const FlSpot(5, 3),
                          const FlSpot(6, 4),
                        ],
                        isCurved: true,
                        color: Colors.blue.shade900,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.shade900.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    if (isMobile) {
      return Column(
        children: [
          buildStatusChart(),
          const SizedBox(height: 24),
          buildTimeChart(),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: buildStatusChart()),
          const SizedBox(width: 24),
          Expanded(child: buildTimeChart()),
        ],
      );
    }
  }

  Widget _buildRightSidebar(BuildContext context, bool isMobile) {
    return Column(
      children: [
        _buildQuickActions(context),
        const SizedBox(height: 24),
        _buildNotificationsList(context),
        const SizedBox(height: 24),
        _buildUpcomingDeadlines(context),
      ],
    );
  }


  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActionButton(context, Icons.add, 'File New Claim', true),
          _buildActionButton(context, Icons.cloud_upload_outlined, 'Upload Documents', false),
          _buildActionButton(context, Icons.track_changes_outlined, 'Track Claim', false),
          _buildActionButton(context, Icons.download_outlined, 'Download Acknowledgement', false),
          _buildActionButton(context, Icons.notifications_none, 'View Notices', false),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, bool isPrimary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        onPressed: () {
          if (label == 'File New Claim') {
            _showFormSelectionDialog(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Action: $label initiated')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF003366) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          elevation: 0,
          side: isPrimary ? null : BorderSide(color: Colors.grey.shade300),
          minimumSize: const Size(double.infinity, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('View all', style: TextStyle(color: Colors.blue.shade900, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(context, 'Clarification requested for Claim ID CLM000123', '2h ago', Colors.orange),
          _buildNotificationItem(context, 'CIRP Extension Notice published by RP', '5h ago', Colors.blue),
          _buildNotificationItem(context, 'New update in Claim CLM000098', '1d ago', Colors.green),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, String text, String time, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification: $text')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: const TextStyle(fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingDeadlines(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Deadlines', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('View all', style: TextStyle(color: Colors.blue.shade900, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDeadlineItem(context, 'Last Date for Submission of Claims', '20 May 2024', Colors.red),
          _buildDeadlineItem(context, 'RP Meeting', '18 May 2024', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(BuildContext context, String title, String date, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deadline: $title')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.calendar_today, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyClaimsTable(BuildContext context, bool isMobile) {
    final provider = Provider.of<ClaimProvider>(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '');

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Claims', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(onPressed: () => _showFormSelectionDialog(context), icon: const Icon(Icons.add_circle, color: Color(0xFF003366))),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.claims.map((claim) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(claim.creditorName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${claim.id} • Form ${claim.formType.name.toUpperCase()}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${currencyFormat.format(claim.amount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  _buildStatusCell(_getStatusText(claim.status)),
                ],
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Details for ${claim.id}')));
              },
            ),
          )),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Claims', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  TextButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list, size: 16), label: const Text('Filter', style: TextStyle(fontSize: 12))),
                  TextButton.icon(onPressed: () {}, icon: const Icon(Icons.sort, size: 16), label: const Text('Sort', style: TextStyle(fontSize: 12))),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) => ElevatedButton.icon(
                      onPressed: () {
                        _showFormSelectionDialog(context);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('File New Claim', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(120, 36)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
              5: FlexColumnWidth(1),
              6: FlexColumnWidth(1),
              7: IntrinsicColumnWidth(),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade50),
                children: [
                  _buildTableCell('Claim ID', isHeader: true),
                  _buildTableCell('Creditor Name', isHeader: true),
                  _buildTableCell('Form', isHeader: true),
                  _buildTableCell('Claim Amount (₹)', isHeader: true),
                  _buildTableCell('Status', isHeader: true),
                  _buildTableCell('RP / IRP', isHeader: true),
                  _buildTableCell('Last Updated', isHeader: true),
                  _buildTableCell('Actions', isHeader: true),
                ],
              ),
              ...provider.claims.map((claim) => _buildTableRow(
                    context,
                    claim.id,
                    claim.creditorName,
                    'Form ${claim.formType.name.toUpperCase()}',
                    currencyFormat.format(claim.amount),
                    _getStatusText(claim.status),
                    claim.rpId,
                    dateFormat.format(claim.lastUpdated),
                  )),
            ],
          ),
        ],
      ),
    );
  }


  String _getStatusText(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.draft: return 'Draft';
      case ClaimStatus.submitted: return 'Submitted';
      case ClaimStatus.underVerification: return 'Under Verification';
      case ClaimStatus.admitted: return 'Admitted';
      case ClaimStatus.rejected: return 'Rejected';
      case ClaimStatus.clarificationRequired: return 'Clarification Required';
    }
  }

  TableRow _buildTableRow(BuildContext context, String id, String name, String form, String amount, String status, String rp, String date) {
    return TableRow(
      children: [
        _buildTableCell(id),
        _buildTableCell(name),
        _buildTableCell(form),
        _buildTableCell(amount),
        _buildStatusCell(status),
        _buildTableCell(rp),
        _buildTableCell(date),
        Padding(
          padding: const EdgeInsets.all(12),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Actions for Claim $id')),
              );
            },
            child: const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: isHeader ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color color = Colors.grey;
    if (status == 'Under Verification') color = Colors.blue;
    if (status == 'Submitted') color = Colors.orange;
    if (status == 'Draft') color = Colors.grey;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
        child: Text(
          status,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isMobile) {
    final provider = Provider.of<ClaimProvider>(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    double totalValue = provider.claims.fold(0, (sum, item) => sum + item.amount);

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        Container(
          width: isMobile ? double.infinity : 800,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: isMobile
              ? Column(
                  children: [
                    _buildFooterInfoItem(Icons.calendar_month, 'Claim Filing Window', '10-20 May 2024'),
                    const Divider(),
                    _buildFooterInfoItem(Icons.payments_outlined, 'Total Value', currencyFormat.format(totalValue)),
                    const Divider(),
                    _buildFooterInfoItem(Icons.business, 'Active CIRP', 'ABC Industries'),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildFooterInfoItem(Icons.calendar_month, 'Claim Filing Window', '10 May 2024 - 20 May 2024')),
                    const VerticalDivider(),
                    Expanded(child: _buildFooterInfoItem(Icons.payments_outlined, 'Total Claims Value', currencyFormat.format(totalValue))),
                    const VerticalDivider(),
                    Expanded(child: _buildFooterInfoItem(Icons.business, 'Active CIRP', 'ABC Industries Limited')),
                  ],
                ),
        ),
        Container(
          width: isMobile ? double.infinity : 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF003366), Color(0xFF0055AA)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Claims, Our Process.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('Accurate claims lead to faster resolution', style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ),
              Icon(Icons.verified_user, color: Colors.cyanAccent, size: 24),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildFooterInfoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.blue.shade900, size: 20),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
