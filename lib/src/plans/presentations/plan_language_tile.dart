import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanLanguageTile extends ConsumerWidget {
  const PlanLanguageTile(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);
    final bibleLanguages = ref.watch(bibleLanguagesProvider).valueOrNull;

    return ListTile(
      title: Text(context.loc.planEditPageLanguageLabel),
      subtitle: DropdownButton<String>(
        key: const Key('language'),
        value: bibleLanguages?.bibleLanguages[plan.language] == null
            ? 'en'
            : plan.language,
        onChanged: (String? value) {
          if (value != null) planEdit.updateLanguage(value);
        },
        items: bibleLanguages?.bibleLanguages.entries
            .map((MapEntry<String, BibleLanguage> bibleLanguage) =>
                DropdownMenuItem<String>(
                  value: bibleLanguage.key,
                  child: Text(
                    bibleLanguage.value.name,
                    key: Key('language-${bibleLanguage.key}'),
                  ),
                ))
            .toList(),
        isExpanded: true,
      ),
    );
  }
}
