part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoadInProgress extends HomeState {}

final class HomeLoadSuccess extends HomeState {
  HomeLoadSuccess({required List<SubscriptionModel> subscriptions})
    : subscriptions = List.unmodifiable(subscriptions);
  final List<SubscriptionModel> subscriptions;

  @override
  List<Object?> get props => [subscriptions];
}

final class HomeLoadFailure extends HomeState {
  const HomeLoadFailure({required this.exception});
  final Object exception;
  @override
  List<Object?> get props => [exception];
}
