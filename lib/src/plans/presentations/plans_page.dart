import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/presentations/plan_edit_dialog.dart';
import 'package:nwt_reading/src/plans/presentations/plans_grid.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';
import 'package:nwt_reading/src/whats_new/presentations/whats_new_dialog.dart';

import '../../settings/presentations/settings_page.dart';

class PlansPage extends ConsumerStatefulWidget {
  const PlansPage({super.key});
  static const routeName = '/';

  @override
  PlansPageState createState() => PlansPageState();
}

class PlansPageState extends ConsumerState<PlansPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      callWhatsNewDialog(context);
    });
  }

  void callWhatsNewDialog(BuildContext context) async {
    final seenWhatsNewVersion =
        (await ref.read(settingsProvider.future)).seenWhatsNewVersion;

    if (context.mounted) {
      showWhatsNewDialog(context, ref, seenWhatsNewVersion);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(context.loc.plansPageTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.restorablePushNamed(context, SettingsPage.routeName);
              },
            ),
          ],
        ),
        body: PlansGrid(
          key: const Key('plans-grid'),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: context.loc.plansPageAddPlanTooltip,
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => PlanEditDialog(),
          ),
          child: const Icon(Icons.add),
        ),
      );
}
