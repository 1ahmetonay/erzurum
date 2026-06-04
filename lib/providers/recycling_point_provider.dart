import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recycling_point_model.dart';
import '../repositories/recycling_point_repository.dart';

final recyclingPointRepositoryProvider = Provider<RecyclingPointRepository>((
  ref,
) {
  return RecyclingPointRepository();
});

final activeRecyclingPointsProvider = StreamProvider<List<RecyclingPointModel>>(
  (ref) {
    return ref
        .watch(recyclingPointRepositoryProvider)
        .watchActiveRecyclingPoints();
  },
);
