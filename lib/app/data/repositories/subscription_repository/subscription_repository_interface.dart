import 'package:flutter_lab_1/app/data/models/subscription_model.dart';

abstract interface class SubscriptionRepositoryInterface {
  Future<List<SubscriptionModel>> getSubscriptions();
  Future<SubscriptionModel> getSubscriptionById(String id);
  SubscriptionModel? findById(String id);
}
