import 'package:flutter_test/flutter_test.dart';
import 'package:kilocal_flutter_app/features/path/domain/entities/path_material.dart';
import 'package:kilocal_flutter_app/features/path/domain/path_materials_repository.dart';
import 'package:kilocal_flutter_app/features/path/presentation/cubit/path_materials_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockPathMaterialsRepository extends Mock
    implements PathMaterialsRepository {}

void main() {
  late _MockPathMaterialsRepository repository;
  late PathMaterialsCubit cubit;

  setUp(() {
    repository = _MockPathMaterialsRepository();
    cubit = PathMaterialsCubit(materialsRepository: repository);
  });

  tearDown(() => cubit.close());

  test(
    'appends material-derived categories missing from the official group list',
    () async {
      when(
        () => repository.fetchMaterials(groupId: 'stile-vita', area: 'benessere'),
      ).thenAnswer(
        (_) async => const PathMaterialsData(
          categories: [
            PathMaterialCategory(
              id: 'schede',
              title: 'Schede',
              internalName: PathMaterialCategories.sheets,
            ),
          ],
          materials: [
            PathMaterial(
              id: 'asia-pdf',
              title: 'Tutto quello che devi sapere per il tuo viaggio in Asia',
              isVideo: false,
              isAvailable: true,
              isCompleted: false,
              categoryIds: ['schede'],
              hidesImage: true,
            ),
          ],
        ),
      );

      await cubit.load(
        groupId: 'stile-vita',
        area: 'benessere',
        officialCategories: const [
          PathMaterialCategory(id: 'scopri', title: 'Scopri'),
        ],
      );

      expect(cubit.state.selectedCategoryId, 'scopri');
      expect(cubit.state.data!.categories.map((c) => (c.id, c.title)), [
        ('scopri', 'Scopri'),
        ('schede', 'Schede'),
      ]);
    },
  );
}
