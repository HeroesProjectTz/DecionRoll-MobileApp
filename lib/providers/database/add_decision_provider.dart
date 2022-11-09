import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decisionroll/providers/database/database_provider.dart';
import 'package:decisionroll/models/database/decision_model.dart';
import 'package:flutter/foundation.dart';

final addDecisionProvider =
    FutureProvider.family<DocumentReference<DecisionModel>?, String>(
        (ref, title) async {
  final db = await ref.read(databaseProvider.future);
  if (db != null) {
    final decision = await db.addDecisionByTitle(title);
    debugPrint("added Decision ${decision.id}");
    return decision;
  }
  return null;
});
