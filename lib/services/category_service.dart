import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_quickart/models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Category>> getCategories() {
    return _firestore.collection('category').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
