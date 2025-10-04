import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class DocumentVerificationScreen extends ConsumerStatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  ConsumerState<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends ConsumerState<DocumentVerificationScreen> {
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _aadharFront;
  XFile? _aadharBack;
  XFile? _panImage;
  XFile? _policeVerification;

  bool _isLoading = false;

  @override
  void dispose() {
    _aadharController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String documentType, {bool isBack = false}) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        switch (documentType) {
          case AppConstants.docTypeAadhar:
            if (isBack) {
              _aadharBack = image;
            } else {
              _aadharFront = image;
            }
            break;
          case AppConstants.docTypePan:
            _panImage = image;
            break;
          case AppConstants.docTypePoliceVerification:
            _policeVerification = image;
            break;
        }
      });
    }
  }

  Future<void> _submitDocuments() async {
    if (!_formKey.currentState!.validate()) return;

    if (_aadharFront == null || _aadharBack == null || _panImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate upload
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(AppConstants.routeProfileSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Document Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upload Your Documents',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  'We need to verify your identity to ensure safety and trust',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // Aadhar Card Section
                _buildDocumentSection(
                  'Aadhar Card',
                  true,
                  [
                    TextFormField(
                      controller: _aadharController,
                      decoration: const InputDecoration(
                        labelText: 'Aadhar Number',
                        hintText: 'Enter 12-digit Aadhar number',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Aadhar number';
                        }
                        if (value.length != 12) {
                          return 'Aadhar number must be 12 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildImageUpload(
                      'Aadhar Front',
                      _aadharFront,
                      () => _pickImage(AppConstants.docTypeAadhar),
                    ),
                    const SizedBox(height: 12),
                    _buildImageUpload(
                      'Aadhar Back',
                      _aadharBack,
                      () => _pickImage(AppConstants.docTypeAadhar, isBack: true),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // PAN Card Section
                _buildDocumentSection(
                  'PAN Card',
                  true,
                  [
                    TextFormField(
                      controller: _panController,
                      decoration: const InputDecoration(
                        labelText: 'PAN Number',
                        hintText: 'Enter PAN number',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter PAN number';
                        }
                        if (value.length != 10) {
                          return 'PAN number must be 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildImageUpload(
                      'PAN Card Image',
                      _panImage,
                      () => _pickImage(AppConstants.docTypePan),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Police Verification Section
                _buildDocumentSection(
                  'Police Verification',
                  false,
                  [
                    _buildImageUpload(
                      'Police Verification Certificate (Optional)',
                      _policeVerification,
                      () => _pickImage(AppConstants.docTypePoliceVerification),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Submit button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitDocuments,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Continue'),
                ),

                const SizedBox(height: 16),

                Text(
                  'Your documents will be verified within 24-48 hours',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentSection(
    String title,
    bool isRequired,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(color: AppTheme.errorRed),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildImageUpload(String label, XFile? image, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: BoxDecoration(
          border: Border.all(
            color: image != null ? AppTheme.successGreen : AppTheme.borderColor,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          color: image != null
              ? AppTheme.successGreen.withOpacity(0.05)
              : AppTheme.backgroundColor,
        ),
        child: Row(
          children: [
            Icon(
              image != null ? Icons.check_circle : Icons.upload_file,
              color: image != null ? AppTheme.successGreen : AppTheme.iconSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                image != null ? '$label - Uploaded' : label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: image != null ? AppTheme.successGreen : AppTheme.textSecondary,
                ),
              ),
            ),
            if (image != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    if (label.contains('Aadhar Front')) {
                      _aadharFront = null;
                    } else if (label.contains('Aadhar Back')) {
                      _aadharBack = null;
                    } else if (label.contains('PAN')) {
                      _panImage = null;
                    } else if (label.contains('Police')) {
                      _policeVerification = null;
                    }
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
