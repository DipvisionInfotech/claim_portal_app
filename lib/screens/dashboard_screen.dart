import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/claim_provider.dart';
import '../models/claim.dart';
import '../models/claim_form.dart';
import '../widgets/sidebar.dart';
import './claim_details_screen.dart';
import './form_submission_screen.dart';
import './reports_screen.dart';
import './profile_screen.dart';
import './claims_list_screen.dart';
import 'package:file_picker/file_picker.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedMenuItem = 'Dashboard';

  void _onMenuItemSelected(String title) {
    if (title == 'Upload Documents') {
      _pickDocuments();
      return;
    }
    
    if (title == 'File New Claim') {
      _showFormSelectionDialog(context);
      return;
    }
    
    setState(() {
      _selectedMenuItem = title;
    });
    if (title != 'Dashboard' && 
        title != 'Reports' && 
        title != 'Profile' && 
        title != 'My Claims') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigating to $title')),
      );
    }
  }

  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} document(s) uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFormSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select IBC Claim Form'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormOption(context, FormType.b, 'Form B', 'Proof of Claim by Operational Creditor'),
                _buildFormOption(context, FormType.c, 'Form C', 'Proof of Claim by Financial Creditor'),
                _buildFormOption(context, FormType.d, 'Form D', 'Proof of Claim by Workman or Employee'),
                _buildFormOption(context, FormType.e, 'Form E', 'Proof of Claim by Authorized Representative'),
                _buildFormOption(context, FormType.f, 'Form F', 'Proof of Claim by Other Creditors'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormOption(BuildContext context, FormType type, String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      leading: const Icon(Icons.description),
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
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: isMobile ? Sidebar(
        selectedItem: _selectedMenuItem,
        onItemSelected: _onMenuItemSelected,
      ) : null,
      body: Row(
        children: [
          if (!isMobile)
            Sidebar(
              selectedItem: _selectedMenuItem,
              onItemSelected: _onMenuItemSelected,
            ),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context, isMobile),
                Expanded(
                  child: _buildBody(context, isMobile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isMobile) {
    switch (_selectedMenuItem) {
      case 'Dashboard':
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(context, isMobile),
              const SizedBox(height: 24),
              _buildChartsSection(context, isMobile),
              const SizedBox(height: 24),
              if (isMobile) ...[
                _buildRightSidebar(context, isMobile),
                const SizedBox(height: 24),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildMyClaimsTable(context, isMobile)),
                  if (!isMobile) ...[
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildRightSidebar(context, isMobile)),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              _buildFooter(context, isMobile),
            ],
          ),
        );
      case 'Reports':
        return const ReportsScreen();
      case 'Profile':
        return const ProfileScreen();
      case 'My Claims':
        return const ClaimsListScreen(title: 'My Claims');
      case 'Notifications':
        return const ClaimsListScreen(title: 'Notifications'); // Placeholder
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '$_selectedMenuItem Module',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('This section is currently under development.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _onMenuItemSelected('Dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final provider = Provider.of<ClaimProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search for claims, notices, or forms...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: provider.totalClaims > 0 ? Badge(
              label: Text('${provider.totalClaims}'),
              child: const Icon(Icons.notifications_none),
            ) : const Icon(Icons.notifications_none),
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
          const SizedBox(width: 16),
          Flexible(
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile menu opened')),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'User',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Creditor',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User details opened')),
              );
            },
            child: const CircleAvatar(
              backgroundColor: Color(0xFF003366),
              radius: 18,
              child: Text('VS', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isMobile) {
    final provider = Provider.of<ClaimProvider>(context);
    
    return GridView.count(
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isMobile ? 1.2 : 2.1,
      children: [
        _buildStatCard('Total Claims', '${provider.totalClaims}', Icons.description_outlined, Colors.blue),
        _buildStatCard('Submitted', '${provider.countByStatus(ClaimStatus.submitted)}', Icons.send_outlined, Colors.orange),
        _buildStatCard('Admitted', '${provider.countByStatus(ClaimStatus.admitted)}', Icons.check_circle_outline, Colors.green),
        _buildStatCard('Rejected', '${provider.countByStatus(ClaimStatus.rejected)}', Icons.cancel_outlined, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return InkWell(
      onTap: () {
         _onMenuItemSelected('My Claims');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
                        spots: provider.claims.isEmpty 
                          ? [const FlSpot(0, 0)] 
                          : List.generate(provider.claims.length, (index) => FlSpot(index.toDouble(), provider.claims[index].amount / 1000)),
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
          } else if (label == 'Upload Documents') {
            _pickDocuments();
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
          const Center(
            child: Text(
              'No new notifications',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
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
          const Center(
            child: Text(
              'No upcoming deadlines',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
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
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '');
    final dateFormat = DateFormat('dd/MM/yyyy');

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
          if (provider.claims.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    const Text('No claims filed yet', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClaimDetailsScreen(claim: claim),
                    ),
                  );
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
          if (provider.claims.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade200),
                    const SizedBox(height: 16),
                    Text('No claim records found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text('Submitted claims will appear here', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
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
              final claim = Provider.of<ClaimProvider>(context, listen: false).claims.firstWhere((c) => c.id == id);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClaimDetailsScreen(claim: claim),
                ),
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
