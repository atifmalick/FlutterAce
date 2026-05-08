import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/medical_report.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  return ScannerRepositoryImpl();
});

// Scanner state
class ScannerState {
  final bool isProcessing;
  final String? extractedText;
  final List<ExtractedBiomarker> biomarkers;
  final String? imagePath;
  final String? error;
  final bool isSaved;

  const ScannerState({
    this.isProcessing = false,
    this.extractedText,
    this.biomarkers = const [],
    this.imagePath,
    this.error,
    this.isSaved = false,
  });

  ScannerState copyWith({
    bool? isProcessing,
    String? extractedText,
    List<ExtractedBiomarker>? biomarkers,
    String? imagePath,
    String? error,
    bool? isSaved,
  }) {
    return ScannerState(
      isProcessing: isProcessing ?? this.isProcessing,
      extractedText: extractedText ?? this.extractedText,
      biomarkers: biomarkers ?? this.biomarkers,
      imagePath: imagePath ?? this.imagePath,
      error: error,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  int get abnormalCount => biomarkers.where((b) => b.isAbnormal).length;
  int get normalCount => biomarkers.where((b) => !b.isAbnormal).length;
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  final ScannerRepository _repository;
  final String? _userId;

  ScannerNotifier(this._repository, this._userId)
      : super(const ScannerState());

  Future<void> processImage(String imagePath) async {
    state = ScannerState(isProcessing: true, imagePath: imagePath);
    try {
      final text = await _repository.extractTextFromImage(imagePath);
      final biomarkers = _repository.analyzeExtractedText(text);
      state = ScannerState(
        isProcessing: false,
        extractedText: text,
        biomarkers: biomarkers,
        imagePath: imagePath,
      );
    } catch (e) {
      state = ScannerState(
        isProcessing: false,
        error: e.toString(),
        imagePath: imagePath,
      );
    }
  }

  Future<void> saveReport() async {
    if (_userId == null || state.extractedText == null) return;
    try {
      final analysisJson = {
        'biomarkers': state.biomarkers.map((b) => b.toJson()).toList(),
        'abnormal_count': state.abnormalCount,
        'normal_count': state.normalCount,
        'total': state.biomarkers.length,
      };

      await _repository.saveReport(
        userId: _userId,
        fileUrl: state.imagePath ?? '',
        extractedText: state.extractedText!,
        analysisJson: analysisJson,
      );

      state = state.copyWith(isSaved: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void reset() {
    state = const ScannerState();
  }
}

final scannerProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  final repo = ref.watch(scannerRepositoryProvider);
  final userId = ref.watch(authProvider).profile?.id;
  return ScannerNotifier(repo, userId);
});
