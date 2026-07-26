import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Mock user data
  String _name = 'Vikram Singh';
  String _email = 'vikram.singh@example.com';
  String _phone = '+91 98765 43210';
  String _pan = 'ABCDE1234F';
  String _address = '123, Business Park, Cyber City, Gurugram, Haryana - 122002';

  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'User Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      // Save logic here
                      _isEditing = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updated successfully')),
                      );
                    } else {
                      _isEditing = true;
                    }
                  });
                },
                icon: Icon(_isEditing ? Icons.save : Icons.edit, size: 18),
                label: Text(_isEditing ? 'Save Profile' : 'Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing ? Colors.green : const Color(0xFF003366),
                  minimumSize: const Size(150, 40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (isMobile)
            Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildProfileForm(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildProfileHeader()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildProfileForm()),
              ],
            ),
          const SizedBox(height: 24),
          _buildAccountSecurity(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF003366),
                child: Text('VS', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(_name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Creditor | Individual', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.email_outlined, _email),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, _phone),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTextField('Full Name', _name, (v) => _name = v)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('PAN Number', _pan, (v) => _pan = v, enabled: false)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Email Address', _email, (v) => _email = v)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Phone Number', _phone, (v) => _phone = v)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField('Residential Address', _address, (v) => _address = v, maxLines: 3),
            const SizedBox(height: 24),
            const Text('KYC Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.withOpacity(0.5))),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text('KYC Verified - 12 Jan 2024', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged, {bool enabled = true, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          enabled: _isEditing && enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: !(_isEditing && enabled),
            fillColor: _isEditing && enabled ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAccountSecurity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            subtitle: const Text('Last changed 3 months ago'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.phonelink_lock),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Currently enabled via SMS'),
            trailing: Switch(value: true, onChanged: (v) {}),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
