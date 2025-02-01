import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAdmin = false;

  bool isAdmin() => _isAdmin;

  Future<void> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      print('Auth Details:');
      print('Email: ${user.email}');
      print('UID: ${user.uid}');

      // Check admin status in Firestore
      final querySnapshot = await _firestore
          .collection('adminData')
          .where('uid', isEqualTo: user.uid)
          .get();

      _isAdmin = querySnapshot.docs.isNotEmpty;
      print('Is admin: $_isAdmin');

      notifyListeners();
    } catch (e) {
      print('Error signing in: $e');
      throw e;
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> signOut() async {
    await _auth.signOut();
    _isAdmin = false;
    notifyListeners();
  }

  Future<void> _fetchUserRole() async {
    if (currentUser != null) {
      final userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      _isAdmin = userDoc.data()?['role'] == 'admin';
    }
  }

  Future<void> createAdminUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': 'admin',
      });
    } catch (e) {
      throw 'Failed to create admin user: ${e.toString()}';
    }
  }

  Future<void> setupAdminUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      // Create or update admin document
      await _firestore.collection('adminData').doc(user.uid).set({
        'email': user.email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Admin document created successfully');

      // Verify the document was created
      final adminDoc =
          await _firestore.collection('adminData').doc(user.uid).get();
      print('Admin document exists: ${adminDoc.exists}');
      if (adminDoc.exists) {
        print('Admin document data: ${adminDoc.data()}');
      }
    } catch (e) {
      print('Error setting up admin user: $e');
    }
  }
}
