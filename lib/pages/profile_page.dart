// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfilePage extends StatefulWidget {
//   // ...
// }

// class _ProfilePageState extends State<ProfilePage> {
//   @override
//   void initState() {
//     super.initState();
//     checkAdminStatus();
//   }

//   void checkAdminStatus() {
//     FirebaseAuth.instance.currentUser?.getIdTokenResult().then((idTokenResult) {
//       print('Admin claim: ${idTokenResult.claims?['admin']}');
//     });
//   }

//   // ...
// }
