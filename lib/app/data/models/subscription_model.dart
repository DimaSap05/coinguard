import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

@JsonSerializable()
class SubscriptionModel {
  final String id; // Уникальный идентификатор
  final String name; // Название сервиса
  final double price; // Стоимость подписки
  final String period; // Период оплаты
  final DateTime nextBillingDate; // Дата следующего списания денег
  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color categoryColor; // Цвет для плашки категории на детальном экране
  final String categoryName; // Название категории
  final String? description; // Описание подписки

  // Конструктор класса
  SubscriptionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.nextBillingDate,
    required this.categoryColor,
    required this.categoryName,
    this.description,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);

  double get monthlyPrice => period == 'month' ? price : price / 12;

  // API передает цвет целым числом ARGB, например 0xFFFFC107.
  static Color _colorFromJson(int value) => Color(value);
  static int _colorToJson(Color value) => value.toARGB32();
}
