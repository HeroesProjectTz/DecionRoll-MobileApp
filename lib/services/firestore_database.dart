import 'package:decisionroll/models/database/decision_model.dart';
import 'package:decisionroll/models/database/candidate_model.dart';
import 'package:decisionroll/services/firestore_path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreDatabase {
  final FirebaseFirestore db;
  final String uid;

  FirestoreDatabase({required this.db, required this.uid});

  // ==== type-safe collection access helpers ====
  CollectionReference<DecisionModel> decisionsCollection() =>
      db.collection(FirestorePath.decisions).withConverter<DecisionModel>(
          fromFirestore: (snapshot, _) => DecisionModel.fromSnapshot(snapshot),
          toFirestore: (decision, _) => decision.toMap());

  CollectionReference<CandidateModel> decisionCandidatesCollection(
          String decisionId) =>
      db
          .collection(FirestorePath.candidates(decisionId))
          .withConverter<CandidateModel>(
              fromFirestore: (snapshot, _) =>
                  CandidateModel.fromSnapshot(snapshot),
              toFirestore: (candidate, _) => candidate.toMap());

  // ==== queries ====
  Stream<List<DecisionModel>> userDecisions(String ownerId) {
    final decisionsQuery =
        decisionsCollection().where('ownerId', isEqualTo: ownerId);
    final userDecisionsList = decisionsQuery
        .snapshots()
        .map((_) => _.docs.map((_) => _.data()).toList());
    return userDecisionsList;
  }

  Stream<List<CandidateModel>> decisionCandidates(String decisionId) {
    final candidatesCollection = decisionCandidatesCollection(decisionId);

    final candidatesListStream = candidatesCollection
        .snapshots()
        .map((_) => _.docs.map((_) => _.data()).toList());

    return candidatesListStream;
  }

  // ==== databes get operations ====
  DocumentReference<DecisionModel> getDecision(String decisionId) {
    return decisionsCollection().doc(decisionId);
  }

  // ==== database update operations ====
  Future<DocumentReference<DecisionModel>> addDecision(DecisionModel decision) {
    return decisionsCollection().add(decision);
  }

  Future<DocumentReference<DecisionModel>> addDecisionByTitle(String title) {
    return addDecision(DecisionModel(ownerId: uid, title: title));
  }

  Future<DocumentReference<CandidateModel>> addCandidate(
      String decisionId, CandidateModel candidate) {
    return decisionCandidatesCollection(decisionId).add(candidate);
  }

  Future<DocumentReference<CandidateModel>> addCandidateByTitle(
      String decisionId, String title) {
    return addCandidate(decisionId, CandidateModel(title: title));
  }
}
