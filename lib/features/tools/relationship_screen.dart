import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../person/person_sheet.dart';
import '../tree/tree_painter.dart';

/// P1「关系计算器」：在家族图（亲子+配偶边）上 BFS 找最短关系路径并归类。
enum RelHopKind { parentOf, childOf, spouseOf }

class RelHop {
  const RelHop(this.fromName, this.toName, this.kind, this.fromId, this.toId);

  final String fromName;
  final String toName;
  final RelHopKind kind;
  final String fromId;
  final String toId;
}

/// 图构建 + BFS 最短路径（规划 P1：关系计算器）。
class FamilyGraph {
  FamilyGraph({
    required this.persons,
    required this.families,
    required this.links,
  });

  final List<Person> persons;
  final List<Family> families;
  final List<FamilyChildLink> links;

  final Map<String, String> names = {};
  final Map<String, List<RelHop>> _adj = {};

  String name(String id) => names[id] ?? '—';

  void build() {
    for (final p in persons) {
      names[p.id] = personDisplayName(p, const Locale('en'));
      _adj.putIfAbsent(p.id, () => []);
    }
    for (final f in families) {
      // 配偶边（双向）
      final p1 = f.partner1Id, p2 = f.partner2Id;
      if (p1 != null && p2 != null) {
        _adj.putIfAbsent(p1, () => []).add(
              RelHop(p1, p2, RelHopKind.spouseOf, p1, p2),
            );
        _adj.putIfAbsent(p2, () => []).add(
              RelHop(p2, p1, RelHopKind.spouseOf, p2, p1),
            );
      }
      // 亲子边：partners → children
      final kids = links.where((l) => l.familyId == f.id).toList();
      for (final partner in [p1, p2]) {
        if (partner == null) continue;
        for (final k in kids) {
          _adj.putIfAbsent(partner, () => []).add(
                RelHop(partner, k.personId, RelHopKind.parentOf, partner,
                    k.personId),
              );
          _adj.putIfAbsent(k.personId, () => []).add(
                RelHop(k.personId, partner, RelHopKind.childOf, k.personId,
                    partner),
              );
        }
      }
    }
  }

  /// BFS：返回从 fromId 到 toId 的跳序列表（最短路径），无连接返回空。
  List<RelHop> shortestPath(String fromId, String toId) {
    if (fromId == toId) return [];
    final prev = <String, RelHop>{};
    final visited = <String>{fromId};
    final queue = <String>[fromId];
    while (queue.isNotEmpty) {
      final cur = queue.removeAt(0);
      for (final hop in _adj[cur] ?? const <RelHop>[]) {
        if (visited.contains(hop.toId)) continue;
        prev[hop.toId] = hop;
        if (hop.toId == toId) {
          // 回溯
          final path = <RelHop>[hop];
          var cursor = toId;
          while (prev[cursor] != null) {
            final h = prev[cursor]!;
            path.insert(0, h);
            cursor = h.fromId;
            if (cursor == fromId) break;
          }
          return path;
        }
        visited.add(hop.toId);
        queue.add(hop.toId);
      }
    }
    return [];
  }
}

/// 关系计算器页：选两个人 → 显示关系分类 + 路径链。
class RelationshipScreen extends ConsumerStatefulWidget {
  const RelationshipScreen({super.key});

  @override
  ConsumerState<RelationshipScreen> createState() =>
      _RelationshipScreenState();
}

class _RelationshipScreenState extends ConsumerState<RelationshipScreen> {
  String? _aId;
  String? _bId;

  @override
  Widget build(BuildContext context) {
    final treeId = ref.watch(effectiveTreeIdProvider);
    final personsAsync = ref.watch(personsProvider(treeId ?? ''));
    final familiesAsync = ref.watch(familiesProvider(treeId ?? ''));
    final linksAsync = ref.watch(childLinksProvider(treeId ?? ''));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.relationshipTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (persons) {
          if (persons.length < 2) {
            return Center(
              child: Text(l10n.searchEmpty,
                  style: TextStyle(fontSize: 13.5, color: colors.ink3)),
            );
          }
          final a = persons.where((p) => p.id == _aId).firstOrNull;
          final b = persons.where((p) => p.id == _bId).firstOrNull;
          final locale = Localizations.localeOf(context);

          // 关系计算
          String? resultText;
          List<RelHop> path = const [];
          final families = familiesAsync.value ?? const <Family>[];
          final links = linksAsync.value ?? const <FamilyChildLink>[];
          if (a != null && b != null) {
            final graph = FamilyGraph(
                persons: persons, families: families, links: links)
              ..build();
            path = graph.shortestPath(a.id, b.id);
            resultText = _classify(graph, path, a.id, b.id, l10n);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
            children: [
              _picker(context, l10n.relationshipPickA, a, persons, colors,
                  (id) => setState(() => _aId = id)),
              const SizedBox(height: 10),
              _picker(context, l10n.relationshipPickB, b, persons, colors,
                  (id) => setState(() => _bId = id)),
              const SizedBox(height: 18),
              if (a != null && b != null) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.brandSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resultText ?? '',
                          style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: colors.brand)),
                      if (path.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(l10n.relPathTitle,
                            style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w700,
                                color: colors.ink3)),
                        const SizedBox(height: 6),
                        for (final hop in path)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Icon(
                                  switch (hop.kind) {
                                    RelHopKind.parentOf => Icons.arrow_upward,
                                    RelHopKind.childOf =>
                                      Icons.arrow_downward,
                                    RelHopKind.spouseOf => Icons.favorite,
                                  },
                                  size: 14,
                                  color: colors.ink3,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                    '\${graph.name(hop.fromId)} → \${graph.name(hop.toId)}',
                                    style: TextStyle(
                                        fontSize: 13.5, color: colors.ink2)),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _classify(FamilyGraph graph, List<RelHop> path, String aId, String bId,
      AppLocalizations l10n) {
    final aName = graph.name(aId);
    final bName = graph.name(bId);
    if (aId == bId) return l10n.relSelf;
    if (path.isEmpty) return l10n.relNoPath;

    final kinds = path.map((h) => h.kind).toList();

    // 纯配偶边
    if (kinds.length == 1 && kinds.first == RelHopKind.spouseOf) {
      return l10n.relSpouses(aName, bName);
    }
    final isAllParent = kinds.every((k) => k == RelHopKind.parentOf);
    final isAllChild = kinds.every((k) => k == RelHopKind.childOf);
    if (isAllParent) {
      return l10n.relDirectAncestor(bName, kinds.length);
    }
    if (isAllChild) {
      return l10n.relDirectDescendant(bName, kinds.length);
    }
    // 同代旁系：上行 n 步 + 同代横移 + 下行 n 步（或纯横向）
    if (kinds.length == 1) return l10n.relSiblings(aName, bName);
    final up = kinds.takeWhile((k) => k == RelHopKind.childOf).length;
    final down = kinds.reversed
        .takeWhile((k) => k == RelHopKind.parentOf)
        .length;
    final midMarriage = kinds.contains(RelHopKind.spouseOf);
    if (midMarriage) return l10n.relRelatedByMarriage(aName, bName);
    if (up == down && up >= 2) {
      return l10n.relCousins(aName, bName, up - 1);
    }
    if (up > down) {
      return l10n.relUncleNiece(up == down + 1 ? aName : bName,
          up == down + 1 ? bName : aName);
    }
    return l10n.relUncleNiece(down == up + 1 ? bName : aName,
        down == up + 1 ? aName : bName);
  }

  Widget _picker(
    BuildContext context,
    String label,
    Person? selected,
    List<Person> persons,
    LarariumColors colors,
    ValueChanged<String> onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 12,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
                color: colors.ink3)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.line),
          ),
          child: Column(
            children: [
              for (final p in persons.take(50))
                InkWell(
                  onTap: () => onSelect(p.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        if (selected?.id == p.id)
                          Icon(Icons.check_circle,
                              size: 18, color: colors.brand)
                        else
                          Icon(Icons.radio_button_unchecked,
                              size: 18, color: colors.ink4),
                        const SizedBox(width: 10),
                        Text(personDisplayName(p, Localizations.localeOf(context)),
                            style: TextStyle(
                                fontSize: 14, color: colors.ink)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
