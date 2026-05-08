import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../providers/scanner_provider.dart';
import '../widgets/report_result_card.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});
  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image != null) {
      ref.read(scannerProvider.notifier).processImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: AppConstants.paddingLarge, right: AppConstants.paddingLarge, bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: AppColors.darkGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Smart Scanner', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Scan blood test reports for instant analysis', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          sliver: SliverList(delegate: SliverChildListDelegate([
            // Image picker area
            if (state.imagePath == null && !state.isProcessing)
              _buildPickerArea(),
            // Processing indicator
            if (state.isProcessing)
              _buildProcessing(),
            // Image preview
            if (state.imagePath != null && !state.isProcessing) ...[
              _buildImagePreview(state.imagePath!),
              const SizedBox(height: 16),
            ],
            // Error
            if (state.error != null)
              _buildError(state.error!),
            // Results
            if (state.biomarkers.isNotEmpty) ...[
              ReportResultCard(biomarkers: state.biomarkers),
              const SizedBox(height: 16),
              if (!state.isSaved)
                GradientButton(label: 'Save Report', icon: Icons.save_rounded, onPressed: () => ref.read(scannerProvider.notifier).saveReport()),
              if (state.isSaved)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success),
                    const SizedBox(width: 12),
                    Text('Report saved successfully!', style: AppTextStyles.body.copyWith(color: AppColors.success, fontWeight: FontWeight.w600)),
                  ]),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.read(scannerProvider.notifier).reset(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Scan Another Report'),
              ),
            ],
            // Extracted text
            if (state.extractedText != null && state.extractedText!.isNotEmpty && state.biomarkers.isEmpty) ...[
              const SizedBox(height: 16),
              ReportResultCard(biomarkers: const []),
              const SizedBox(height: 12),
              _buildExtractedText(state.extractedText!),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ref.read(scannerProvider.notifier).reset(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
            const SizedBox(height: 100),
          ])),
        ),
      ]),
    );
  }

  Widget _buildPickerArea() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.secondary, width: 2, strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
          child: const Icon(Icons.document_scanner_rounded, size: 48, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        Text('Upload Medical Report', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text('Take a photo or choose from gallery\nto analyze your blood test report', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: GradientButton(label: 'Camera', icon: Icons.camera_alt_rounded, onPressed: () => _pickImage(ImageSource.camera))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
        ]),
      ]),
    );
  }

  Widget _buildProcessing() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
      child: Column(children: [
        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
        const SizedBox(height: 20),
        Text('Analyzing Report...', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text('Extracting text and identifying biomarkers', style: AppTextStyles.bodySmall),
      ]),
    );
  }

  Widget _buildImagePreview(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(File(path), height: 200, width: double.infinity, fit: BoxFit.cover),
    );
  }

  Widget _buildError(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error),
        const SizedBox(width: 12),
        Expanded(child: Text(error, style: AppTextStyles.body.copyWith(color: AppColors.error))),
      ]),
    );
  }

  Widget _buildExtractedText(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Extracted Text', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Text(text, style: AppTextStyles.bodySmall.copyWith(fontFamily: 'monospace')),
      ]),
    );
  }
}
