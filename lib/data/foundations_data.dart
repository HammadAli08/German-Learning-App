/// GermanLoop — Foundations track data.
/// 10 lessons structured to match Goethe Institut A1 beginner order.

class LessonItem {
  final String de;
  final String en;
  final String? note;

  const LessonItem(this.de, this.en, {this.note});
}

class ConjugationTable {
  final String infinitive;
  final String infinitiveEn;
  final List<List<String>> rows; // [pronoun, conjugated, en]

  const ConjugationTable({
    required this.infinitive,
    required this.infinitiveEn,
    required this.rows,
  });
}

class WordOrderExample {
  final String de;
  final String en;
  final String ruleNote;

  const WordOrderExample(this.de, this.en, this.ruleNote);
}

enum LessonContentType { vocab, conjugation, wordOrder, pronunciationRules }

class FoundationsLesson {
  final int id;
  final String title;
  final String subtitle;
  final LessonContentType primaryContent;
  final List<LessonItem> items;
  final List<ConjugationTable> conjugationTables;
  final List<WordOrderExample> wordOrderExamples;

  const FoundationsLesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.primaryContent,
    this.items = const [],
    this.conjugationTables = const [],
    this.wordOrderExamples = const [],
  });
}

// ── Lesson data ───────────────────────────────────────────────────────────────

const List<FoundationsLesson> kFoundationsLessons = [
  // ── Lesson 1 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 1,
    title: 'The Alphabet & Core Sounds',
    subtitle: 'German letters, special characters, and pronunciation rules',
    primaryContent: LessonContentType.pronunciationRules,
    items: [
      LessonItem('A, B, C, D, E, F, G', 'the German alphabet begins', note: 'Same letters as English — but every one is pronounced differently'),
      LessonItem('ä', 'like the "e" in bed'),
      LessonItem('ö', 'round lips as if whistling, say "e"'),
      LessonItem('ü', 'round lips as if whistling, say "ee"'),
      LessonItem('ß', 'sharp unvoiced "s" — never used at the start of a word'),
    ],
  ),

  // ── Lesson 2 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 2,
    title: 'Numbers',
    subtitle: '0–100 — count and handle prices',
    primaryContent: LessonContentType.vocab,
    items: [
      LessonItem('null', 'zero'),
      LessonItem('eins', 'one'),
      LessonItem('zwei', 'two'),
      LessonItem('drei', 'three'),
      LessonItem('vier', 'four'),
      LessonItem('fünf', 'five'),
      LessonItem('sechs', 'six'),
      LessonItem('sieben', 'seven'),
      LessonItem('acht', 'eight'),
      LessonItem('neun', 'nine'),
      LessonItem('zehn', 'ten'),
      LessonItem('elf', 'eleven'),
      LessonItem('zwölf', 'twelve'),
      LessonItem('dreizehn', 'thirteen'),
      LessonItem('vierzehn', 'fourteen'),
      LessonItem('fünfzehn', 'fifteen'),
      LessonItem('sechzehn', 'sixteen'),
      LessonItem('siebzehn', 'seventeen'),
      LessonItem('achtzehn', 'eighteen'),
      LessonItem('neunzehn', 'nineteen'),
      LessonItem('zwanzig', 'twenty'),
      LessonItem('dreißig', 'thirty'),
      LessonItem('vierzig', 'forty'),
      LessonItem('fünfzig', 'fifty'),
      LessonItem('sechzig', 'sixty'),
      LessonItem('siebzig', 'seventy'),
      LessonItem('achtzig', 'eighty'),
      LessonItem('neunzig', 'ninety'),
      LessonItem('hundert', 'one hundred'),
    ],
  ),

  // ── Lesson 3 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 3,
    title: 'Greetings & Time of Day',
    subtitle: 'Essential phrases for meeting people',
    primaryContent: LessonContentType.vocab,
    items: [
      LessonItem('Guten Morgen', 'Good morning'),
      LessonItem('Guten Tag', 'Good day / Hello'),
      LessonItem('Guten Abend', 'Good evening'),
      LessonItem('Gute Nacht', 'Good night'),
      LessonItem('Hallo', 'Hi / Hello'),
      LessonItem('Tschüss', 'Bye (informal)'),
      LessonItem('Auf Wiedersehen', 'Goodbye (formal)'),
      LessonItem('Wie geht es dir?', 'How are you? (informal — use with friends)',
          note: '"dir" is the informal form — use with friends, family, and peers'),
      LessonItem('Wie geht es Ihnen?', 'How are you? (formal)',
          note: '"Ihnen" is the formal form — use with strangers or in professional settings'),
      LessonItem('Mir geht es gut.', 'I am doing well.'),
      LessonItem('Mir geht es schlecht.', 'I am not doing well.'),
      LessonItem('Ich heiße …', 'My name is …'),
      LessonItem('Wie heißt du?', 'What is your name? (informal)'),
      LessonItem('Wie heißen Sie?', 'What is your name? (formal)'),
      LessonItem('Freut mich.', 'Nice to meet you.'),
    ],
  ),

  // ── Lesson 4 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 4,
    title: 'Pronouns, sein & haben',
    subtitle: 'Personal pronouns and the two most important verbs',
    primaryContent: LessonContentType.conjugation,
    items: [
      LessonItem('ich', 'I'),
      LessonItem('du', 'you (informal)'),
      LessonItem('er', 'he'),
      LessonItem('sie', 'she'),
      LessonItem('es', 'it'),
      LessonItem('wir', 'we'),
      LessonItem('ihr', 'you all (informal plural)'),
      LessonItem('sie', 'they'),
      LessonItem('Sie', 'you (formal — always capitalised)'),
    ],
    conjugationTables: [
      ConjugationTable(
        infinitive: 'sein',
        infinitiveEn: 'to be',
        rows: [
          ['ich', 'bin', 'I am'],
          ['du', 'bist', 'you are'],
          ['er / sie / es', 'ist', 'he / she / it is'],
          ['wir', 'sind', 'we are'],
          ['ihr', 'seid', 'you all are'],
          ['sie / Sie', 'sind', 'they / you (formal) are'],
        ],
      ),
      ConjugationTable(
        infinitive: 'haben',
        infinitiveEn: 'to have',
        rows: [
          ['ich', 'habe', 'I have'],
          ['du', 'hast', 'you have'],
          ['er / sie / es', 'hat', 'he / she / it has'],
          ['wir', 'haben', 'we have'],
          ['ihr', 'habt', 'you all have'],
          ['sie / Sie', 'haben', 'they / you (formal) have'],
        ],
      ),
    ],
  ),

  // ── Lesson 5 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 5,
    title: 'Sentence Word Order',
    subtitle: 'The single biggest structural difference from English',
    primaryContent: LessonContentType.wordOrder,
    wordOrderExamples: [
      WordOrderExample(
        'Ich lerne Deutsch.',
        'I am learning German.',
        'In a plain statement the verb comes second — right after the subject.',
      ),
      WordOrderExample(
        'Lernst du Deutsch?',
        'Are you learning German?',
        'In a yes/no question the verb comes first — before the subject.',
      ),
      WordOrderExample(
        'Ich möchte Deutsch lernen.',
        'I would like to learn German.',
        'With a modal verb (möchte), the modal is second and the main verb jumps to the very end in its infinitive form.',
      ),
    ],
    items: [
      LessonItem('Ich lerne Deutsch.', 'I am learning German.'),
      LessonItem('Lernst du Deutsch?', 'Are you learning German?'),
      LessonItem('Ich möchte Deutsch lernen.', 'I would like to learn German.'),
    ],
  ),

  // ── Lesson 6 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 6,
    title: 'Articles, Gender & Formal Address',
    subtitle: 'der / die / das and the du vs. Sie distinction',
    primaryContent: LessonContentType.vocab,
    items: [
      LessonItem('der Mann', 'the man (masculine — der)',
          note: 'Masculine nouns use "der"'),
      LessonItem('die Frau', 'the woman (feminine — die)',
          note: 'Feminine nouns use "die"'),
      LessonItem('das Kind', 'the child (neuter — das)',
          note: 'Neuter nouns use "das" — gender must be memorised with each word'),
      LessonItem('du', 'you (informal)',
          note: 'Use with friends, family, children, and people your own age in casual settings'),
      LessonItem('Sie', 'you (formal)',
          note: 'Use with strangers, in professional settings, or as a sign of respect with anyone older or in authority. Always written with a capital S.'),
    ],
  ),

  // ── Lesson 7 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 7,
    title: 'Question Words',
    subtitle: 'wer, was, wo, wann, warum, wie, wie viel',
    primaryContent: LessonContentType.vocab,
    items: [
      LessonItem('Wer ist das?', 'Who is that?', note: 'wer = who'),
      LessonItem('Was machst du?', 'What are you doing?', note: 'was = what'),
      LessonItem('Wo bist du?', 'Where are you?', note: 'wo = where'),
      LessonItem('Wann kommst du?', 'When are you coming?', note: 'wann = when'),
      LessonItem('Warum lernst du Deutsch?', 'Why are you learning German?',
          note: 'warum = why'),
      LessonItem('Wie heißt du?', 'What is your name?', note: 'wie = how'),
      LessonItem('Wie viel kostet das?', 'How much does that cost?',
          note: 'wie viel = how much'),
    ],
  ),

  // ── Lesson 8 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 8,
    title: 'Food, Shopping & Prices',
    subtitle: 'Survive any German café or market',
    primaryContent: LessonContentType.vocab,
    items: [
      LessonItem('das Brot', 'bread'),
      LessonItem('das Wasser', 'water'),
      LessonItem('der Kaffee', 'coffee'),
      LessonItem('der Apfel', 'apple'),
      LessonItem('die Milch', 'milk'),
      LessonItem('Das kostet …', 'That costs …'),
      LessonItem('Wie viel kostet das?', 'How much does that cost?'),
      LessonItem('Die Rechnung, bitte.', 'The bill, please.'),
      LessonItem('Ich möchte … bitte.', 'I would like … please.'),
    ],
  ),

  // ── Lesson 9 ─────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 9,
    title: 'Family',
    subtitle: 'Talk about the people closest to you',
    primaryContent: LessonContentType.vocab,
    items: [
      LessonItem('die Familie', 'the family'),
      LessonItem('die Mutter', 'the mother'),
      LessonItem('der Vater', 'the father'),
      LessonItem('die Schwester', 'the sister'),
      LessonItem('der Bruder', 'the brother'),
      LessonItem('mein', 'my (before masculine or neuter nouns)',
          note: '"mein" changes to "meine" before feminine nouns: meine Mutter, meine Schwester'),
      LessonItem('meine', 'my (before feminine nouns)'),
    ],
  ),

  // ── Lesson 10 ────────────────────────────────────────────────────────────
  FoundationsLesson(
    id: 10,
    title: 'Travel & Directions',
    subtitle: 'Find your way around any German city',
    primaryContent: LessonContentType.vocab,
    items: [
      LessonItem('links', 'left'),
      LessonItem('rechts', 'right'),
      LessonItem('geradeaus', 'straight ahead'),
      LessonItem('der Bahnhof', 'the train station'),
      LessonItem('der Zug', 'the train'),
      LessonItem('das Flugzeug', 'the airplane'),
      LessonItem('Wo ist …?', 'Where is …?'),
    ],
  ),
];
