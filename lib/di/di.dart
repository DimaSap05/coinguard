import 'package:get_it/get_it.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_lab_1/app/data/dio/set_up.dart';
import 'package:flutter_lab_1/app/data/repositories/subscription_repository/subscription_repository.dart';
import 'package:flutter_lab_1/app/data/repositories/subscription_repository/subscription_repository_interface.dart';
import 'package:flutter_lab_1/app/features/home/bloc/home_bloc.dart';

final getIt = GetIt.instance;
final talker = TalkerFlutter.init();
final Dio dio = Dio();

Future<void> setupLocator() async {
  getIt.registerSingleton(talker);
  setUpDio();
  getIt.registerSingleton<SubscriptionRepositoryInterface>(
    SubscriptionRepository(dio: dio),
  );
  getIt.registerSingleton(HomeBloc(getIt<SubscriptionRepositoryInterface>()));
}
