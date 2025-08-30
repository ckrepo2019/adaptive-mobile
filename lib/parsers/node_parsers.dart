import 'dart:convert';
import 'package:flutter_lms/models/node.dart';

void _sortNodes(List<Node> nodes) {
  nodes.sort((a, b) {
    final sa = a.sort ?? 1 << 30;
    final sb = b.sort ?? 1 << 30;
    if (sa != sb) return sa.compareTo(sb);
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

Map<String, dynamic>? _asStringMap(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return v;
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), val));
  }
  return null;
}

List<Node> parseRootChildren(String jsonText) {
  dynamic decoded;
  try {
    decoded = jsonDecode(jsonText);
  } catch (_) {
    return const [];
  }

  List<Node> parseOneRoot(dynamic root) {
    if (root is! Map) return const [];
    final String type = (root['type'] ?? '').toString();

    if (type == 'content') {
      final List rawChildren = root['children'] is List
          ? root['children'] as List
          : const [];

      final Map<String, dynamic>? content = _asStringMap(root['content']);
      final List contentChildren =
          (content != null && content['children'] is List)
          ? content['children'] as List
          : const [];

      final List merged = rawChildren.isNotEmpty
          ? rawChildren
          : contentChildren;

      final nodes = _parseNodesRecursively(merged);
      _sortNodes(nodes);
      return nodes;
    }

    if (type == 'assessment') {
      final Map<String, dynamic>? content = _asStringMap(root['content']);
      if (content == null) return const [];
      final name = (content['assessment_name'] ?? 'Assessment').toString();
      final desc = (content['assessment_description'] ?? '').toString();
      final sort = _asInt(content['sort']);
      return [
        Node(
          type: 'assessment',
          name: name,
          description: desc,
          sort: sort,
          children: const [],
          content: content,
        ),
      ];
    }

    return const [];
  }

  if (decoded is List) {
    final out = <Node>[];
    for (final root in decoded) {
      out.addAll(parseOneRoot(root));
    }
    _sortNodes(out);
    return out;
  }

  if (decoded is Map) {
    return parseOneRoot(decoded);
  }

  return const [];
}

List<Node> _parseNodesRecursively(List<dynamic> rawList) {
  final out = <Node>[];
  for (final item in rawList) {
    if (item is! Map) continue;

    final String type = (item['type'] ?? '').toString();

    if (type == 'content') {
      final Map<String, dynamic>? content = _asStringMap(item['content']);
      if (content == null) continue;

      final name = (content['name'] ?? 'Untitled').toString();
      final desc = (content['description'] ?? '').toString();
      final sort = _asInt(content['sort']);

      final bookId = _asInt(content['bookID'] ?? content['bookId']);
      final subjectId = _asInt(content['subjectID'] ?? content['subjectId']);
      final hierarchyId = _asInt(
        content['hierarchyID'] ?? content['hierarchyId'],
      );
      final bookcontentId = _asInt(
        content['bookcontentID'] ??
            content['bookContentID'] ??
            content['bookContentId'],
      );

      final hierarchyNameRaw =
          (content['hierarchy_name'] ?? content['HierarchyName'] ?? '')
              .toString()
              .trim();
      final hierarchyName = hierarchyNameRaw.isEmpty ? null : hierarchyNameRaw;

      final rawHtml = (content['content'] ?? '').toString();
      final html = rawHtml.trim().isEmpty ? null : rawHtml;

      final rawFile = (content['file'] ?? '').toString().trim();
      final file = rawFile.isEmpty ? null : rawFile;

      final childRaw = (item['children'] is List)
          ? item['children'] as List
          : const [];
      final children = _parseNodesRecursively(childRaw);
      _sortNodes(children);

      out.add(
        Node(
          type: 'content',
          name: name,
          description: desc,
          sort: sort,
          children: children,
          bookId: bookId,
          subjectId: subjectId,
          hierarchyId: hierarchyId,
          bookcontentId: bookcontentId,
          hierarchyName: hierarchyName,
          html: html,
          file: file,
          content: content,
        ),
      );
    } else if (type == 'assessment') {
      final Map<String, dynamic>? content = _asStringMap(item['content']);
      if (content == null) continue;

      final name = (content['assessment_name'] ?? 'Assessment').toString();
      final desc = (content['assessment_description'] ?? '').toString();
      final sort = _asInt(content['sort']);

      out.add(
        Node(
          type: 'assessment',
          name: name,
          description: desc,
          sort: sort,
          children: const [],
          content: content,
        ),
      );
    }
  }
  return out;
}

Node? parseRootWithParent(String jsonText) {
  dynamic decoded;
  try {
    decoded = jsonDecode(jsonText);
  } catch (_) {
    return null;
  }

  Map? root;
  if (decoded is List) {
    root = decoded.isNotEmpty && decoded.first is Map
        ? decoded.first as Map
        : null;
  } else if (decoded is Map) {
    root = decoded;
  }
  if (root == null) return null;

  final String type = (root['type'] ?? '').toString();

  if (type == 'content') {
    final Map<String, dynamic>? content = _asStringMap(root['content']);
    if (content == null) return null;

    final name = (content['name'] ?? 'Untitled').toString();
    final desc = (content['description'] ?? '').toString();
    final sort = _asInt(content['sort']);

    final bookId = _asInt(content['bookID'] ?? content['bookId']);
    final subjectId = _asInt(content['subjectID'] ?? content['subjectId']);
    final hierarchyId = _asInt(
      content['hierarchyID'] ?? content['hierarchyId'],
    );
    final bookcontentId = _asInt(
      content['bookcontentID'] ??
          content['bookContentID'] ??
          content['bookContentId'],
    );

    final hierarchyNameRaw =
        (content['hierarchy_name'] ?? content['HierarchyName'] ?? '')
            .toString()
            .trim();
    final hierarchyName = hierarchyNameRaw.isEmpty ? null : hierarchyNameRaw;

    final rawHtml = (content['content'] ?? '').toString();
    final html = rawHtml.trim().isEmpty ? null : rawHtml;

    final rawFile = (content['file'] ?? '').toString().trim();
    final file = rawFile.isEmpty ? null : rawFile;

    final childRaw = (root['children'] is List)
        ? root['children'] as List
        : const [];
    final children = _parseNodesRecursively(childRaw);
    _sortNodes(children);

    return Node(
      type: 'content',
      name: name,
      description: desc,
      sort: sort,
      children: children,
      bookId: bookId,
      subjectId: subjectId,
      hierarchyId: hierarchyId,
      bookcontentId: bookcontentId,
      hierarchyName: hierarchyName,
      html: html,
      file: file,
      content: content,
    );
  }

  if (type == 'assessment') {
    final Map<String, dynamic>? content = _asStringMap(root['content']);
    if (content == null) return null;
    final name = (content['assessment_name'] ?? 'Assessment').toString();
    final desc = (content['assessment_description'] ?? '').toString();
    final sort = _asInt(content['sort']);
    return Node(
      type: 'assessment',
      name: name,
      description: desc,
      sort: sort,
      children: const [],
      content: content,
    );
  }

  return null;
}
