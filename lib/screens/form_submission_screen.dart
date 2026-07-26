import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/claim_form.dart';
import '../models/claim.dart';
import '../providers/claim_provider.dart';

class FormSubmissionScreen extends StatefulWidget {
  final FormType formType;

  const FormSubmissionScreen({super.key, required this.formType});

  @override
  State<FormSubmissionScreen> createState() => _FormSubmissionScreenState();
}

class _FormSubmissionScreenState extends State<FormSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final Map<String, TextEditingController> _controllers = {};

  // File Upload State
  List<PlatformFile> _pickedFiles = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Common fields
    _controllers['name'] = TextEditingController();
    _controllers['id_number'] = TextEditingController();
    _controllers['address_email'] = TextEditingController();
    _controllers['total_claim'] = TextEditingController();
    _controllers['documents_details'] = TextEditingController();
    _controllers['how_when_incurred'] = TextEditingController();
    _controllers['mutual_dealings'] = TextEditingController();
    _controllers['security_details'] = TextEditingController();
    _controllers['bank_account'] = TextEditingController();
    _controllers['list_docs'] = TextEditingController();

    // Specific fields
    if (widget.formType == FormType.ca) {
      _controllers['auth_rep'] = TextEditingController();
    }
    if (widget.formType == FormType.c) {
      _controllers['guarantee_details'] = TextEditingController();
      _controllers['principal_borrower'] = TextEditingController();
    }
    if (widget.formType == FormType.b || widget.formType == FormType.d || widget.formType == FormType.f) {
      _controllers['dispute_details'] = TextEditingController();
    }
    if (widget.formType == FormType.e) {
      _controllers['representative_name'] = TextEditingController();
    }
  }

  String get _formTitle {
    switch (widget.formType) {
      case FormType.ca: return 'FORM CA';
      case FormType.c: return 'FORM C';
      case FormType.b: return 'FORM B';
      case FormType.d: return 'FORM D';
      case FormType.f: return 'FORM F';
      case FormType.e: return 'FORM E';
    }
  }

  String get _formSubtitle {
    switch (widget.formType) {
      case FormType.ca: return 'Financial Creditors in a Class';
      case FormType.c: return 'Financial Creditors';
      case FormType.b: return 'Operational Creditors';
      case FormType.d: return 'Workman or Employee';
      case FormType.f: return 'Other Creditors';
      case FormType.e: return 'Authorised Representative of Workmen/Employees';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_formTitle),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        actions: [
          if (!isMobile)
            TextButton.icon(
              onPressed: () => _showSuccessDialog(),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('SAVE DRAFT', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SUBMISSION OF CLAIM BY ${_formSubtitle.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'RELEVANT PARTICULARS',
                    style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildField('1. Name of the creditor', 'name'),
                  _buildField('2. Identification number (PAN/Passport/Aadhaar)', 'id_number'),
                  _buildField('3. Address and email for correspondence', 'address_email', maxLines: 2),
                  
                  if (isMobile) ...[
                    _buildField('4. Total amount of claim (in Rs.)', 'total_claim', keyboardType: TextInputType.number),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildField('4. Total amount of claim (in Rs.)', 'total_claim', keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField('9. Bank account details', 'bank_account')),
                      ],
                    ),

                  _buildField('5. Details of documents to substantiate debt', 'documents_details', maxLines: 2),
                  _buildField('6. Details of how and when debt incurred', 'how_when_incurred', maxLines: 2),
                  _buildField('7. Details of mutual credit/dealings/set-off', 'mutual_dealings', maxLines: 2),
                  _buildField('8. Details of security held/value/date', 'security_details', maxLines: 2),
                  
                  if (isMobile)
                    _buildField('9. Bank account details for transfer', 'bank_account'),
                  
                  if (widget.formType == FormType.c) ...[
                    _buildField('10. Details of any guarantee given by the corporate debtor', 'guarantee_details', maxLines: 2),
                    _buildField('11. Name of the principal borrower', 'principal_borrower'),
                  ],

                  if (widget.formType == FormType.b || widget.formType == FormType.d || widget.formType == FormType.f)
                    _buildField('10. Details of any dispute of the debt', 'dispute_details', maxLines: 2),

                  _buildField(widget.formType == FormType.c ? '12. List of documents attached' : '11. List of documents attached', 'list_docs', maxLines: 3),

                  if (widget.formType == FormType.ca)
                    _buildField('12. Name of the Authorised Representative', 'auth_rep'),

                  if (widget.formType == FormType.e)
                    _buildField('12. Name of the representative of workmen/employees', 'representative_name'),

                  const SizedBox(height: 32),
                  _buildDocumentUploadSection(isMobile),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'DECLARATION & VERIFICATION',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'I hereby verify that the contents of this proof of claim are true and correct to my knowledge and belief and no material fact has been concealed therefrom.',
                      style: TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('UPLOADING DOCUMENTS...'),
                              ],
                            )
                          : const Text('SUBMIT CLAIM APPLICATION'),
                    ),
                  ),
                  if (isMobile) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved locally')));
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        side: const BorderSide(color: Color(0xFF003366)),
                      ),
                      child: const Text('SAVE DRAFT', style: TextStyle(color: Color(0xFF003366))),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildField(String label, String key, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controllers[key],
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.all(12),
            ),
            validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _pickedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);

    // Simulate file upload delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    
    _showSuccessDialog();
    setState(() => _isSubmitting = false);
  }

  Widget _buildDocumentUploadSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DOCUMENT UPLOAD (PDF/Images)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickFiles,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade200, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
              color: Colors.blue.shade50.withOpacity(0.3),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: isMobile ? 36 : 48, color: Colors.blue.shade900),
                const SizedBox(height: 12),
                Text(
                  'Click to upload supporting documents',
                  style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Invoices, Agreements, Bank Statements, etc.',
                  style: TextStyle(fontSize: isMobile ? 10 : 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        if (_pickedFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Selected Files:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pickedFiles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final file = _pickedFiles[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      file.extension?.toLowerCase() == 'pdf' ? Icons.picture_as_pdf : Icons.image,
                      color: Colors.blue.shade900,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(file.size / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: Colors.red),
                      onPressed: () => _removeFile(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }


  void _showSuccessDialog() {
    final provider = Provider.of<ClaimProvider>(context, listen: false);
    
    // Add new claim to provider
    provider.addClaim(Claim(
      id: 'CLM000${124 + provider.totalClaims}',
      creditorName: _controllers['name']?.text ?? 'Unknown',
      formType: widget.formType,
      amount: double.tryParse(_controllers['total_claim']?.text ?? '0') ?? 0,
      status: ClaimStatus.submitted,
      rpId: 'RP001',
      lastUpdated: DateTime.now(),
    ));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Claim Submitted'),
        content: const Text('Your claim has been successfully submitted to the Resolution Professional. You will receive an email confirmation shortly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Back to login/dashboard
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
