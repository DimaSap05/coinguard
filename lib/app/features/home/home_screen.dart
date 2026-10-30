import 'package:flutter/material.dart';
import 'package:flutter_lab_1/app/data/data.dart';
import 'package:flutter_lab_1/app/extensions/widget_extensions.dart';
import 'package:flutter_lab_1/app/features/home/widgets/content_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab_1/app/features/home/bloc/home_bloc.dart';
import 'package:flutter_lab_1/app/widgets/widgets.dart';
import 'package:flutter_lab_1/di/di.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _home = getIt<HomeBloc>();

  void loadHome() => _home.add(const HomeLoad());

  @override
  void initState() {
    super.initState();
    loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoinGuard'),
        actions: [
          IconButton(
            onPressed: loadHome,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить подписки',
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        bloc: _home,
        builder: (context, state) => switch (state) {
          HomeInitial() => const SizedBox.shrink(),
          HomeLoadInProgress() => const AppProgressIndicator(),
          HomeLoadSuccess() => _buildHomeLoadSuccess(state),
          HomeLoadFailure() => AppError(
            description: 'Не удалось загрузить подписки. Проверьте подключение и повторите попытку.',
            onTap: loadHome,
          ),
        },
      ),
    );
  }

  Widget _buildHomeLoadSuccess(HomeLoadSuccess state) {
    final subscriptions = state.subscriptions;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Сводка по тратам
          _MonthlySummary(subscriptions: subscriptions),
          if (subscriptions.isEmpty) const Text('Подписок пока нет'),
          Text(
            'Мои подписки',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          ListView.separated(
            primary: false,
            shrinkWrap: true,
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final sub = subscriptions[index];
              return ContentCard(subscription: sub);
            },
            separatorBuilder: (_, _) => 16.ph,
          ),
        ],
      ),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({required this.subscriptions});
  final List<SubscriptionModel> subscriptions;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Траты за месяц',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          6.ph,
          Text(
            '${subscriptions.fold<double>(0, (sum, s) => sum + s.monthlyPrice).toStringAsFixed(0)} ₽',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          6.ph,
          Text(
            'Активных подписок: ${subscriptions.length}',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
