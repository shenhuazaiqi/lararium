import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/locale_resolver.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'data/providers.dart';

/// MaterialApp.router：locale 由 provider 驱动，应用内切换即时生效（规划文档 5.3.2）。
class LarariumApp extends ConsumerWidget {
  const LarariumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final override = ref.watch(localeOverrideProvider);
    final themeMode = ref.watch(themeModeProvider);

    final resolved = LocaleResolver.resolve(
      overrideTag: override,
    );

    return MaterialApp.router(
      title: 'Lararium',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: larariumTheme(Brightness.light),
      darkTheme: larariumTheme(Brightness.dark),
      themeMode: themeMode.followsSystem
          ? ThemeMode.system
          : (themeMode.isDark ? ThemeMode.dark : ThemeMode.light),
      locale: resolved,
      supportedLocales: [
        for (final tag in LocaleResolver.supportedTags)
          LocaleResolver.parseTag(tag),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
