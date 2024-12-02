import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void showWhatsNewDialog(
    BuildContext context, WidgetRef ref, String? seenWhatsNewVersion) async {
  final version = (await PackageInfo.fromPlatform()).version;

  if (context.mounted && seenWhatsNewVersion != version) {
    final whatsNewDialogOpenSourceText = context.loc.whatsNewDialogOpenSource;

    showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'test',
      builder: (BuildContext context) {
        return AlertDialog(
          key: const Key('whats-new-dialog'),
          title: Text("What's New in NWT Reading"),
          content: SingleChildScrollView(
              child: Column(children: [
            Image(image: AssetImage('assets/images/whats_new/plans.png')),
            SizedBox(height: 20),
            RichText(
                text: TextSpan(
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
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: whatsNewDialogOpenSourceText.split('GitHub')[0],
                children: [
                  TextSpan(
                    text: 'GitHub',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse(
                            'https://github.com/searchwork/nwt-reading');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
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
                ref
                    .read(settingsProvider.notifier)
                    .updateSeenWhatsNewVersion(version);
                Navigator.pop(context, 'Got It');
              },
            ),
          ],
        );
      },
    );
  }
}
