class Node {
  final String type; // 'content' or 'assessment'
  final String name;
  final String description;
  final int? sort;
  final List<Node> children;
  // IDs
  final int? bookId;
  final int? subjectId;
  final int? hierarchyId;
  final int? bookcontentId;
  final String? hierarchyName;
  final String? file;
  final String? html;
  final Map<String, dynamic>? content;
  final int? assessmentOrder;
  Node({
    required this.type,
    required this.name,
    required this.description,
    required this.children,
    this.sort,
    this.bookId,
    this.subjectId,
    this.hierarchyId,
    this.bookcontentId,
    this.hierarchyName,
    this.html,
    this.file,
    this.content,
    this.assessmentOrder,
  });

  Node copyWith({List<Node>? children, int? assessmentOrder}) {
    return Node(
      type: type,
      name: name,
      description: description,
      sort: sort,
      children: children ?? this.children,
      bookId: bookId,
      subjectId: subjectId,
      hierarchyId: hierarchyId,
      bookcontentId: bookcontentId,
      hierarchyName: hierarchyName,
      assessmentOrder: assessmentOrder ?? this.assessmentOrder,
    );
  }
}
