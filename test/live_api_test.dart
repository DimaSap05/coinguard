import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_lab_1/app/data/repositories/subscription_repository/subscription_repository.dart';

void main() {
  test('Настоящий HTTP API возвращает подписки CoinGuard', () async {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://127.0.0.1:8080',
        connectTimeout: const Duration(seconds: 5),
      ),
    );
    addTearDown(dio.close);
    final repository = SubscriptionRepository(dio: dio);
    final subscriptions = await repository.getSubscriptions();
    expect(subscriptions.map((s) => s.id), ['sub_1', 'sub_2', 'sub_3']);
    expect(
      subscriptions.fold<double>(0, (sum, s) => sum + s.monthlyPrice),
      2728,
    );
    expect(repository.findById('sub_3')?.price, 24000);
  }, skip: !const bool.fromEnvironment('RUN_API_TESTS'));
}
