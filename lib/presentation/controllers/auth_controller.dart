import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive variable to store the current user
  Rx<User?> currentUser = Rx<User?>(null);
  RxString userMatricule = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth changes when the controller is initialized
    _auth.authStateChanges().listen((user) async {
      currentUser.value = user;
      if (user != null) {
        // Fetch the matricule from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          userMatricule.value = userDoc.get('matricule');
        } else {
          print("User document does not exist");
        }
      }
    });
  }

  // Sign in with email and passw ord
  Future<User?> signin(String email, String password) async {
    try {
      if (email != null) {
        // Fetch the matricule from Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(email).get();
        if (userDoc.exists) {
          userMatricule.value = userDoc.get('matricule');
        } else {
          print("User document does not exist");
        }
      }
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Error in signin: $e");
      return null;
    }
  }

  // Sign up with email and password
  Future<User?> signup(String password, String email) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Add user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'email': email,
        'matricule': "33333333",
      });

      return userCredential.user;
    } catch (e) {
      print("Error in signup: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error in signOut: $e");
    }
  }
}
