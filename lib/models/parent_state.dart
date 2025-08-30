// lib/models/parent_state.dart
import 'package:flutter_lms/models/node.dart';

/// Simple container to represent a lazily-loaded child list state.
class ParentState {
  bool loading;
  String? error;
  List<Node>? children;

  ParentState({this.loading = false, this.error, this.children});
}
