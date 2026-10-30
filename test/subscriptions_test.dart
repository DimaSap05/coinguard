import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lab_1/app/data/models/subscription_model.dart';
import 'package:flutter_lab_1/app/data/repositories/subscription_repository/subscription_repository.dart';
import 'package:flutter_lab_1/app/features/home/bloc/home_bloc.dart';

// Подменяем только транспорт: JSON-разбор, репозиторий и BLoC настоящие.
class TestAdapter implements HttpClientAdapter {
  Object response = {'data': <Object>[]};
  int status = 200;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(response),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> record({String period = 'year'}) => {
  'id': 'remote_42',
  'name': 'Тестовая подписка',
  'price': 24000,
  'period': period,
  'nextBillingDate': '2026-12-01',
  'categoryColor': 4283215696,
  'categoryName': 'Спорт',
};

void main() {
  late Dio dio;
  late TestAdapter adapter;
  late SubscriptionRepository repository;
  setUp(() {
    adapter = TestAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = adapter;
    repository = SubscriptionRepository(dio: dio);
  });
  tearDown(() => dio.close());

  test('JSON сохраняет дату цвет и необязательное описание', () {
    final model = SubscriptionModel.fromJson(record());
    expect(model.description, isNull);
    expect(model.monthlyPrice, 2000);
    final copy = SubscriptionModel.fromJson(model.toJson());
    expect(copy.categoryColor, model.categoryColor);
    expect(copy.nextBillingDate, DateTime(2026, 12, 1));
  });

  test('Репозиторий разбирает HTTP ответ и кеширует серверный id', () async {
    adapter.response = {
      'data': [record()],
    };
    final result = await repository.getSubscriptions();
    expect(result.single.id, 'remote_42');
    expect(repository.findById('remote_42'), same(result.single));
    expect(repository.findById('missing'), isNull);
  });

  test('Неверный JSON и неизвестный период не затирают успешный кеш', () async {
    adapter.response = {
      'data': [record()],
    };
    await repository.getSubscriptions();
    adapter.response = {'unexpected': []};
    await expectLater(repository.getSubscriptions(), throwsFormatException);
    adapter.response = {
      'data': [record(period: 'week')],
    };
    await expectLater(repository.getSubscriptions(), throwsFormatException);
    expect(repository.findById('remote_42'), isNotNull);
  });

  test('BLoC сообщает ошибку HTTP и восстанавливается после повтора', () async {
    final bloc = HomeBloc(repository);
    addTearDown(bloc.close);
    adapter.status = 500;
    final failed = expectLater(
      bloc.stream,
      emitsInOrder([isA<HomeLoadInProgress>(), isA<HomeLoadFailure>()]),
    );
    final first = Completer<void>();
    bloc.add(HomeLoad(completer: first));
    await first.future;
    await failed;
    adapter.status = 200;
    adapter.response = {
      'data': [record()],
    };
    final recovered = expectLater(
      bloc.stream,
      emitsInOrder([isA<HomeLoadInProgress>(), isA<HomeLoadSuccess>()]),
    );
    final second = Completer<void>();
    bloc.add(HomeLoad(completer: second));
    await second.future;
    await recovered;
    expect(
      (bloc.state as HomeLoadSuccess).subscriptions.single.id,
      'remote_42',
    );
  });

  test('Пустой ответ является успешным состоянием', () async {
    final bloc = HomeBloc(repository);
    addTearDown(bloc.close);
    final done = Completer<void>();
    bloc.add(HomeLoad(completer: done));
    await done.future;
    expect((bloc.state as HomeLoadSuccess).subscriptions, isEmpty);
  });
}
