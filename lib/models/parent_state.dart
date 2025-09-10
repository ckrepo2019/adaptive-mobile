// lib/models/parent_state.dart
import 'package:Adaptive/models/node.dart';

class ParentState {
  bool loading;
  String? error;
  List<Node>? children;

  ParentState({this.loading = false, this.error, this.children});
}
