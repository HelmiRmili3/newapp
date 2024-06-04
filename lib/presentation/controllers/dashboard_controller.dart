import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add a penalty to the penalties collection
  // Function to add a penalty to the penalties collection
  Future<void> addPenalty({
    required String name,
    required String email,
    required String cin,
    required String matricule,
    required int points,
    required bool isPaid,
    required String whoSignedIt,
  }) async {
    try {
      DocumentReference docRef = _firestore.collection('penalties').doc();
      await docRef.set({
        'id': docRef.id,
        'name': name,
        'email': email,
        'cin': cin,
        'matricule': matricule,
        // 'points': points,
        // 'isPaid': isPaid,
        // 'whoSignedIt': whoSignedIt,
        // 'timestamp': FieldValue.serverTimestamp(),
      });
      print("Penalty added successfully with ID: ${docRef.id}");
    } catch (e) {
      print("Error adding penalty: $e");
    }
  }

  // Function to switch the isPaid field of a penalty
  Future<void> switchIsPaid(
      String documentId, bool currentStatus, matricule) async {
    try {
      print("matricule : $matricule ");
      await _firestore.collection('penalties').doc(documentId).update({
        'isPaid': !currentStatus,
        'whoSignedIt': matricule.toString(),
      });
      print("Penalty isPaid status switched successfully.");
    } catch (e) {
      print("Error switching isPaid status: $e");
    }
  }

  // Function to fetch all penalties as a stream
  Stream<QuerySnapshot> fetchPenalties() {
    try {
      return _firestore.collection('penalties').snapshots();
    } catch (e) {
      print("Error fetching penalties: $e");
      rethrow;
    }
  }
}
