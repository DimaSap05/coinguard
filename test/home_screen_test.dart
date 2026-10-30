import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lab_1/app/data/data.dart';
import 'package:flutter_lab_1/app/features/content/content_screen.dart';
import 'package:flutter_lab_1/app/features/home/bloc/home_bloc.dart';
import 'package:flutter_lab_1/app/features/home/home_screen.dart';
import 'package:flutter_lab_1/di/di.dart';

class ScreenRepository implements SubscriptionRepositoryInterface {
  bool fail = false;
  final subscription = SubscriptionModel(
    id: 'server_id',
    name: 'Сервис с API',
    price: 1200,
    period: 'year',
    nextBillingDate: DateTime(2026, 12, 1),
    categoryColor: Colors.green,
    categoryName: 'Учеба',
    description: 'Данные сервера',
  );
  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    if (fail) throw Exception('Нет соединения');
    return [subscription];
  }

  @override
  SubscriptionModel? findById(String id) =>
      id == subscription.id ? subscription : null;
}

void main() {
  testWidgets('Сводка из BLoC переход в детали и повтор после ошибки', (
    tester,
  ) async {
    final repository = ScreenRepository();
    final bloc = HomeBloc(repository);
    getIt.registerSingleton<SubscriptionRepositoryInterface>(repository);
    getIt.registerSingleton(bloc);
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/content/:id',
          builder: (_, state) =>
              ContentScreen(contentId: state.pathParameters['id']!),
        ),
      ],
    );
    addTearDown(() async {
      router.dispose();
      await bloc.close();
      await getIt.reset();
    });
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('100 ₽'), findsOneWidget);
    expect(find.text('Активных подписок: 1'), findsOneWidget);
    await tester.tap(find.text('Сервис с API'));
    await tester.pumpAndSettle();
    expect(find.text('Тарифный план'), findsOneWidget);
    expect(find.text('Учеба'), findsOneWidget);
    expect(tester.takeException(), isNull);
    router.pop();
    await tester.pumpAndSettle();
    repository.fail = true;
    await tester.tap(find.byTooltip('Обновить подписки'));
    await tester.pumpAndSettle();
    expect(find.text('Повторить'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.text('100 ₽'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
