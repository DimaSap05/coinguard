import 'package:flutter/material.dart';

import 'models/subscription_model.dart';

final List<SubscriptionModel> mockSubscriptions = [
  SubscriptionModel(
    id: 'sub_1',
    name: 'Яндекс Плюс',
    price: 399.0,
    period: 'month',
    nextBillingDate: DateTime.now().add(const Duration(days: 3)),
    categoryColor: Colors.amber,
    categoryName: 'Развлечения',
    description: 'Семейная подписка на Музыку и Кинопоиск.',
  ),
  SubscriptionModel(
    id: 'sub_2',
    name: 'Telegram Premium',
    price: 329.0,
    period: 'month',
    nextBillingDate: DateTime.now().add(const Duration(days: 13)),
    categoryColor: Colors.blue,
    categoryName: 'Соцсети',
    description: 'Увеличенные лимиты и кастомные эмодзи.',
  ),
  SubscriptionModel(
    id: 'sub_3',
    name: 'Фитнес-клуб «Мустанг»',
    price: 24000.0,
    period: 'year',
    nextBillingDate: DateTime.now().add(const Duration(days: 45)),
    categoryColor: Colors.green,
    categoryName: 'Спорт',
    description: 'Годовой абонемент с бассейном, сауной и хамамом.',
  ),
];

/// Найти подписку по id (для детального экрана).
SubscriptionModel? findSubscriptionById(String id) {
  for (final s in mockSubscriptions) {
    if (s.id == id) return s;
  }
  return null;
}

/// Суммарные траты за месяц (годовые раскладываем на 12).
double get totalMonthlySpend {
  return mockSubscriptions.fold<double>(0, (sum, s) {
    return sum + (s.period == 'month' ? s.price : s.price / 12);
  });
}
