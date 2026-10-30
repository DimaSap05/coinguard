import 'package:flutter_lab_1/app/data/models/subscription_model.dart';

abstract interface class SubscriptionRepositoryInterface {
  Future<List<SubscriptionModel>> getSubscriptions();
  SubscriptionModel? findById(String id);
}
