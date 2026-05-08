import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/experience.dart';

final firestoreExperienceRepositoryProvider = Provider<FirestoreExperienceRepository>((ref) {
  return FirestoreExperienceRepository(FirebaseFirestore.instance);
});

class FirestoreExperienceRepository {
  final FirebaseFirestore _firestore;

  FirestoreExperienceRepository(this._firestore);

  Stream<List<Experience>> getExperiences() {
    return _firestore.collection('experiences').orderBy('startDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Convert Firestore Timestamps to DateTimes
        if (data['startDate'] is Timestamp) {
          data['startDate'] = (data['startDate'] as Timestamp).toDate().toIso8601String();
        }
        if (data['endDate'] is Timestamp) {
          data['endDate'] = (data['endDate'] as Timestamp).toDate().toIso8601String();
        }

        return Experience.fromJson(data);
      }).toList();
    });
  }
}
