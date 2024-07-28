import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';
import 'package:nwt_reading/src/theme.dart';

import 'schedules/presentations/schedule_page.dart';
import 'plans/presentations/plans_page.dart';
import 'settings/presentations/settings_page.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).valueOrNull;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        restorationScopeId: 'app',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (BuildContext context) =>
            AppLocalizations.of(context)!.appTitle,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode,

        // Define a function to handle named routes in order to support
        // Flutter web url navigation and deep linking.
        onGenerateRoute: (RouteSettings routeSettings) =>
            MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsPage.routeName:
                    return const SettingsPage();
                  case SchedulePage.routeName:
                    return const SchedulePage();
                  case PlansPage.routeName:
                  default:
                    return const PlansPage();
                }
              },
            ));
  }
}
