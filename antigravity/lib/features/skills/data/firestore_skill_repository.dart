import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/skill.dart';

final firestoreSkillRepositoryProvider = Provider<FirestoreSkillRepository>((ref) {
  return FirestoreSkillRepository(FirebaseFirestore.instance);
});

class FirestoreSkillRepository {
  final FirebaseFirestore _firestore;

  FirestoreSkillRepository(this._firestore);

  Stream<List<Skill>> getSkills() {
    return _firestore.collection('skills').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Skill.fromJson(data);
      }).toList();
    });
  }
}
