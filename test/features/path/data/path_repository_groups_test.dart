import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/path/data/path_repository_impl.dart';
import 'package:kilocal_flutter_app/l10n/app_localizations_it.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

/// Builds an area-steps response with the given main-tab [groups]. Each group
/// entry is `(title, completedFlags)` where `completedFlags` is one bool per
/// step. [categoriesPerGroup], when provided, is one list of `(id, title)`
/// category pairs per group (same order as [groups]) — mirrors
/// `groups[].categories` from the real backend.
Map<String, dynamic> _areaResponse(
  List<(String, List<bool>)> groups, {
  String area = 'benessere',
  List<Map<String, dynamic>> timeframes = const [],
  List<List<(String, String)>>? categoriesPerGroup,
}) {
  var stepId = 0;
  Map<String, dynamic> step(bool completed) => {
    'id': (stepId++).toString(),
    'sort': 0,
    'timeframe': {
      'id': 1,
      'sort': 0,
      'translations': [
        {'languages_code': 'it-IT', 'title': '1° mese'},
      ],
    },
    'translations': [
      {'languages_code': 'it-IT', 'title': 'Step'},
    ],
    'asset': {'asset_is_video': false, 'translations': <dynamic>[]},
    'started': false,
    'completed': completed,
    'is_current': false,
    'locked': false,
  };

  return {
    'data': {
      'area': area,
      'percorso': {
        'id': 'p1',
        'internal_name': area,
        'has_progressive_steps': true,
      },
      'progress': {'completed': 7, 'total': 21, 'percent': 33},
      'current_step_id': null,
      'active_timeframe': null,
      'access': {'restricted': false, 'percorso_locked': false},
      'timeframes': timeframes,
      // The wellbeing sub-sections come back as separate groups, all flagged
      // `is_percorso_main_tab: false` — mirror that here.
      'groups': [
        for (final (index, (title, flags)) in groups.indexed)
          {
            'id': title,
            'sort': null,
            'is_percorso_main_tab': false,
            'show_limited_steps_value': null,
            'translations': [
              {'languages_code': 'it-IT', 'title': title},
            ],
            'steps': [for (final c in flags) step(c)],
            if (categoriesPerGroup != null)
              'categories': [
                for (final (catId, catTitle) in categoriesPerGroup[index])
                  {
                    'percorsi_material_categories_id': {
                      'id': catId,
                      'translations': [
                        {'languages_code': 'it-IT', 'title': catTitle},
                      ],
                    },
                  },
              ],
          },
      ],
    },
  };
}

void main() {
  late _MockDio dio;
  late PathRepositoryImpl repository;
  final l10n = AppLocalizationsIt();

  setUp(() {
    dio = _MockDio();
    repository = PathRepositoryImpl(dio: dio);
  });

  void stubResponse(Map<String, dynamic> body) {
    when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
      (_) async => Response(
        data: body,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/path/me/areas/benessere/steps'),
      ),
    );
  }

  test(
    'maps each titled group to a PathAreaGroup with its own counts',
    () async {
      stubResponse(
        _areaResponse([
          ('Mindfulness', [true, false, true]),
          ('Self care', [false, false]),
          ('Stili di vita', [true, true, true, true]),
        ]),
      );

      final detail = await repository.fetchAreaSteps(
        area: 'benessere',
        l10n: l10n,
      );

      expect(detail.groups, hasLength(3));

      expect(detail.groups[0].title, 'Mindfulness');
      expect(detail.groups[0].completed, 2);
      expect(detail.groups[0].total, 3);

      expect(detail.groups[1].title, 'Self care');
      expect(detail.groups[1].completed, 0);
      expect(detail.groups[1].total, 2);

      expect(detail.groups[2].title, 'Stili di vita');
      expect(detail.groups[2].completed, 4);
      expect(detail.groups[2].total, 4);
    },
  );

  test(
    'includes titled groups even when is_percorso_main_tab is false',
    () async {
      // The real backend returns the three wellbeing sub-sections all flagged
      // `is_percorso_main_tab: false`; they must still surface as cards.
      stubResponse(
        _areaResponse([
          ('Mindfullness', <bool>[]),
          ('Self Care', <bool>[]),
          ('Stili di vita', <bool>[]),
        ]),
      );

      final detail = await repository.fetchAreaSteps(
        area: 'benessere',
        l10n: l10n,
      );

      expect(detail.groups.map((g) => g.title), [
        'Mindfullness',
        'Self Care',
        'Stili di vita',
      ]);
    },
  );

  test('excludes groups without a title', () async {
    final body = _areaResponse([
      ('Mindfulness', [true]),
    ]);
    (body['data']['groups'] as List).add({
      'id': 'untitled',
      'sort': null,
      'is_percorso_main_tab': false,
      'translations': <dynamic>[],
      'steps': <dynamic>[],
    });
    stubResponse(body);

    final detail = await repository.fetchAreaSteps(
      area: 'benessere',
      l10n: l10n,
    );

    expect(detail.groups.map((g) => g.title), ['Mindfulness']);
  });

  test('builds every month for a group, locked when it has no steps', () async {
    stubResponse(
      _areaResponse(
        [('Mindfullness', <bool>[])],
        timeframes: [
          {
            'id': 1,
            'sort': 1,
            'translations': [
              {'languages_code': 'it-IT', 'title': '1° mese'},
            ],
            'locked': false,
            'is_current': false,
            'is_past': false,
          },
          {
            'id': 2,
            'sort': 2,
            'translations': [
              {'languages_code': 'it-IT', 'title': '2° mese'},
            ],
            'locked': false,
            'is_current': false,
            'is_past': false,
          },
          {
            'id': 3,
            'sort': 3,
            'translations': [
              {'languages_code': 'it-IT', 'title': '3° mese'},
            ],
            'locked': false,
            'is_current': false,
            'is_past': false,
          },
        ],
      ),
    );

    final detail = await repository.fetchAreaSteps(
      area: 'benessere',
      l10n: l10n,
    );

    final months = detail.groups.single.months;
    expect(months, hasLength(3));
    expect(months.map((m) => m.title), ['1° mese', '2° mese', '3° mese']);
    // No steps in this group → every month is 0/0 and locked.
    for (final m in months) {
      expect(m.total, 0);
      expect(m.completed, 0);
      expect(m.isLocked, isTrue);
    }
  });

  test(
    'maps group.categories to PathAreaGroup.categories without throwing',
    () async {
      // Regression test: `group.categories ?? const []` without an explicit
      // element type made Dart infer the for-in loop variable as `dynamic`
      // when `categories` was non-null, so the `titleFor` extension method
      // (statically resolved) wasn't found on `category.translations` at
      // runtime — "PathCubit.load" swallowed it into a generic error and the
      // whole "Il tuo percorso" screen showed "Qualcosa è andato storto"
      // (user-reported 2026-07-27, only reproducible with real backend data
      // carrying populated categories — no existing test covered this shape).
      stubResponse(
        _areaResponse(
          [('Mindfullness', <bool>[]), ('Self Care', <bool>[])],
          categoriesPerGroup: [
            [('7', 'Scopri'), ('8', 'Consigli utili')],
            [('9', 'Scopri'), ('10', 'Consigli utili')],
          ],
        ),
      );

      final detail = await repository.fetchAreaSteps(
        area: 'benessere',
        l10n: l10n,
      );

      expect(detail.groups[0].categories.map((c) => (c.id, c.title)), [
        ('7', 'Scopri'),
        ('8', 'Consigli utili'),
      ]);
      expect(detail.groups[1].categories.map((c) => (c.id, c.title)), [
        ('9', 'Scopri'),
        ('10', 'Consigli utili'),
      ]);
    },
  );
}
