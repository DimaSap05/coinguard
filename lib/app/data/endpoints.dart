class Endpoints {
  Endpoints._();

  static const String subscriptions = '/subscriptions';
  static String subscription(String id) =>
      '$subscriptions/${Uri.encodeComponent(id)}';
}
