import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_and_api_for_class/config/router/app_route.dart';
import 'package:hive_and_api_for_class/features/auth/domain/use_case/auth_usecase.dart';
import 'package:hive_and_api_for_class/features/auth/presentation/viewmodel/auth_view_model.dart';
import 'package:hive_and_api_for_class/features/batch/domain/entity/batch_entity.dart';
import 'package:hive_and_api_for_class/features/batch/domain/use_case/batch_use_case.dart';
import 'package:hive_and_api_for_class/features/batch/presentation/viewmodel/batch_view_model.dart';
import 'package:hive_and_api_for_class/features/course/domain/entity/course_entity.dart';
import 'package:hive_and_api_for_class/features/course/domain/use_case/course_usecase.dart';
import 'package:hive_and_api_for_class/features/course/presentation/viewmodel/course_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../build/unit_test_assets/test_data/batch_entity_test.dart';
import '../../../../../build/unit_test_assets/test_data/course_entity_test.dart';
import '../../../../unit_test/auth_unit_test.mocks.dart';
import '../../../../unit_test/batch_unit_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthUseCase>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthUseCase mockAuthUseCase;
  late BatchUseCase mockBatchUseCase;
  late CourseUseCase mockCourseUseCase;

  late List<CourseEntity> lstCourses;
  late List<BatchEntity> lstBatches;
  late bool isLogin;

  setUpAll(() async {
    mockAuthUseCase = MockAuthUseCase();
    mockBatchUseCase = MockBatchUseCase();
    mockCourseUseCase = MockCourseUseCase();

    lstCourses = await getCourseListTest();
    lstBatches = await getBatchListTest();

    isLogin = true;
  });

  testWidgets('Login test with username and password', (tester) async {
    when(mockAuthUseCase.loginStudent('amsh', 'amsh123'))
        .thenAnswer((_) => Future.value(Right(isLogin)));

    // Dashboard Khulni bittikai getAllbatches and getAllcourses()
    when(mockCourseUseCase.getAllCourses())
        .thenAnswer((_) => Future.value(Right(lstCourses)));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider
              .overrideWith((ref) => AuthViewModel(mockAuthUseCase)),
          courseViewModelProvider
              .overrideWith((ref) => CourseViewModel(mockCourseUseCase)),
          batchViewModelProvider
              .overrideWith((ref) => BatchViewModel(mockBatchUseCase)),
        ],
        child: MaterialApp(
          initialRoute: AppRoute.loginRoute,
          routes: AppRoute.getApplicationRoute(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // enter amsh in textfield username
    await tester.enterText(find.byType(TextFormField).at(0), 'amsh');
    await tester.enterText(find.byType(TextFormField).at(1), 'amsh123');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));

    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Dashboard View'), findsOneWidget);
  });
}
