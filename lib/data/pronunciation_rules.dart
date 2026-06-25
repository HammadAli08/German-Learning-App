/// GermanLoop — static pronunciation rules lookup.
/// 21 hardcoded rules. Use [matchingRules] to scan any German text.

class PronunciationRule {
  final int id;
  final String pattern;
  final String explanation;
  final String exampleWord;

  const PronunciationRule({
    required this.id,
    required this.pattern,
    required this.explanation,
    required this.exampleWord,
  });
}

const List<PronunciationRule> kPronunciationRules = [
  PronunciationRule(
    id: 1,
    pattern: 'ch',
    explanation:
        'After a, o, u, au: a hard, throaty sound made at the back of the mouth, like the ch in the Scottish word "loch".',
    exampleWord: 'Buch',
  ),
  PronunciationRule(
    id: 2,
    pattern: 'ch',
    explanation:
        'After e, i, ä, ö, ü, eu, äu, or a consonant: a soft hissing sound made just behind the front teeth.',
    exampleWord: 'ich',
  ),
  PronunciationRule(
    id: 3,
    pattern: 'sch',
    explanation: 'Always sounds like the English "sh", no exceptions.',
    exampleWord: 'Schule',
  ),
  PronunciationRule(
    id: 4,
    pattern: 'sp/st',
    explanation:
        'sp or st at the start of a word or syllable: pronounced "shp" and "sht".',
    exampleWord: 'sprechen',
  ),
  PronunciationRule(
    id: 5,
    pattern: 'w',
    explanation: 'Sounds like an English "v".',
    exampleWord: 'wir',
  ),
  PronunciationRule(
    id: 6,
    pattern: 'v',
    explanation:
        'Usually sounds like an English "f", except in a few borrowed words where it sounds like an English "v".',
    exampleWord: 'Vater',
  ),
  PronunciationRule(
    id: 7,
    pattern: 'z',
    explanation: 'Sounds like "ts", as in "cats".',
    exampleWord: 'Zeit',
  ),
  PronunciationRule(
    id: 8,
    pattern: 's',
    explanation: 'Before a vowel: sounds like an English "z".',
    exampleWord: 'Sonne',
  ),
  PronunciationRule(
    id: 9,
    pattern: 'ß/ss',
    explanation: 'A sharp, unvoiced "s" sound.',
    exampleWord: 'groß',
  ),
  PronunciationRule(
    id: 10,
    pattern: 'ei',
    explanation: 'Sounds like the English word "eye".',
    exampleWord: 'mein',
  ),
  PronunciationRule(
    id: 11,
    pattern: 'ie',
    explanation: 'One long "ee" sound.',
    exampleWord: 'sie',
  ),
  PronunciationRule(
    id: 12,
    pattern: 'eu/äu',
    explanation: 'Sounds like "oy", as in "boy".',
    exampleWord: 'neu',
  ),
  PronunciationRule(
    id: 13,
    pattern: 'j',
    explanation: 'Sounds like an English "y".',
    exampleWord: 'ja',
  ),
  PronunciationRule(
    id: 14,
    pattern: 'pf',
    explanation:
        'Both letters said quickly together, almost as one sound, like in "stepfather".',
    exampleWord: 'Apfel',
  ),
  PronunciationRule(
    id: 15,
    pattern: 'qu',
    explanation: 'Sounds like "kv".',
    exampleWord: 'Quelle',
  ),
  PronunciationRule(
    id: 16,
    pattern: 'r',
    explanation:
        'At the start of a syllable: a throaty sound made at the back of the mouth. Softer elsewhere in a word, almost like an "uh" sound.',
    exampleWord: 'rot',
  ),
  PronunciationRule(
    id: 17,
    pattern: 'ä',
    explanation: 'Like the "e" in the English word "bed".',
    exampleWord: 'Mädchen',
  ),
  PronunciationRule(
    id: 18,
    pattern: 'ö',
    explanation:
        'Round your lips as if about to whistle while saying an "e" sound.',
    exampleWord: 'schön',
  ),
  PronunciationRule(
    id: 19,
    pattern: 'ü',
    explanation:
        'Round your lips as if about to whistle while saying an "ee" sound.',
    exampleWord: 'müde',
  ),
  PronunciationRule(
    id: 20,
    pattern: 'long vowel',
    explanation:
        'A vowel followed by a single consonant or by "h" is long.',
    exampleWord: 'Sohn',
  ),
  PronunciationRule(
    id: 21,
    pattern: 'short vowel',
    explanation: 'A vowel followed by a double consonant is short.',
    exampleWord: 'Mutter',
  ),
];

/// Returns all pronunciation rules whose pattern is visibly present in [text].
/// Uses simple substring / regex checks; order-independent.
List<PronunciationRule> matchingRules(String text) {
  final lower = text.toLowerCase();
  final results = <PronunciationRule>[];

  for (final rule in kPronunciationRules) {
    bool matches = false;
    switch (rule.id) {
      case 1: // ch after a,o,u,au
        matches = RegExp(r'[aouk]ch', caseSensitive: false).hasMatch(lower) ||
            lower.contains('auch');
        break;
      case 2: // ch after e,i,ä,ö,ü,eu,äu or consonant
        matches =
            RegExp(r'[eiäöü]ch|[lnrsch]ch', caseSensitive: false).hasMatch(lower);
        break;
      case 3:
        matches = lower.contains('sch');
        break;
      case 4:
        matches = RegExp(r'\bsp|\bst', caseSensitive: false).hasMatch(lower);
        break;
      case 5:
        matches = lower.contains('w');
        break;
      case 6:
        matches = lower.contains('v');
        break;
      case 7:
        matches = lower.contains('z');
        break;
      case 8: // s before vowel
        matches = RegExp(r's[aeiouäöü]', caseSensitive: false).hasMatch(lower);
        break;
      case 9:
        matches = lower.contains('ß') || lower.contains('ss');
        break;
      case 10:
        matches = lower.contains('ei');
        break;
      case 11:
        matches = lower.contains('ie');
        break;
      case 12:
        matches = lower.contains('eu') || lower.contains('äu');
        break;
      case 13:
        matches = lower.contains('j');
        break;
      case 14:
        matches = lower.contains('pf');
        break;
      case 15:
        matches = lower.contains('qu');
        break;
      case 16:
        matches = lower.contains('r');
        break;
      case 17:
        matches = lower.contains('ä');
        break;
      case 18:
        matches = lower.contains('ö');
        break;
      case 19:
        matches = lower.contains('ü');
        break;
      case 20: // long vowel heuristic
        matches = RegExp(r'[aeiouäöü]h|[aeiouäöü][^aeiouäöüh\s](?!\s)',
                caseSensitive: false)
            .hasMatch(lower);
        break;
      case 21: // short vowel / double consonant
        matches =
            RegExp(r'[aeiouäöü][bcdfghjklmnpqrstvwxyz]\1', caseSensitive: false)
                .hasMatch(lower);
        break;
    }
    if (matches) results.add(rule);
  }
  return results;
}
