import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_ui/ui/widgets/dialogs/school_form_dialog.dart';
import 'package:school_shared/school_shared.dart';
import '../../../helpers/test_wrapper.dart';

class MockCreateUseCase extends Mock implements CreateUseCase {}

class MockUpdateUseCase extends Mock implements UpdateUseCase {}

void main() {
  setUpAll(() async {
    await initTestServices();
  });

  late MockCreateUseCase mockCreateUseCase;
  late MockUpdateUseCase mockUpdateUseCase;

  setUp(() {
    mockCreateUseCase = MockCreateUseCase();
    mockUpdateUseCase = MockUpdateUseCase();

    registerFallbackValue(
      SchoolDetails(
        id: '',
        name: '',
        email: '',
        address: '',
        phone: '',
        code: '',
        locationCity: '',
        locationDistrict: '',
        director: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: SchoolStatus.active,
      ),
    );
  });

  testWidgets('should show Create School title in creation mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        SchoolFormDialog(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
        ),
      ),
    );

    expect(find.text('Criar Escola'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('should show Edit School title in edit mode', (tester) async {
    final school = SchoolDetails(
      id: '1',
      name: 'Test School',
      email: 'test@school.com',
      address: 'Test Address',
      phone: '(11) 98765-4321',
      code: 'CIE001',
      locationCity: 'City',
      locationDistrict: 'District',
      director: 'Director',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: SchoolStatus.active,
    );

    await tester.pumpWidget(
      wrapWithMaterial(
        SchoolFormDialog(
          createUseCase: mockCreateUseCase,
          updateUseCase: mockUpdateUseCase,
          initialData: school,
        ),
      ),
    );

    expect(find.text('Editar Escola'), findsOneWidget);
  });

  testWidgets('should close dialog when clicking close button', (tester) async {
    await tester.pumpWidget(
      wrapWithMaterial(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog<SchoolDetails>(
              context: context,
              builder: (context) => SchoolFormDialog(
                createUseCase: mockCreateUseCase,
                updateUseCase: mockUpdateUseCase,
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(SchoolFormDialog), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(SchoolFormDialog), findsNothing);
  });
}
