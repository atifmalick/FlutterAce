import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/project.dart';

final firestoreProjectRepositoryProvider = Provider<FirestoreProjectRepository>((ref) {
  return FirestoreProjectRepository(FirebaseFirestore.instance);
});

class FirestoreProjectRepository {
  final FirebaseFirestore _firestore;

  FirestoreProjectRepository(this._firestore);

  Stream<List<Project>> getProjects() {
    return _firestore.collection('projects').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Assign document ID
        return Project.fromJson(data);
      }).toList();
    });
  }
}
