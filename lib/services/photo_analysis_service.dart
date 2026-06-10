import '../models/photo_analysis_result_model.dart';

class PhotoAnalysisService {
  Future<PhotoAnalysisResultModel> analyzeDirtyAreaPhoto({
    required String photoUrl,
    required List<String> reportedWasteTypes,
    required String description,
  }) async {
    // TODO: Connect Gemini API / Firebase AI Logic here.
    return PhotoAnalysisResultModel(
      status: 'needsReview',
      cleanlinessScore: 70,
      wasteMatchScore: 80,
      detectedWasteTypes: reportedWasteTypes,
      summary:
          'Fotoğraf analizi Gemini entegrasyonu sonrası otomatik yapılacak.',
      provider: 'mock',
    );
  }
}
