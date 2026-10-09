import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../person/person_sheet.dart';
import 'layout/tree_layout.dart';
import 'tree_painter.dart';

/// 01 树视图：拖拽平移 / 双指或滚轮缩放 / 6px 阈值防误触（对标 FamilySearch 差评 #1）。
class TreeScreen extends ConsumerStatefulWidget {
  const TreeScreen({super.key, required this.treeId});

  final String treeId;

  @override
  ConsumerState<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends ConsumerState<TreeScreen> {
  final TreeViewport _viewport = TreeViewport();
  bool _fitted = false;

  static const double _tapSlop = 6; // 拖动阈值：小于视为点按
  Offset? _startFocal;
  Offset? _lastFocal;
  Offset _offsetStart = Offset.zero;
  double _accumDist = 0;

  void _fit(TreeLayoutResult result, Size canvasSize) {
    if (result.bounds.isEmpty) return;
    const pad = 52.0;
    final bw = result.bounds.width;
    final bh = result.bounds.height;
    if (bw <= 0 || bh <= 0) return;
    final s = math.min(
      ((canvasSize.width - pad) / bw).clamp(0.3, 1.05),
      ((canvasSize.height - pad) / bh).clamp(0.3, 1.05),
    ).toDouble();
    final center = result.bounds.center;
    _viewport.set(
      scale: s,
      offset: Offset(
        canvasSize.width / 2 - center.dx * s,
        canvasSize.height / 2 - center.dy * s,
      ),
    );
  }

  void _zoomBy(double factor, Size canvasSize) {
    _viewport.zoomAround(canvasSize.center(Offset.zero), _viewport.scale * factor);
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(personsProvider(widget.treeId));
    final familiesAsync = ref.watch(familiesProvider(widget.treeId));
    final linksAsync = ref.watch(childLinksProvider(widget.treeId));
    final treeAsync = ref.watch(defaultTreeProvider);
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return personsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (persons) {
        final families = familiesAsync.value ?? const <Family>[];
        final links = linksAsync.value ?? const <FamilyChildLink>[];
        final textDirection = Directionality.of(context);
        final result = computeTreeLayout(TreeLayoutInput(
          persons: persons,
          families: families,
          childLinks: links,
          textDirection: textDirection,
          focusPersonId: persons.where((p) => p.isSelf).firstOrNull?.id,
        ));

        final self = persons.where((p) => p.isSelf).firstOrNull;
        final visuals = <String, PersonNodeVisual>{
          for (final n in result.nodes)
            n.person.id: _visualFor(n.person, locale, l10n),
        };
        final treeName =
            treeAsync.value?.name ?? l10n.treeTitle;

        return Scaffold(
          backgroundColor: colors.bg,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(treeName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: colors.ink)),
                Text(
                  '${l10n.treeTitle} · ${l10n.peopleCount(persons.length)} · ${l10n.generationsCount(_generationCount(result))}',
                  style: TextStyle(fontSize: 12.5, color: colors.ink3),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: l10n.searchAction,
                onPressed: () => context.push('/search'),
              ),
            ],
          ),
          body: LayoutBuilder(builder: (context, constraints) {
            final canvasSize =
                Size(constraints.maxWidth, constraints.maxHeight);
            if (!_fitted && result.nodes.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_fitted) {
                  _fit(result, canvasSize);
                  setState(() => _fitted = true);
                }
              });
            }
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.9),
                        radius: 1.4,
                        colors: [colors.surface2, colors.bg],
                        stops: const [0, 0.62],
                      ),
                    ),
                    child: ClipRect(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: (d) {
                          _startFocal = d.localFocalPoint;
                          _lastFocal = d.localFocalPoint;
                          _offsetStart = _viewport.offset;
                          _accumDist = 0;
                        },
                        onScaleUpdate: (d) {
                          if (_lastFocal != null) {
                            _accumDist +=
                                (d.localFocalPoint - _lastFocal!).distance;
                          }
                          _lastFocal = d.localFocalPoint;
                          if (_accumDist <= _tapSlop) return;
                          if (d.pointerCount >= 2) {
                            final ns =
                                (_viewport.scale * d.scale).clamp(0.3, 2.2);
                            _viewport.zoomAround(d.localFocalPoint, ns);
                          } else {
                            _viewport.set(
                              offset: _offsetStart +
                                  (d.localFocalPoint - _startFocal!),
                            );
                          }
                        },
                        onScaleEnd: (d) {
                          if (_accumDist <= _tapSlop && _lastFocal != null) {
                            final world =
                                (_lastFocal! - _viewport.offset) / _viewport.scale;
                            final hit = result.nodeAt(world);
                            if (hit != null) _openPerson(hit.person);
                          }
                          _startFocal = null;
                          _lastFocal = null;
                        },
                        child: Listener(
                          onPointerSignal: (signal) {
                            if (signal is PointerScrollEvent) {
                              _viewport.zoomAround(
                                signal.localPosition,
                                _viewport.scale *
                                    (signal.scrollDelta.dy < 0 ? 1.12 : 1 / 1.12),
                              );
                            }
                          },
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: TreePainter(
                              result: result,
                              visuals: visuals,
                              viewport: _viewport,
                              colors: colors,
                              selfBadge: self == null ? null : l10n.selfBadge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Column(
                    children: [
                      _zoomBtn(context, Icons.add, () => _zoomBy(1.22, canvasSize)),
                      const SizedBox(height: 8),
                      _zoomBtn(
                          context, Icons.remove, () => _zoomBy(1 / 1.22, canvasSize)),
                      const SizedBox(height: 8),
                      _zoomBtn(context, Icons.center_focus_weak,
                          () => _fit(result, canvasSize),
                          tooltip: l10n.fitView),
                    ],
                  ),
                ),
                Positioned(
                  left: 14,
                  bottom: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.line),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(l10n.treeHint,
                        style: TextStyle(fontSize: 11.5, color: colors.ink3)),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _zoomBtn(BuildContext context, IconData icon, VoidCallback onTap,
      {String? tooltip}) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final btn = Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: colors.ink2),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  PersonNodeVisual _visualFor(Person p, Locale locale, AppLocalizations l10n) {
    String years;
    if (!p.isLiving && p.deathDate != null) {
      years = '${p.birthDate?.year ?? '?'} – ${p.deathDate!.year}';
    } else if (p.birthDate != null) {
      years = '${l10n.bornAbbr} ${p.birthDate!.year}';
    } else {
      years = '';
    }
    final initials = ((p.givenName.isNotEmpty ? p.givenName[0] : '') +
            (p.surname.isNotEmpty ? p.surname[0] : ''))
        .toUpperCase();
    final palette = avatarColorsFor(p.id);
    return PersonNodeVisual(
      name: personDisplayName(p, locale),
      years: years,
      initials: initials.isEmpty ? '?' : initials,
      avatarTop: palette[0],
      avatarBottom: palette[1],
    );
  }

  int _generationCount(TreeLayoutResult result) {
    if (result.nodes.isEmpty) return 0;
    final maxGen =
        result.nodes.map((n) => n.generation).reduce((a, b) => a > b ? a : b);
    return maxGen + 1;
  }

  void _openPerson(Person p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PersonSheet(personId: p.id),
    );
  }
}

/// 姓名显示顺序按 locale（规划文档 6.6 坑 #4）：东亚姓前，其余名前。
String personDisplayName(Person p, Locale locale) {
  const surnameFirst = {'ja', 'ko', 'zh'};
  final full = surnameFirst.contains(locale.languageCode)
      ? '${p.surname} ${p.givenName}'
      : '${p.givenName} ${p.surname}';
  return full.trim().isEmpty ? '—' : full.trim();
}
