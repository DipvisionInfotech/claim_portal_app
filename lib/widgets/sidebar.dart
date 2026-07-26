import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String selectedItem;
  final Function(String)? onItemSelected;

  const Sidebar({
    super.key,
    this.selectedItem = 'Dashboard',
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;
    
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF003366),
        borderRadius: isDrawer ? null : const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'IBC Claim Filing Portal',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Insolvency and Bankruptcy Code, 2016',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard'),
                _buildNavItem(context, Icons.edit_note_outlined, 'File New Claim'),
                _buildNavItem(context, Icons.list_alt_outlined, 'My Claims'),
                _buildNavItem(context, Icons.drafts_outlined, 'Draft Claims'),
                _buildNavItem(context, Icons.cloud_upload_outlined, 'Upload Documents'),
                _buildNavItem(context, Icons.help_outline, 'Clarifications'),
                _buildNavItem(context, Icons.campaign_outlined, 'Notices & Announcements'),
                _buildNavItem(context, Icons.bar_chart_outlined, 'Reports'),
                _buildNavItem(context, Icons.person_outline, 'Profile'),
                _buildNavItem(context, Icons.live_help_outlined, 'Help & FAQs'),
              ],
            ),
          ),
          _buildSecurityInfo(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              '© 2024 IBC Claim Portal',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String title) {
    final bool isSelected = selectedItem == title;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        dense: true,
        hoverColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          // Close drawer if open
          if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
            Navigator.pop(context);
          }
          
          if (onItemSelected != null) {
            onItemSelected!(title);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Menu item "$title" clicked')),
            );
          }
        },
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_outlined, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          const Text(
            'Secure, Transparent, Compliant.',
            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Your claims. Our responsibility.',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10),
          ),
        ],
      ),
    );
  }
}
