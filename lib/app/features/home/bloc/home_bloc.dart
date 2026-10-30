import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab_1/app/data/models/subscription_model.dart';
import 'package:flutter_lab_1/app/data/repositories/subscription_repository/subscription_repository_interface.dart';
import 'package:flutter_lab_1/di/di.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this.subscriptionRepository) : super(HomeInitial()) {
    on<HomeLoad>(_homeLoad);
  }

  final SubscriptionRepositoryInterface subscriptionRepository;
  bool _loading = false;

  Future<void> _homeLoad(HomeLoad event, Emitter<HomeState> emit) async {
    if (_loading) {
      event.completer?.complete();
      return;
    }
    _loading = true;
    try {
      emit(HomeLoadInProgress());
      final subscriptions = await subscriptionRepository.getSubscriptions();
      emit(HomeLoadSuccess(subscriptions: subscriptions));
    } catch (exception, stackTrace) {
      emit(HomeLoadFailure(exception: exception));
      talker.handle(exception, stackTrace);
    } finally {
      _loading = false;
      if (!(event.completer?.isCompleted ?? true)) event.completer!.complete();
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    talker.handle(error, stackTrace);
  }
}
