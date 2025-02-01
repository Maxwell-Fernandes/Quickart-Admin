import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isUserAdmin() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    try {
      DocumentSnapshot adminDoc =
          await _firestore.collection('adminData').doc(user.uid).get();
      return adminDoc.exists;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
