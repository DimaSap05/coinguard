// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      period: json['period'] as String,
      nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
      categoryColor: SubscriptionModel._colorFromJson(
        (json['categoryColor'] as num).toInt(),
      ),
      categoryName: json['categoryName'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'period': instance.period,
      'nextBillingDate': instance.nextBillingDate.toIso8601String(),
      'categoryColor': SubscriptionModel._colorToJson(instance.categoryColor),
      'categoryName': instance.categoryName,
      'description': instance.description,
    };
