import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_do_list/data/data_sources/remote/firebase/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
