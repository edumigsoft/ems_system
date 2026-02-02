import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_ui/ui/widgets/components/desktop/desktop_table_widget.dart';
import 'package:school_ui/ui/view_models/school_view_model.dart';
import 'package:school_shared/school_shared.dart';
import 'package:core_shared/core_shared.dart';
import '../../../../helpers/test_wrapper.dart';

class MockGetAllUseCase extends Mock implements GetAllUseCase {}

class MockGetDeletedSchoolsUseCase extends Mock
    implements GetDeletedSchoolsUseCase {}

class MockCreateUseCase extends Mock implements CreateUseCase {}

class MockUpdateUseCase extends Mock implements UpdateUseCase {}

class MockDeleteUseCase extends Mock implements DeleteUseCase {}

class MockRestoreSchoolUseCase extends Mock implements RestoreSchoolUseCase {}

void main() {
  setUpAll(() async {
    await initTestServices();
  });

  late MockGetAllUseCase mockGetAllUseCase;
  late MockGetDeletedSchoolsUseCase mockGetDeletedUseCase;
  late MockCreateUseCase mockCreateUseCase;
  late MockUpdateUseCase mockUpdateUseCase;
  late MockDeleteUseCase mockDeleteUseCase;
  late MockRestoreSchoolUseCase mockRestoreUseCase;
  late SchoolViewModel viewModel;

  final schools = [
    SchoolDetails(
      id: '1',
      name: 'School A',
      email: 'a@test.com',
      address: 'Addr A',
      phone: '(11) 98765-4321',
      code: 'C01',
      locationCity: 'City A',
      locationDistrict: 'Dist A',
      director: 'Dir A',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: SchoolStatus.active,
    ),
  ];

  setUp(() {
    mockGetAllUseCase = MockGetAllUseCase();
    mockGetDeletedUseCase = MockGetDeletedSchoolsUseCase();
    mockCreateUseCase = MockCreateUseCase();
    mockUpdateUseCase = MockUpdateUseCase();
    mockDeleteUseCase = MockDeleteUseCase();
    mockRestoreUseCase = MockRestoreSchoolUseCase();

    when(() => mockGetAllUseCase.execute()).thenAnswer(
      (_) async => Success(
        PaginatedResult(
          items: schools,
          total: 1,
          page: 1,
          limit: 10,
        ),
      ),
    );

    viewModel = SchoolViewModel(
      getAllUseCase: mockGetAllUseCase,
      getDeletedUseCase: mockGetDeletedUseCase,
      createUseCase: mockCreateUseCase,
      updateUseCase: mockUpdateUseCase,
      deleteUseCase: mockDeleteUseCase,
      restoreUseCase: mockRestoreUseCase,
    );
  });

  testWidgets('should display school in table', (tester) async {
    // Inicializar viewModel (gera fetchAll)
    await viewModel.init();

    await tester.pumpWidget(
      wrapWithMaterial(
        DesktopTableWidget(viewModel: viewModel),
      ),
    );

    expect(find.text('School A'), findsOneWidget);
    expect(find.textContaining('C01'), findsOneWidget);
  });

  testWidgets('should open create dialog when clicking Novo button', (
    tester,
  ) async {
    await viewModel.init();

    await tester.pumpWidget(
      wrapWithMaterial(
        DesktopTableWidget(viewModel: viewModel),
      ),
    );

    final novoButton = find.text('Adicionar Escola');
    expect(novoButton, findsOneWidget);

    await tester.tap(novoButton);
    await tester.pumpAndSettle();

    // Verifica se o título do diálogo de cadastro aparece
    expect(find.text('Criar Escola'), findsOneWidget);
  });
}
