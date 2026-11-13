part of 'content_bloc.dart';

sealed class ContentState extends Equatable {
  const ContentState();
  @override
  List<Object?> get props => [];
}

final class ContentInitial extends ContentState {}

final class ContentLoadInProgress extends ContentState {}

final class ContentLoadSuccess extends ContentState {
  const ContentLoadSuccess({required this.subscription});
  final SubscriptionModel subscription;
  @override
  List<Object?> get props => [subscription];
}

final class ContentLoadFailure extends ContentState {
  const ContentLoadFailure({required this.exception, this.notFound = false});
  final Object exception;
  final bool notFound;
  @override
  List<Object?> get props => [exception, notFound];
}
