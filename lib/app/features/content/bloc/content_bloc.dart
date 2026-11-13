import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab_1/app/data/data.dart';
import 'package:flutter_lab_1/di/di.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  ContentBloc(this.subscriptionRepository) : super(ContentInitial()) {
    on<ContentLoad>(_contentLoad);
  }

  final SubscriptionRepositoryInterface subscriptionRepository;
  int _request = 0;

  Future<void> _contentLoad(
    ContentLoad event,
    Emitter<ContentState> emit,
  ) async {
    final request = ++_request;
    emit(ContentLoadInProgress());
    try {
      final subscription = await subscriptionRepository.getSubscriptionById(
        event.contentId,
      );
      // При смене id показываем только результат последнего запроса.
      if (!emit.isDone && request == _request) {
        emit(ContentLoadSuccess(subscription: subscription));
      }
    } catch (exception, stackTrace) {
      talker.handle(exception, stackTrace);
      if (!emit.isDone && request == _request) {
        emit(
          ContentLoadFailure(
            exception: exception,
            notFound:
                exception is DioException &&
                exception.response?.statusCode == 404,
          ),
        );
      }
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    talker.handle(error, stackTrace);
  }
}
