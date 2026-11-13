import 'package:dio/dio.dart';
import 'package:flutter_lab_1/app/data/endpoints.dart';
import 'package:flutter_lab_1/app/data/models/subscription_model.dart';

import 'subscription_repository_interface.dart';

class SubscriptionRepository implements SubscriptionRepositoryInterface {
  SubscriptionRepository({required this.dio});

  final Dio dio;
  List<SubscriptionModel> _subscriptions = const [];

  @override
  Future<SubscriptionModel> getSubscriptionById(String id) async {
    final response = await dio.get<Map<String, dynamic>>(
      Endpoints.subscription(id),
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('API не вернул объект подписки в поле data');
    }
    final subscription = _parseSubscription(data);
    if (subscription.id != id) {
      throw const FormatException('API вернул другую подписку');
    }
    return subscription;
  }

  SubscriptionModel _parseSubscription(Map<String, dynamic> data) {
    final subscription = SubscriptionModel.fromJson(data);
    if (subscription.id.isEmpty ||
        subscription.price < 0 ||
        !subscription.price.isFinite ||
        !const ['month', 'year'].contains(subscription.period)) {
      throw const FormatException('Некорректные данные подписки');
    }
    return subscription;
  }

  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    final response = await dio.get<Map<String, dynamic>>(
      Endpoints.subscriptions,
    );
    final data = response.data?['data'];
    if (data is! List) {
      throw const FormatException('API не вернул список подписок в поле data');
    }
    final subscriptions = data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Некорректная запись подписки');
      }
      return _parseSubscription(item);
    }).toList();
    if (subscriptions.map((s) => s.id).toSet().length != subscriptions.length) {
      throw const FormatException('API вернул повторяющиеся идентификаторы');
    }
    // Сохраняем только полностью разобранный успешный ответ.
    _subscriptions = List.unmodifiable(subscriptions);
    return _subscriptions;
  }

  @override
  SubscriptionModel? findById(String id) {
    for (final subscription in _subscriptions) {
      if (subscription.id == id) return subscription;
    }
    return null;
  }
}
