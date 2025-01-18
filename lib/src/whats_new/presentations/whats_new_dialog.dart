import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';
import 'package:url_launcher/url_launcher.dart';

void showWhatsNewDialog(
    BuildContext context, WidgetRef ref, String? seenWhatsNewVersion) async {
  final settingsNotifier = ref.read(settingsProvider.notifier);

  if (await settingsNotifier.shouldShowWhatsNew()) {
    // The mounted check guard must be on its own for linting purpose.
    if (context.mounted) {
      final whatsNewDialogOpenSourceText = context.loc.whatsNewDialogOpenSource;

      showDialog<String>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'test',
        builder: (BuildContext context) {
          return AlertDialog(
            key: const Key('whats-new-dialog'),
            title: Text(context.loc.whatsNewDialogTitle),
            content: SingleChildScrollView(
                child: Column(children: [
              Image(image: AssetImage('assets/images/whats_new/plans.png')),
              SizedBox(height: 15),
              Text.rich(TextSpan(
                text: context.loc.whatsNewDialogPlans,
              )),
              SizedBox(height: 30),
              SvgPicture.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/whats_new/github_mark_white.svg'
                    : 'assets/images/whats_new/github_mark.svg',
                semanticsLabel: 'GitHub Logo',
                width: 30,
                height: 30,
              ),
              SizedBox(height: 15),
              Text.rich(
                TextSpan(
                  text: whatsNewDialogOpenSourceText.split('GitHub')[0],
                  children: [
                    TextSpan(
                      text: 'GitHub',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          final url = Uri.parse(
                              'https://github.com/searchwork/nwt-reading');
                          launchUrl(url);
                        },
                    ),
                    TextSpan(
                      text: whatsNewDialogOpenSourceText.split('GitHub')[1],
                    ),
                  ],
                ),
              ),
            ])),
            actions: <Widget>[
              OutlinedButton(
                key: const Key('later'),
                child: Text(context.loc.whatsNewDialogLaterButtonText),
                onPressed: () => Navigator.pop(context, 'Later'),
              ),
              FilledButton(
                key: const Key('got-it'),
                child: Text(context.loc.whatsNewDialogGotItButtonText),
                onPressed: () {
                  settingsNotifier.markWhatsNewAsSeen();
                  Navigator.pop(context, 'Got It');
                },
              ),
            ],
          );
        },
      );
    }
  }
}
