import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  final FirebaseFirestore _firestore;

  Firestore(this._firestore);

  Future<List<CollectionReference>> listCollections() async {
    final collections = <CollectionReference>[];
    final response = await _firestore.collectionGroup('root').get();

    for (var doc in response.docs) {
      collections.add(doc.reference.parent);
    }

    return collections;
  }
}
